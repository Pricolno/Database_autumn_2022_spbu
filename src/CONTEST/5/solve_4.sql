-- подсчет умений ребенка по генам родителей
drop function if exists child_gene;
create function child_gene(man_id int, man_gene int, woman_id int, woman_gene int)
returns int as $gene$
declare
	--умение ребенка
	gene integer;
	--считаемая сумма генов родителей на данном шагу
	cur_g integer;
begin
	gene := 0;
	for i in 0..7 LOOP
		cur_g := woman_gene % 2 + man_gene % 2;
		if cur_g = 0 then
			if man_id > woman_id then
				gene := gene + 2^i;
			end if;
		end if;
		if cur_g = 1 then
			gene := gene + ( woman_gene % 2) * 2^i;
		end if;
		if cur_g = 2 then
			gene := gene + 2^i;
		end if;
 
		man_gene := man_gene / 2;
		woman_gene := woman_gene / 2;
	end LOOP;
	return gene;
end;
$gene$
language plpgsql;
 
--красивый вывод
drop function if exists ans_view;
create function ans_view(
		man_id int,
		man_name text,
		man_gene int,
		woman_id int ,
		woman_name text,
		woman_gene int,
		child_gene int)
returns text as $ans$
declare 
	ans text;
begin
	ans := woman_name || ', ' || woman_gene::text || ', ' || 
			man_name || ', ' || man_gene::text || ', ' || 
			child_gene::text;
	return ans;
end;
$ans$
language plpgsql;
 
--основаная функция, алгоритм:
--	находим все возможные пары родителей и какой будет их ребенок(families)
--	находим навык наиболее способного ребенка (минимальную разницу между 'недостижимым' максимумом 256 и рельным навыком)
--	находим всех детей с таким навыком и выбираем с наименьшей суммой id родителей
drop function if exists main;
create function main()
returns text as $ans$
declare
	ans text;
	min_diff int;
begin
	drop table if exists families;
 
	create temp table families(
		man_id int,
		man_name text,
		man_gene int,
		woman_id int ,
		woman_name text,
		woman_gene int,
		child_gene int
	);
 
	insert into families(
		with woman as(
			select * from trooper where sex = false
		) 
		select 
			man.id as man_id, man.name as man_name, man.gene as man_gene, 
			woman.id as woman_id, woman.name as woman_name, woman.gene as woman_gene,
			child_gene(man.id, man.gene, woman.id, woman.gene) as child_gene
			from trooper as man 
				cross join woman
				where man.sex = true
	);
 
	select min(256 - child_gene) into min_diff from families;
 
	with best_child as(
	select *, man_id + woman_id as sum_ids 
		from families 
			where child_gene + min_diff = 256
	) select ans_view(man_id ,
		man_name ,
		man_gene ,
		woman_id  ,
		woman_name ,
		woman_gene ,
		child_gene ) into ans
		from best_child
		order by sum_ids limit 1;
	return ans;
end;
$ans$
language plpgsql;
 
select main();