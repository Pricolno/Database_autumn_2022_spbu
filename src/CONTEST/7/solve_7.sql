Решение задачи 7.
 
Здесь 4 таблицы и функция.
 
Таблица teams: для каждой команды (названной по первой букве имени) вычисляется, сколько в ней людей.
 
Таблица alliances: в ней все тройки команд (их не больше 26*26*26), команды в тройках упорядочены и без повторов,
строка таблицы: team1, team2, team3, strength, где strength - сумма количеств людей в командах.
 
Таблица alliances_and_weakest_enemies: получена из таблицы alliances добавлением столбца
strength_of_weakest_enemy - силы самого слабого союза, с которым данный союз не пересекается.
Самый слабый союз берётся как top-3 из команд, которые не совпадают ни с одной из команд данного союза,
так что асимптотика вычисления этой таблицы максимум (число союзов*число команд) <= (число команд)^4 <= 26*26*26*26. 
Таблица может быть посчитана неверно, если команд всего меньше 6, и никакие союзы не могут сражаться. 
Для этого в функции, печатающей ответ, есть if,
чтобы вывести пустую строку, если команд меньше 6.
 
Таблица t_answer: имена без повторов всех людей из трёх команд самого слабого союза, такого, что он сильнее, чем его самый слабый враг.
 
Функция transform_answer_table_into_text выдаёт строку, где записаны через запятые и с пробелами имена из t_answer.
Если всего команд меньше, чем 6, то выдаёт пустую строку.
 
Код работает меньше секунды и выдаёт ответ:
Eddy, Kazuya, King, Sergei, Steve
 
Этот ответ принят ботом. 
 
Вот код:
 
drop table if exists teams;
drop table if exists alliances;
drop table if exists alliances_and_weakest_enemies;
drop table if exists t_answer;
drop function if exists transform_answer_table_into_text;
 
create table teams as
(
	select team, count(*) from (select substring(name,1,1) as team from trooper) as tt 
	group by team order by count
);
 
create table alliances as
(
	with alliances1 as
	(
		select * from 
		((select team as team1, count as count1 from teams) as t0 
		 inner join 
		(select team as team2, count as count2 from teams) as t1 on true) as tt
		inner join 
		(select team as team3, count as count3 from teams) as t2 on true
	)
	select team1, team2, team3, count1+count2+count3 as strength 
	from alliances1 where team1 < team2 and team2 < team3
);
 
create table alliances_and_weakest_enemies as
(
	select *,(select sum(count) from 
		(select * from teams where team != team1 and team != team2
		and team != team3 order by count limit 3) as tt)::int 
		as strength_of_weakest_enemy
		from alliances
);
 
create table t_answer as
(
	with tt as
	(
		select * from alliances_and_weakest_enemies where strength > strength_of_weakest_enemy order by strength limit 1
	)
	select distinct name from trooper,tt where 
	substring(name,1,1) = tt.team1 
	or substring(name,1,1) = tt.team2 
	or substring(name,1,1) = tt.team3 
	order by name
);
 
create function transform_answer_table_into_text() returns text
language plpgsql
as $$
declare
answer text = '';
i record;
begin
if (select count(*) from teams)::int < 6 then
	return '';
end if;
for i in (select * from t_answer order by name)
	loop
		answer = answer || i.name::text || ', ';
	end loop;
if answer = '' then 
	answer := ', '; 
end if;
return substring(answer,1,length(answer)-2);
end $$;
 
select transform_answer_table_into_text() as answer;