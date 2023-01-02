select * from TwentyOneTables ;

drop table if exists lears;
create temp table lears(
	lear varchar(1)
);
	--select ♣, ♠, ♥, ♦   
insert into lears values
('♣'), ('♠'), ('♥'), ('♦');
--select * from lears;

drop table if exists ranks;
-- 0 2..9 AJKQ
create temp table ranks(
	rank varchar(1)
);
insert into ranks values
('0'), ('2'), ('3'), ('4'), ('5'), ('6'), ('7'), ('8'), ('9'),
('A'), ('J'), ('K'), ('Q');
--select * from ranks;

-- check all ranks (is is all???)
select distinct substring(card, 2, 1) a from TwentyOneTables order by a; 

with recursive
all_table as(
	select distinct table_n from TwentyOneTables
)--select * from all_table
,all_card as(
	select concat('', lears.lear, ranks.rank) as card, all_table.table_n
	from lears  
	join ranks on True
	join all_table on True
)--select * from all_card
,check_less_card as(
	select distinct(diff.table_n) from (
		(select * from all_card) 
		except
		(select TwentyOneTables.card, TwentyOneTables.table_n  from TwentyOneTables)
	) diff
	
)--select distinct(table_n) from check_less_card
,check_dubl as(
	select  t1.table_n 
	from TwentyOneTables t1
	join TwentyOneTables t2 
	on  t1.id <> t2.id and t1.table_n = t2.table_n and t1.card = t2.card
)
,wrong_deck as(
	select * from check_less_card
	union
	select * from check_dubl
)select * from wrong_deck







