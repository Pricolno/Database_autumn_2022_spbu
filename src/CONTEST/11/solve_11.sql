select * from family;
select * from gotrones_db;
 
drop index if exists index_parent_gotrone_id;
drop function if exists get_children;
drop index if exists index_parent_gotrone_id;
drop table if exists global_ans;
drop procedure if exists update_global_ans;
drop function if exists get_max_gotrone;
 
 
 
--самый большой фиксик
--select * from gotrones_db where parent_gotrone_id = -1;
 
--показываем что суммарно сходится количество
--select * from gotrones_db order by gotrone_id desc;
--select log(5.0, 4 * 488281.0 + 1.0);
--select (5 ^ 9 - 1) / 4;
 
--создаём индексы для быстрого тупого поиска
--drop index if exists index_parent_gotrone_id;
CREATE INDEX index_parent_gotrone_id ON gotrones_db (parent_gotrone_id);
 
--drop index if exists index_gotrone_id;
CREATE INDEX index_gotrone_id ON gotrones_db (gotrone_id);
 
--функция по большому фиксику возращает 5 детей (на ранг младше фиксиков)
--drop function if exists get_children;
create function get_children(parent_id int)
returns table(gotrone_id int,
			  power int) as 
$$
begin 
	return query(
		select gotrones_db.gotrone_id, gotrones_db.power
		from gotrones_db
		--where parent_gotrone_id = 488280
		where gotrones_db.parent_gotrone_id = parent_id
	);
 
end;
$$
language plpgsql;
 
--тут будут хранится top3 фиксиков и постоянно сортироваться
--drop table if exists global_ans;
create table global_ans(
	gotrone_id int,
	power int 
);
 
--добавляем вершину в сортировочную переменную 
--ВАЖНО: в ходе решения задаки, стало ОПРЕДЕЛЁННО понятно, что delete и insert дороже 
-- чем select и  update
--drop procedure if exists update_global_ans;
create procedure update_global_ans(gotrone_id_ int, power_ int)
as
$$
begin 
	if (select count(*) from global_ans) < 3 then 
		insert into global_ans values (gotrone_id_, power_);
	elsif (select power
		   from global_ans
		   order by power asc limit 1) < power_ then 
		update global_ans
		set gotrone_id = gotrone_id_, power = power_	
		where
			global_ans.gotrone_id = (select gotrone_id
									 from global_ans
									 order by power asc
									 limit 1);
	end if;
 
	--raise notice 'count_global_ans=%', (select count(*) from global_ans);
 
	--too much time :(
	--insert into global_ans values (gotrone_id_, power_);
 
	--delete 
	--from global_ans
	--where gotrone_id in (select gotrone_id 
	--					 from global_ans
	--					 order by power desc
	--					 offset 3);
 
 
 
	--need top 3
	--raise notice 'count_global_ans=%', (select count(*) from global_ans);
 
 
	--if  ((select gotrone_id from global_ans) is null) or
	--	((select power from global_ans) is null) or
	--	(select power from global_ans) < power_ then
	--	update global_ans 
	--		set gotrone_id = gotrone_id_, power = power_;
	--end if;
 
	return;
end;
$$
language plpgsql;
 
--select * from global_ans;
--call update_global_ans(4, 5);
--select * from global_ans;
 
 
--рекурсивно спускаемся к детям и считаем суммарную power в поддереве 
--drop function if exists get_max_gotrone;
create function get_max_gotrone(cur_gotrone int) 
returns int as
$$
declare 
	count_children int;
	a int;
	cur_power int; 
begin
	select 
		count(*),
		sum(get_max_gotrone(gch.gotrone_id)) 
	into
		count_children,
		cur_power
	from get_children(cur_gotrone) as gch;
 
	--raise notice 'count_children=%', count_children;
	--raise notice 'cur_gotrone=%', cur_gotrone;
	--raise notice 'count_children=% cur_power=%', count_children, cur_power;
 
	if count_children = 5 then
		call update_global_ans(cur_gotrone, cur_power);
 
		return cur_power;
 
	elsif count_children = 0 then 
		select 
			gotrones_db.power 
		into cur_power 
		from gotrones_db
		where gotrones_db.gotrone_id = cur_gotrone;
 
		call update_global_ans(cur_gotrone, cur_power);
 
		return cur_power;
	else 
		assert('count_children not in [0, 5]');
	end if;	
end;
$$
language plpgsql;
 
--select * from gotrones_db;
 
--488280 самый большой из фиксиков
--select * from gotrones_db where parent_gotrone_id = -1;
 
 
 
 
--запускаем поиск top3 фиксика
select 1 from get_max_gotrone(
	(select gotrone_id
	from gotrones_db 
	where parent_gotrone_id = -1));
 
--select * from global_ans order by power desc;
 
 
--приводим ответ к нужному формату 
select
	string_agg(global_ans.gotrone_id::text || '-' || global_ans.power::text, ','  order by global_ans.power desc) as ans
from global_ans;