select * from transactions;
 
select * from investors;
 
select * from companies;
 
select * from transaction_outcomes;
 
--select dt from transactions where extract(second from dt) > 0;
 
--select dt from transactions where extract(minute from dt) > 0;
 
--select dt from transactions where extract(hour from dt) > 0;
 
--select id from companies except select distinct company_id from transactions;
 
--select distinct company_id from transactions except select id from companies;
 
 
-- check getting more 1 credit one company in one day 
--select company_id, dt, count(*) as cnt from transactions where type_of_invest = 'Credit' group by company_id, dt having count(*) > 1 order by company_id;
 
--select transaction_id, count(*) from transaction_outcomes group by transaction_id having(count(*) > 1);
 
--select * from transaction_outcomes;
 
 
--select * from transactions left join transaction_outcomes on transactions.id = transaction_outcomes.transaction_id  where transactions.type_of_invest = 'Credit' and  transaction_outcomes.transaction_id  is  null;
 
 
drop table if exists get_and_return_money;
create table get_and_return_money(
	transaction_id int,
	company_id int,
	received int,
	returned int,
	dt timestamp,
	util float
);
 
--select * from transactions where type_of_invest = 'Credit' order by dt desc;
 
insert into get_and_return_money(
	select 
		transactions.id,
		transactions.company_id,
		transactions.received,
		transaction_outcomes.returned,
		transactions.dt,
		transaction_outcomes.returned::float / transactions.received::float
 
	from transactions
	join transaction_outcomes on
		transactions.id = transaction_outcomes.transaction_id 
		and transactions.type_of_invest = 'Credit' 
		and transactions.dt <= '2020-02-03 00:00:00'
);	
--select * from get_and_return_money;
 
--подсчёт по двум датам кол-во дней между ними 
drop function if exists get_days;
create function get_days(timestamp1 timestamp, timestamp2 timestamp)
returns int as $$
declare 
	all_days int = 0;
	d int;
begin 
	--проблема в подсчёте дней (лесокосные года)
	--select extract(days from age(timestamp1, timestamp2)) as days into d; 
 	--all_days := all_days + d;
	--select extract(month from age(timestamp1, timestamp2)) * 12 as days into d; 
	--all_days := all_days + d;
	--select extract(year from age(timestamp1, timestamp2)) * 12 * 31 *  as days into d; 
	--all_days := all_days + d;
 
	SELECT (EXTRACT(EPOCH from timestamp1::date) - EXTRACT(EPOCH from timestamp2::date))/(24*3600) into all_days;
 
	return all_days;
end;
$$
language plpgsql;
 
--select get_days('2011-08-10 00:00:00', '2011-09-19 00:00:00');
 
--select distinct transaction_id from transaction_outcomes;
 
--вычисления определёного интеграла для определённой компании  
drop function if exists calc_safety;
create function calc_safety(id_comp integer)
returns float as
$$
declare 
	r_now get_and_return_money%rowtype;
	last_r get_and_return_money%rowtype;
	start_r get_and_return_money%rowtype;
	finish_r get_and_return_money%rowtype;
	integ float = 0.0;
	len int;
begin
	start_r.transaction_id := -1;
	start_r.company_id := id_comp;
	start_r.dt := '2006-01-01 00:00:00'::timestamp;
	start_r.util := 1.0;
 
 
	finish_r.transaction_id := -2;
	finish_r.company_id := id_comp;
	finish_r.dt := '2020-02-03 00:00:00'::timestamp;
	finish_r.util := 1.0;
 
	last_r.transaction_id := -3;
 
	for r_now in 
		(
			select *
		 	from get_and_return_money
			--where company_id = 1
			where company_id = id_comp
			order by dt asc 
		)
	loop
		-- case start
		if last_r.transaction_id = -3 then
			if get_days(r_now.dt, start_r.dt) = 0 then
				last_r :=  r_now;
				continue;
			else
				last_r := start_r;
			end if;
 
		end if;
 
		--raise notice 'DEBUG r.transaction_id=%, r.util=%', r_now.transaction_id , r_now.util;
 
		len := get_days(r_now.dt, last_r.dt);
		integ := integ + (r_now.util + last_r.util) * len::float / 2.0;
 
		last_r := r_now;
	end loop;
 
	if last_r.transaction_id = -3 then
		last_r := start_r;
	end if;
	if get_days(finish_r.dt, last_r.dt) <> 0 then 
		len := get_days(finish_r.dt, last_r.dt);
 
		--integ := integ + finish_r.util * len::float - (finish_r.util - last_r.util) * len::float / 2.0 ;
		integ := integ + (finish_r.util + last_r.util) * len::float / 2.0;	
	end if;
 
 
	return integ;
end;
$$
language plpgsql;
 
--вывод результатов с именем компании
with top_company_safety as(
	select 
		id,--company_id,
		company_name,
		calc_safety(id)--(company_ids.company_id)
	from companies--(select distinct(company_id) from transactions) as company_ids
	--join companies on
	--companies.id = company_ids.company_id
	--order by calc_safety desc
	--limit 3 
) 
select * from top_company_safety order by calc_safety desc limit 3;
--select string_agg(company_name, ',') as top_top_company_safety_by_string from top_company_safety;