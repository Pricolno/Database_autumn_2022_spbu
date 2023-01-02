Вот решение задачи 4.
 
Вначале создаётся таблица country_medians, где для каждой страны вычисляется медиана медиан её городов.
Я два раза использую percentile_cont(0.5): вначале, чтобы посчитать для каждого города медиану готовности деталей с готовностью не меньше 10 процентов
(таблица country_city_medians), а затем, чтобы посчитать медиану медиан городов для каждой страны (country_medians).
 
Затем функция transform_answer_table_into_text конкатенирует строки таблицы country_medians
в алфавитном порядке и с правильными знаками препинания.
 
Код работает меньше секунды, и выдаёт ответ:
Германия:17,Китай:18,Россия:17,США:18,Франция:17,
 
Бот этот ответ принял. Вот код.
 
drop function if exists transform_answer_table_into_text;
drop table if exists country_medians;
 
create table country_medians as
(
	with country_city_medians as
	(
		select 
		(select (case country when 'France' then 'Франция'
		 else country end) as country from town where town.id = tt.city_id)::text,
		city_id, 
		percentile_cont(0.5) within group(order by stage) as town_stage_median 
		from spaceship_part_in_town as tt 
		where stage > 9.999999 
		group by city_id
	)
	select country, percentile_cont(0.5) within group(order by town_stage_median) as median 
		from country_city_medians 
		group by country order by country
);
 
 
create function transform_answer_table_into_text() returns text
language plpgsql
as $$
declare
answer text = '';
i record;
begin
for i in (select * from country_medians order by country)
loop
answer = answer || i.country::text || ':' || i.median::text || ',';
end loop;
return answer;
end $$;
 
select transform_answer_table_into_text() as answer;
