Просто прохожу в цикле по всем инвестициям, упорядоченным по инвестору, и, пока инвестор не меняется,
накапливаю инвестиции в массиве. Когда меняется, проверяю, правда ли, что min/avg > 0.02 в текущем массиве,
и если да, добавляю к ответу 1. При смене инвестора очищаю массив, и начинаю копить значения для следующего инвестора.
Так как минимум функции из задачи достигается на максимальной инвестиции, 
то минимальное значение формулы для инвестора равно -min/avg в его массиве.
 
Здесь функции, циклы и массивы, но джойнов и рекурсий нет. 
 
drop function if exists get_answer;
create function get_answer() returns int
language plpgsql
as $$
declare
ans int := 0;
i record;
inv_id int := -1;
arr float[] := '{}'; 
begin
	for i in (select * from transactions where type_of_invest = 'Invest' order by investor_id)
	loop
		if i.investor_id != inv_id and inv_id != -1 then
			if ((SELECT min(x) FROM unnest(arr) as tt(x))::float/
			(SELECT avg(x) FROM unnest(arr) as tt(x))::float) > 0.02::float then
				ans := ans+1;
			end if;
			arr := '{}';
		end if;
		inv_id := i.investor_id;
		arr := arr || (i.received)::float;
	end loop;
	if inv_id != -1 then
		if ((SELECT min(x) FROM unnest(arr) as tt(x))::float/
			(SELECT avg(x) FROM unnest(arr) as tt(x))::float) > 0.02::float then
			ans := ans+1;
		end if;
		arr := '{}';
	end if;
return ans;
end $$;