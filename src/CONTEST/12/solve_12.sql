Решение задачи 12: вначале в cred_info собираю всю информацию в одну таблицу, заодно убираю неправильные дедлайны.
Я работаю с удвоенными hope везде.
inv_res - таблица, где для каждого инвестора его hope и число компаний в конце.
Процедура insert_investor_result добавляет строчку в inv_res, она накапливает события для инвестора в таблице events, а компании
в которые инвестируется на текущем шаге хранятся в comp.
В цикле все события обрабатываются в хронологическом порядке.
Процедура call_for_all_inv вызывает insert_investor_result для всех инвесторов.
Дальше вывод ответа.
Программа работает 4 секунды и выдаёт ответ 131-16,148-15,138-16
Этот ответ принят ботом.
 
 
drop table if exists cred_info;
drop table if exists inv_res;
drop procedure if exists insert_investor_result;
drop procedure if exists call_for_all_inv;
 
create table cred_info as
(
	with cred1 as
	(
		select * from transactions where type_of_invest = 'Credit' and received < 20000000
	),
	cred2 as
	(
		select id,company_id,start_price,investor_id,received,dt 
		from (select * from cred1) as t1 join (select id as iddddd, start_price from companies) as t2
		on t1.company_id = t2.iddddd
	),
	cred3 as
	(
		select id,company_id,start_price,investor_id,received,dt,deadline_dt as deddt,hope  
		from (select * from cred2) as t1 left join (select * from credit_outcomes) as t2
		on t1.id = t2.transaction_id
	),
	cred4 as
	(
		select id,company_id,start_price,investor_id,received,dt,
		(case when dt < deddt and deddt < '2100-01-01'::timestamp and deddt >= '2000-01-01'::timestamp then deddt else null end) as deddt,
		hope 
		from cred3
	),
	cred5 as
	(
		select id,company_id,start_price,investor_id,received,dt,deddt,
		(case when deddt is null then 10 else hope*2 end) as hope 
		from cred4
	),
	cred6 as
	(
		select id,company_id,start_price,investor_id,received,dt,deddt,hope,returned,retdt from
		(select * from cred5) as t1 left join (select transaction_id as ttid, returned, dt as retdt from transaction_outcomes) as t2
		on t1.id = t2.ttid
	)
	select * from cred6
);
 
--select * from cred_info;
 
create table inv_res
(
	investor_id int,
	hope int,
	num_comp int
);
 
 
create procedure insert_investor_result(inv_id int)   --all hopes *2
language plpgsql
as $$
declare
inv_hope int = 200;
i record;
pp int;
pdt timestamp;
begin
	create table inv_info as
	(
		select * from cred_info where investor_id = inv_id
	);
	create table comp
	(
		comp_id int primary key,
		start_price int,
		start_inv_dt timestamp
	);
	create table events
	(
		dt timestamp,
		comp_id int,
		start_price int,
		delta_hope int,
		type_fear int -- 0 new_comp, 1 no fear, 2 fear min_start_price, 3 fear min start_inv_dt
	);
	insert into events
	(
		select dt, company_id as comp_id, start_price, 0 as delta_hope, 0 as type_fear from inv_info
	);
	insert into events
	(
		select retdt as dt, company_id as comp_id, start_price, hope as delta_hope, 1 as type_fear from inv_info
		where (not retdt is null) and received <= returned and (deddt is null or retdt <= deddt)
	);
	insert into events
	(
		select retdt as dt, company_id as comp_id, start_price, -(hope/2)::int as delta_hope, 2 as type_fear from inv_info
		where (not retdt is null) and received > returned and (deddt is null or retdt <= deddt)
	);
	insert into events
	(
		select deddt as dt, company_id as comp_id, start_price, -hope*2 as delta_hope, 3 as type_fear from inv_info
		where (not deddt is null) and (retdt is null or retdt > deddt)
	);
	insert into events
	(
		select retdt as dt, company_id as comp_id, start_price,(hope/2)::int as delta_hope, 1 as type_fear from inv_info
		where (not deddt is null) and (not retdt is null) and retdt > deddt
	);
	for i in (select * from events order by dt asc)
	loop
		if inv_hope > 0 then inv_hope = inv_hope+i.delta_hope; else inv_hope = 0; end if;
		if inv_hope > 200 then inv_hope = 200; end if;
		case i.type_fear
			when 0 then
				insert into comp
				(select i.comp_id as comp_id, i.start_price as start_price, i.dt as start_inv_dt)
				on conflict (comp_id) do nothing;
			when 2 then
				pp = (select min(start_price) from comp)::int;
				delete from comp where start_price = pp;
			when 3 then
				pdt = (select min(start_inv_dt) from comp)::timestamp;
				delete from comp where start_inv_dt = pdt;
			else
				pp = 0; -- do nothing
		end case;
	end loop;
	insert into inv_res (select inv_id as investor_id,inv_hope as hope,(select count(*) from comp)::int as num_comp);
	drop table events;
	drop table inv_info;
	drop table comp;
end $$;
 
 
create procedure call_for_all_inv()
language plpgsql
as $$
declare
i record;
begin
	for i in (select distinct investor_id from transactions)
	loop
		call insert_investor_result(i.investor_id);
	end loop;
end $$;
 
call call_for_all_inv();
with ans1 as
(
	select * from inv_res order by hope desc,investor_id asc limit 12
),
ans2 as
(
	select * from ans1 order by hope asc,investor_id desc limit 3
)
select * from ans2 order by hope desc,investor_id asc;