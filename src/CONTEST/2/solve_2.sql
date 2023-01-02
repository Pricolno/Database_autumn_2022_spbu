select * from Spaceship_part_in_town;
select * from Spaceship_required_part;
 
select * from Spaceship_part;
select * from Spaceship;
select * from Town;
 
-- КОД НАЧИНАЕТСЯ С 66 строчке
 
 
-- В начале заимствование кода с предыдущего задания (первый пункт совпадает)  
--Проверить, какие типы кораблей можно построить,
-- если не производить новых деталей, а только доделывать те, которые уже в производстве
-- для этого считаем country_spaceships
 
--1
drop table if exists country_parts;
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
 
--2
drop table if exists country_spaceships;
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
 
--Посчитать, сколько нужно денег для завершения каждого из доступных для производства типа кораблей. 
--Считается, что для завершения детали нужно пропорциональное оставшейся работе количество монет
--(Пример: если Китай может построить Ястреб и Орел, так как имеет ресурсы,
--то в ответе должна быть указана суммарная стоимость доработки деталей для обоих кораблей)
--т.е. если нужно для Ястреба 4 навигатора, а Орлу 6, то нужно взять top 4 + top 6 (а не  top 10) деталей по stage 
 
--сначала считаем для ключа (country, spaceship, part) сколько part нужно для соответсвующего spaceship определйной country
-- создаём общую таблицу с производствами деталей 
-- (будем из неё выделять записи конкретного города и запчасти, 
-- а потом сортировать по stage и брать limit по суммарному кол-ву запчастей на одну деталь для страны)
-- просто проходимся по (country, spaceship, part) и для каждой пары считаем сколько нужно ещё потратить процентов денежных средств
 
 
------ if parts independent
 
 
drop function if exists permutation cascade;
 
drop table if exists sums_parts_spaceship cascade;
create table sums_parts_spaceship(
	country text,
	sum_parts_spaceship int
);
 
 
create or replace function permutation()
returns setof sums_parts_spaceship as
--returns int as 
$body$
declare 
	r sums_parts_spaceship%rowtype;
begin
	return query (select *
				 from sums_parts_spaceship
				 where sums_parts_spaceship.country = 'Китай'
				);
 
	return query (
		select * 
		from sums_parts_spaceship
		where sums_parts_spaceship.country <> 'Китай'
		order by sums_parts_spaceship.country
		);
 
	return;
end;
$body$
language plpgsql;
 
select * from permutation();
 
 
 
with country_spaceship_part_which_can_do as(
	select 	country_spaceship_we_can_do.country,
			country_spaceship_we_can_do.spaceship,
			Spaceship_required_part.spaceship_part,
			Spaceship_required_part.amount
	from (select country, spaceship from country_spaceships where num > 0) as country_spaceship_we_can_do
	join Spaceship_required_part on Spaceship_required_part.spaceship = country_spaceship_we_can_do.spaceship
) 
--select * from country_spaceship_part_which_can_do;
,country_spaceship_part_for_every_city_stage as(
	select
		country,
		spaceship,
		spaceship_part,
		stage,
		Spaceship_part_in_town.id,
		Spaceship_required_part.amount
	from Spaceship_part_in_town
	--added country
	join Town on
		Town.id = Spaceship_part_in_town.city_id
	--added spaceship
	join Spaceship_required_part on 
		Spaceship_required_part.spaceship_part = Spaceship_part_in_town.spaceship_part_id
) 
--select count(*) from country_spaceship_part_for_every_city_stage as csp_cs group by csp_cs.id
--select * from country_spaceship_part_for_every_city_stage as csp_cs order by stage desc; 
,min_cost_country_spaceship_part_in_percent as(
	select 
		csp.country,
		csp.spaceship,
		csp.spaceship_part,
		--csp.amount, --true amount for detail of spaceship --for check up
		(
			select sum(100 - biggest_stage_for_csp.stage) as sum_rest_stage
			--select count(*) as count_notes
			--select csp.country
			from(
				select *
				from country_spaceship_part_for_every_city_stage as csp_cs
				where
					csp_cs.country = csp.country and
					csp_cs.spaceship = csp.spaceship and
					csp_cs.spaceship_part = csp.spaceship_part
				order by csp_cs.stage desc
				--limit 100
				-- amount spaceship_part for spaceship (fix in csp) 
				limit (
					select amount 
					from Spaceship_required_part
					where
						Spaceship_required_part.spaceship_part = csp.spaceship_part and
						Spaceship_required_part.spaceship = csp.spaceship
 
				)
			) as biggest_stage_for_csp
		)
	from country_spaceship_part_which_can_do as csp 
)
--select * from min_cost_country_spaceship_part;
,min_cost_country_spaceship_part_in_money as(
	select 
		min_cost_csp.country,
		sum(min_cost_csp.sum_rest_stage * Spaceship_part.cost) / 100 as sum_parts_spaceship
	from min_cost_country_spaceship_part_in_percent as min_cost_csp
	join Spaceship_part on
		min_cost_csp.spaceship_part = Spaceship_part.id
	group by country 
)
insert into 
	sums_parts_spaceship(country, sum_parts_spaceship)
select 
	country,
	sum_parts_spaceship as sum_parts_spaceship
from min_cost_country_spaceship_part_in_money
order by country;
 
select * from permutation();