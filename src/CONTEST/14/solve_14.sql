Решение задачи 14. Программа состоит из функции и процедуры.
 
Функция image_to_strings получает на вход имя таблицы-картинки с точками (x,y), и возвращает таблицу строк кода на Pikeman.
Идея в том, что в картинке каждый символ находится в квадратике 5*5, и квадратики отделены друг от друга двумя рядами пустых пикселей.
Поэтому верхние левые углы квадратиков имеют координаты (0,0),(0,7),(7,0),(0,14),(7,7),(14,0),... Я перебираю в двух циклах
координаты левого верхнего угла квадрата, для каждого квадрата вычисляю код из 25 нулей и единиц (закрашен пиксель в квадрате 5*5 или нет),
а затем смотрю какой букве он соответствует в таблице кодов и букв. Из букв в квадратах строк составляются строки с кодом для ответа.
В таблице codes записано, какие коды соответствуют каким буквам. Я составляла эту таблицу не вручную, а напечатав коды для все букв
из первой строки первого датасета, а потом скопировав в программу.
 
Процедура Halberdier получает на вход имя таблицы в виде строки.
Затем она вызывает image_to_strings и получает список строк с кодом.
Дальше этот код преобразуется в более удобный формат: первым проходом я удаляю комментарии и сшиваю код в одну строку,
при этом между строками добавляю пробелы, чтобы ничего не склеилось.
Следующим проходом я убираю пробелы и ставлю ; после каждой операции присвоения, так что ничего не склеивается.
 
В таблице vars хранятся названия и значения переменных.
 
Строка с кодом читается посимвольно, в var хранится текущее слово или число, в sign - знак слагаемого:
0, если текущее слово не после '=','+','-', то есть не слагаемое; 1, если перед текущим слагаемым стоит знак '+', и -1 если стоит '-'.
Если встречается '(', то текущее слово - это print, его можно сбросить; если ')', то надо вывести значение текущей переменной.
Оно печатается с помощью raise notice.
Буквы или цифры записываются в var.
Если встречается '=', то имя переменной запоминается в target_var, а в переменной new_val накапливается результат арифметического выражения.
Если '+','-', то текущую переменную, если есть, надо добавить к new_val с правильным знаком, возможно, изменить знак.
Если ';', то арифметическое выражение закончилось, в этот момент знак становится 0, переменная в vars с именем target_val получает значение new_val.
 
В конце кода вызов процедуры Halberdier для таблицы python_image. Код работает меньше секунды и выдаёт в messanges:
ЗАМЕЧАНИЕ:  17
ЗАМЕЧАНИЕ:  1
ЗАМЕЧАНИЕ:  -103
CALL
 
Query returned successfully in 1 secs 512 msec.
 
Это соответствует ответу 17;1;-103 для бота.
Выводить ответ в messanges через строчки raise notice было разрешено.
 
Вот код:
 
drop function if exists image_to_strings;
create function image_to_strings(table_name_ text) returns table(num_str int, str text)
language plpgsql
as $$
declare
	xmax int;
	ymax int;
	s text;
	code text;
begin
	create table ans
	(
		num_str int, 
		str text
	);
	create table codes as
	(
		select * from (values
		('#', '0101011111010101111101010'),
		('0', '0111001010010100101001110'),
		('1', '0010001100101000010001110'),
		('2', '0011001001000100010001111'),
		('3', '0011001001000100100100110'),
		('4', '0101001010011100001000010'),
		('5', '0111001000011100001001110'),
		('6', '0111001000011100101001110'),
		('7', '0111000010001110001000010'),
		('8', '0111001010011100101001110'),
		('9', '0111001010011100001001110'),
		('A', '0111001010011100101001010'),
		('B', '0110001010011000101001100'),
		('C', '0111001010010000101001110'),
		('I', '0111000100001000010001110'),
		('R', '0111001010011100110001010'),
		('P', '0111001010011100100001000'),
		('Y', '1000101010001000010000100'),
		('T', '0111000100001000010000100'),
		('H', '0101001010011100101001010'),
		('O', '0111010001100011000101110'),
		('N', '1000111001101011001110001'),
		('(', '0000100010000100001000001'),
		(')', '1000001000010000100010000'),
		('=', '0000001110000000111000000'),
		('+', '0000000100011100010000000'),
		('-', '0000000000011100000000000'),
		(' ', '0000000000000000000000000')) as tt(letter, code_of_letter)
	);
	execute 'select (select max(x) from '|| table_name_||')::int' into xmax;
	execute 'select (select max(y) from '|| table_name_||')::int' into ymax;
	for y1 in 0..ymax by 7
	loop
		s = '';
		for x1 in 0..xmax by 7
		loop
			execute 'create table cell as(select x-'||x1||' as x, y-'||y1||' as y from ' ||table_name_
				||' where x >= '||x1||' and x <= '||x1||'+4 and y >= '||y1||' and y <= '||y1||' +4);';
			code = '';
			for y2 in 0..4
			loop
				for x2 in 0..4
				loop
					if (select count(*) from cell where x = x2 and y = y2)::int = 1 then
						code = code||'1';
					else
						code = code||'0';
					end if;
				end loop;
			end loop;
			drop table cell;
			s = s||(select letter from codes where code_of_letter = code)::text;
		end loop;
		insert into ans values (((y1-y1%7)/7)::int, s);
	end loop;
	drop table codes;
	return query select * from ans;
	drop table ans;
end $$;
 
--select * from image_to_strings('python_image')
 
drop procedure if exists Halberdier;
create procedure Halberdier(table_name_ text)
language plpgsql
as $$
declare
	i record;
	l int;
	--j int;
	b varchar;
	sign bigint;
	s_prog text;
	prog varchar[];
	s varchar[];
	var text;
	target_var text;
	new_val bigint;
begin
	create table strs_prog as
	(
		select * from image_to_strings(table_name_)
	);
	create table vars
	(
		name text primary key,
		val bigint
	);
	s_prog = '';
	for i in (select * from strs_prog order by num_str)
	loop
		s = string_to_array(i.str,null);
		for j in 1..length(i.str)
		loop
			if s[j] = '#' then exit; end if;
			s_prog = s_prog||s[j];
			if s[j] similar to '0|1|2|3|4|5|6|7|8|9' and j+1<= length(i.str) and s[j+1] similar to 'A|B|C|I|R|P|Y|T|H|O|N' then
				s_prog = s_prog||' ';
			end if;
		end loop;
		s_prog = s_prog||' ';
	end loop;
	s = string_to_array(s_prog,null);
	l = length(s_prog);
	s_prog = '';
	b = ';';
	--raise notice '%',s_prog;
	for j in 1..l	
	loop
		if s[j] similar to 'A|B|C|I|R|P|Y|T|H|O|N' and 
		((b similar to 'A|B|C|I|R|P|Y|T|H|O|N' and s[j-1] = ' ') or
		b similar to '0|1|2|3|4|5|6|7|8|9') then
			s_prog = s_prog||';';
			b = ';';
		end if;
		if s[j] != ' ' then 
			s_prog = s_prog||s[j]; 
			b = s[j];
		end if;
	end loop;
	if length(s_prog) > 0 and substring(s_prog,length(s_prog),1) 
	similar to 'A|B|C|I|R|P|Y|T|H|O|N|0|1|2|3|4|5|6|7|8|9' then
		s_prog = s_prog||';';
	end if;
	--raise notice '%',s_prog;
	prog = string_to_array(s_prog,null);
	var = '';
	sign = 0;
	for j in 1..length(s_prog)
	loop
		case
			when prog[j] = '(' then var = '';
			when prog[j] = ')' then 
				raise notice '%',(select val from vars where name = var)::bigint;
				var = '';
			when prog[j] = '=' then
				target_var = var;
				new_val = 0;
				var = '';
				sign = 1;
			when prog[j] = '+' or prog[j] ='-' or prog[j] = ';' then
				if length(var) > 0 then
					if substring(var,1,1) similar to '0|1|2|3|4|5|6|7|8|9' then
						new_val = new_val+(var::bigint)*sign;
					else
						new_val = new_val+(select val from vars where name = var)::bigint*sign;
					end if;
					sign = 1;
				end if;
				var = '';
				if prog[j] = '-' then sign = -sign; end if;
				if prog[j] = ';' then 
					sign = 0; 
					insert into vars values (target_var,new_val) on conflict(name) do update set val = new_val;
				end if;
			else
				var = var||prog[j];
		end case;
	end loop;
 
	drop table vars;
	drop table strs_prog;
end $$;
 
call Halberdier('python_image');