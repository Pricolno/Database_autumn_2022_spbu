Я написала код для задачи 1 и получила такой ответ:
США:9069719,4-986,5-4950,Россия:2400786,4-0,5-2488,Германия:7077455,4-0,Китай:,Франция:,5-0,
 
Ответ принят ботом.
 
Немного пояснений к коду. Структура программы: 
1) Вначале создается таблица country_parts, в которой для каждой страны и каждой детали хранится,
сколько таких деталей у страны в производстве.
Она заполняется двумя запросами, в первом я добавляю все детали из таблиц условия,
а во втором добавляю нули для тех пар страна-деталь, что эта страна не сделала ни одной такой детали.
2) Дальше создаётся таблица country_spaceships. В ней для каждой страны и для каждого корабля
хранится, сколько таких кораблей может построить эта страна.
3) Создаётся таблица budgets, в которой для каждой страны вычисляется, сколько монет она вложила в детали.
4) Создаётся функция make_country_report которая по стране выдаёт строчку 'страна:вся информация про неё,'
В этой функции информация об инвестициях берётся из budgets, информация о кораблях из country_spaceships.
Есть костыль, заменяющий France на Франция, поскольку в базе данных на emkn вечером во вторник было всё ещё France.
Разбираются случаи, и результаты других стран, не меньшие, чем у США, и нулевые результаты США опускаются.
5) Финальный запрос конкатенирует отчёты о всех странах.
 
Код отработал за 7 секунд.
Вот код для задачи 1.
 
drop table if exists country_parts;
drop table if exists country_spaceships;
drop table if exists budgets;
drop function if exists make_country_report;
 
create table country_parts
(
	country text,
	part_id int,
	num int
);
 
with parts as
(
	select *, (select country from town where town.id = tt.city_id) from spaceship_part_in_town as tt where stage > 0.00001
),
cp as
(
	select country,spaceship_part_id as part_id, count(*) as num 
	from parts group by spaceship_part_id, country order by country,spaceship_part_id
)
insert into country_parts(country, part_id, num) select * from cp;
 
with tt_country as
(
	select distinct country from town
),
tt_part as
(
	select id as part_id from spaceship_part
)
insert into country_parts(country, part_id, num)
select *, 0 from tt_country inner join tt_part 
				on (select count(*) from country_parts as tt where tt.country = tt_country.country
					and tt.part_id = tt_part.part_id)::int = 0;
 
 
create table country_spaceships as( 
with country_spaceship_part as
(
	select country, spaceship, part_id, num as num_exist, amount as num_reqired, num/amount as upper_bound from
	(
		(select * from country_parts) as t1
		inner join
		(select * from spaceship_required_part) as t2
		on t1.part_id = t2.spaceship_part
	) as tt
)
select country, spaceship, min(upper_bound) as num from country_spaceship_part 
group by country, spaceship order by country, spaceship);
 
 
create table budgets as
(
	with parts as
	(
		select (select country from town where town.id = tt.city_id) as country,
		tt.spaceship_part_id as part_id, tt.stage::bigint as stage, 
		(select cost from spaceship_part where id = tt.spaceship_part_id)::bigint as price 
		from spaceship_part_in_town as tt
	)
	select country, sum(price::bigint*stage::bigint)/(100::bigint) 
						as budget from parts group by country
);
 
 
create function make_country_report(name_country text) returns text
language plpgsql
as $$
declare
report text = (case name_country when 'France' then 'Франция' else name_country end) ||':';
i record;
money bigint;
moneyUSA bigint;
begin
money = (select budget from budgets where country = name_country)::bigint;
moneyUSA = (select budget from budgets where country = 'США')::bigint;
if name_country = 'США' and moneyUSA > 0 or
(name_country != 'США' and moneyUSA > money)
then
report = report || money::text;
end if;
report = report || ',';
for i in (select * from country_spaceships where country = name_country order by spaceship)
loop
if name_country = 'США' and i.num > 0 or
(name_country != 'США' and 
i.num < (select num from country_spaceships where country = 'США' and spaceship = i.spaceship)::bigint)
then
report = report || i.spaceship::text || '-' || i.num::text || ',';
end if;
end loop;
return report;
end $$;
 
 
select make_country_report('США') || make_country_report('Россия') ||
make_country_report('Германия') || make_country_report('Китай') ||
make_country_report('France') 
as answer;