select * from Spaceship_part_in_town;
select * from Spaceship_required_part;
 
select * from Spaceship_part;
select * from Spaceship;
select * from Town;
 
-- считаем для каждого города количество "деталей" (if stage < 10 : не деталь)
drop table if exists counts_part_spaceship;
create table counts_part_spaceship(
	city_id int,
	count_part_spaceship bigint
);
 
with tt as(
	select city_id, count(*) as count_part_spaceship  from Spaceship_part_in_town
	where stage >= 10
	group by city_id
	order by city_id
) 
insert into counts_part_spaceship(city_id, count_part_spaceship)
select city_id, count_part_spaceship
from tt;
 
--7! = 5040 на так много для алгоритма с асимтотикой работы O(n^2)
-- поэтому будем генерировать все перестановки городов all_permutation
 
--select * from counts_part_spaceship;
 
drop table if exists all_permutation;
create table all_permutation(
	sequense integer[]
);
 
 
WITH RECURSIVE
t(num) AS (
	select city_id::int
	from counts_part_spaceship
)
,cte AS (
	SELECT 
		array[num] AS sequense,
		num as num,
		1 AS len
	FROM t
	UNION ALL
	SELECT
		array_append(cte.sequense, t.num),
		t.num,
		len + 1
	FROM cte
	join t on
		not array[t.num] && cte.sequense
	where cte.len <= 7
)
insert into all_permutation(sequense)
SELECT 
	cte.sequense
FROM cte
--where len = 7
where len =(
			select count(*)
			from counts_part_spaceship)
ORDER BY len, sequense;
 
--select * from all_permutation;
 
-- функция по городу возращает кол-во деталей (в 0 городе 0 деталей)
drop function if exists get_count;
create function get_count(city int)
returns int as
$$
begin
	if city = 0 then 
		return 0;
	end if;
 
	return (select count_part_spaceship 
			from counts_part_spaceship 
			where counts_part_spaceship.city_id = city);
end;
$$
language plpgsql;
 
--select get_count(1);
 
-- функция вычисляет успешность по порядку обхода городов
drop function if exists calc_succ(arr integer[]);
create function calc_succ(arr integer[])
returns int as
$$
declare 
	ind int;
	insp float;
	cnt_shoks int;
	succ int;
	eps float;
begin 
	eps := 0.00001;
	arr := '{0, 0}' || arr;
	insp := 5.0;
	cnt_shoks := 0;
	for ind in 
		(select gen_ind 
		 from generate_subscripts(arr, 1) as gen_ind)
		loop
			if ind = 1 or ind = 2 then 
				--raise notice 'DEBUG'; 
				continue;
			end if;
 
 
			if 2 * get_count(arr[ind]) > (get_count(arr[ind - 1]) + get_count(arr[ind - 2])) then 
				insp := insp + 3.0 + ln(get_count(arr[ind])::float - LEAST(get_count(arr[ind - 1]),
																get_count(arr[ind - 2]))::float);
			else
				insp := insp - 2.0;
			end if;
 
			raise notice 'SHOK ind=% arr[%]=% | insp=%', ind, ind, get_count(arr[ind]), insp;
 
			if insp < -eps then 
				cnt_shoks := cnt_shoks + 1;
				--raise notice 'SHOK ind=% arr[%]=%', ind, ind, arr[ind];
			end if;
 
		end loop;
	succ := round((10.0 - cnt_shoks::float) * insp); 
	return succ;
end;
$$
language plpgsql;
 
--select * from all_permutation;
--select sequense, calc_succ(sequense) from all_permutation order by calc_succ desc;
 
-- считаем значение по всем перестановкам, сортируем, берём наибольший и склеиваем результат по формату 
select string_agg(var::text, ', ') || ',' as submition
from unnest((
	select (calc_succ || sequense)  as ans
	from(
		select
			sequense,
			calc_succ(sequense)
		from all_permutation
		order by calc_succ desc
		limit 1
		) seq_succ
	)) var