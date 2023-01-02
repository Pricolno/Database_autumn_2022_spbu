--красивый вывод
drop function if exists ans_view;
create function ans_view(
	avg_gene int,
	med_gene int,
	q_woman int,
	q_man int,
	pop_name text
)
returns text as $ans$
declare 
	ans text;
begin
	ans := avg_gene::text || ', ' || med_gene::text || ', ' || 
			q_woman::text || ', ' || q_man::text || ', ' || 
			pop_name;
	return ans;
end;
$ans$
language plpgsql;
 
 
drop function if exists main;
create function main()
returns text as $ans$
declare
	ans text;
	pop_name text;
	med_gene int;
	q_woman int;
	q_man int;
	avg_gene float;
begin
	--самое популярное имя
	select name into pop_name from trooper 
		group by name 
		order by(count(name)) 
			DESC limit 1;
 
	--медиана
	select PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY gene) into med_gene FROM trooper;
 
	--находим лучших штурмовиков
	drop table if exists best;
	create temp table best(
		sex bool,
		quantity int
	);
 
	insert into best(
		with top as(
			select * from trooper 
				order by gene DESC,
						id limit 100
		) 
		select sex, count(sex) as quantity from top 
			group by sex
	);
 
	--считаем женщин и мужчин среди лучших
	select quantity into q_woman from best where sex = false; 
	select quantity into q_man from best where sex = true; 
 
	--считаем средний навык
	select avg(gene) into avg_gene from trooper;
	ans := ans_view(floor(avg_gene)::int, med_gene, q_woman, q_man, pop_name);
	return ans;
end;
$ans$
language plpgsql;
 
select main();