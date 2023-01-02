select * from family;
select * from gotrones_db;
 
drop table if exists gotrones;
drop table if exists gotrones_buff;
drop function if exists get_top3;
drop function if exists create_next_gotrones;
 
 
-- в целом наш алгоритм состоит из двух много повторённых шагов
-- 1.  Находим top3 среди Go^k_trone  get_top3 и кладём в answer
-- 2.  С помощью create_next_gotrones считаем power от Go^k_trone к Go^(k + 1)_trone 
-- 3.  В конце делаем generate_series нужное кол-во раз (макс кол-во GO)
-- Вместо generate_series можно использовать, конечно, ROLLUP (для модуляции цикла), но бред какой-то 
create temp table gotrones
as(
	select 
		parent.gotrone_id,
		parent.parent_gotrone_id,
		--parent.member_id,
		--parent.gotrone_type,
		parent.power
	from gotrones_db as child
    right join gotrones_db as parent
		on child.parent_gotrone_id = parent.gotrone_id 
    where 
		child.parent_gotrone_id is Null
);
select * from gotrones;
 
 
 
create temp table gotrones_buff as(
	select * from gotrones where False
);
select * from gotrones_buff;
 
 
 
 
drop table if exists answer cascade;
create table answer as(
	select gotrone_id, power from gotrones
	where False
);
select * from answer;
 
 
create function get_top3() returns void as
$$
begin
	execute 
		'
		insert into answer 
			select 
				gotrone_id,
				power
			from ' || ' gotrones ' || 
			'order by power desc limit 3
		';	
 
	return;
end;
$$ language plpgsql;
 
--select get_top3();
--select * from answer;
 
 
create function create_next_gotrones() returns void as
$$
begin
	execute 
		'
		insert into gotrones_buff 
			select 
				gt_pgt_p.gotrone_id,
				gotrones_db.parent_gotrone_id,
				gt_pgt_p.power
			from
				(select 
					parent_gotrone_id as gotrone_id,
					Null,
					sum(power) as power
				from ' || ' gotrones ' || 
				'group by parent_gotrone_id) as gt_pgt_p
			join gotrones_db on 
				gt_pgt_p.gotrone_id = gotrones_db.gotrone_id
		';	
 
	execute 
		'
		TRUNCATE gotrones CASCADE;
		';
	execute 
		'
		insert into gotrones
			select *
			from gotrones_buff 
		';
	execute
		'
		TRUNCATE gotrones_buff CASCADE;
		';
 
	return;
end;
$$ language plpgsql;
 
 
 
-- get max_count GO
--select (length(gotrone_type) - length('trone')) / length('Go') as max_count_go  from gotrones_db order by length(gotrone_type) desc limit 1 ;
 
 
select step, get_top3(), create_next_gotrones()  
from generate_series(1, (
	select (length(gotrone_type) - length('trone')) / length('Go') as max_count_go  from gotrones_db order by length(gotrone_type) desc limit 1
)) as step;
 
--select * from answer order by power desc limit 3;
 
--приводим ответ к нужному формату 
select
	string_agg(top_3.gotrone_id::text || '-' || top_3.power::text, ',') as ans
from (select * from answer order by answer.power desc limit 3) as top_3;