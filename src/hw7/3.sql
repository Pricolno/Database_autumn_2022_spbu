select * from TwentyOneTables ;

drop table if exists weigth;
create temp table weigth(
	rank varchar(2),
	val float
);

insert into weigth values
('A', -1), ('J', -1), ('K', -1), ('Q', -1),
('3', 1), ('4', 1), ('6', 1), 
('5', 1.5),
('9', -0.5),
('0', -1),
('2', 0.5), ('7', 0.5),
('8', 0);

--select * from weigth;

select max(max_counter) as max_counter_for_all_table
from
(select t_cumsum_val.table_n, max(t_cumsum_val.cumsum_val) as max_counter from 
(select 
	id,
	table_n,
	sum(val) over(partition by table_n order by id) as cumsum_val
from TwentyOneTables
join weigth on substring(TwentyOneTables.card, 2, 1) = weigth.rank) t_cumsum_val
group by table_n) max_counter_on_table








