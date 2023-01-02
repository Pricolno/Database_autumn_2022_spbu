Решение задачи 9. 
 
Вначале создаётся таблица credits_returned,
в которой записываются строки (компания, сколько денег вернула, дата возвращения).
 
Дальше функция get_price_of_company, которая по id компании и моменту времени говорит, 
сколько стоила компания в этот момент (изменения, случившиеся в этот момент учитываются).
Внутри функции создаётся таблица changes, в которую записываются все изменения, происходящие со стоимостью компании до момента,
в который надо узнать цену, включительно.
Записи вида (дата-время, изменение стоимости).
Затем эти изменения сортируются по времени, и в цикле применяются по очереди к изначальной стоимости компании.
Если изменение делает цену компании отрицательной, то цена делается нулём.
 
И финальный запрос: сложить цены трёх компаний на момент, когда предложил продать друг, и вычесть из них
цены трёх компаний на момент, когда решил продать Анатолий, дальше поделить на 10000, так как у Анатолия не все,
а только по 5 акций, и округлить вниз.
 
Код отработал меньше, чем за секунду, и выдал ответ 17264.
Бот этот ответ принял. Вот код.
 
drop table if exists credits_returned;
drop function if exists get_price_of_company;
 
create table credits_returned as(
	select company_id,returned, dt from 
	(select company_id, id from transactions) as t1
	join (select returned, dt, transaction_id as t_id from transaction_outcomes) as t2 
	on t1.id = t2.t_id 
);
 
create function get_price_of_company(comp_id int, moment timestamp without time zone) returns float
language plpgsql
as $$
declare
total_price float = (select start_price from companies where id = comp_id)::float;
i record;
begin
	create temp table changes
	(
		dt timestamp without time zone,
		change float
	);
	for i in (select * from transactions where company_id = comp_id and dt <= moment order by dt)
	loop
		case i.type_of_invest
		when 'Invest' then
			insert into changes values(i.dt, i.received::float);
		when 'Donation' then
			insert into changes values(i.dt, i.received::float);
			if i.dt+'3 week' <= moment then
				insert into changes values(i.dt+'3 week', -i.received::float*0.5);
			end if;
		when 'Credit' then
			insert into changes values(i.dt, i.received::float*0.5);
		end case;
	end loop;
	for i in (select * from credits_returned where company_id = comp_id and dt <= moment order by dt)
	loop
		insert into changes values(i.dt, -i.returned::float*2.0);
	end loop;
	for i in (select * from changes order by dt)
	loop
		total_price := greatest(0.0, total_price+i.change);
	end loop;
	drop table changes;
	return total_price;
end $$;
 
select floor((get_price_of_company((select id from companies where company_name = '4 TanLab')::int, '2018-01-10 00:00:00')+
	   get_price_of_company((select id from companies where company_name = 'Le Fe Waveenv')::int, '2018-01-10 00:00:00')+
	   get_price_of_company((select id from companies where company_name = 'MayCev')::int, '2018-01-10 00:00:00')-
	   get_price_of_company((select id from companies where company_name = '4 TanLab')::int,'2017-01-10 00:00:00')-
	   get_price_of_company((select id from companies where company_name = 'Le Fe Waveenv')::int,'2017-01-10 00:00:00')-
	   get_price_of_company((select id from companies where company_name = 'MayCev')::int,'2017-01-10 00:00:00'))/(10000::float));