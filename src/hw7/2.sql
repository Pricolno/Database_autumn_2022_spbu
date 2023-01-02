--select * from PokerEvent;
--select * from Bets;


drop table if exists all_info cascade;
create temp table all_info as
with start_value as(
	select distinct(executor),
		-1 as id,
		'start' as event_type,
		1000 as value
	from PokerEvent
) --select * from start_value
,t as(
	((select PokerEvent.executor ,PokerEvent.id, event_type, Bets.value
	from PokerEvent
	left join Bets on Bets.poker_event_id = PokerEvent.id)
	union 
	(select * from start_value)) 
) select * from t
order by t.id;

select * from all_info;

drop function if exists put_win_value;
CREATE OR REPLACE FUNCTION put_win_value() 
RETURNS SETOF all_info AS
$BODY$
DECLARE
	r all_info%rowtype;
	pref_sum int := 0;
BEGIN
	for r in 
		select * from all_info
	loop 
		if r.event_type = 'bet' then 
			pref_sum := pref_sum + r.value;
			r.value := -r.value;
		elsif r.event_type = 'win' then
			r.value := pref_sum;
			pref_sum := 0;
		--elsif r.event_type = 'start' then
			
		end if;
		
		return next r;
	end loop;
	
	return;
END;
$BODY$
LANGUAGE plpgsql;



SELECT executor, sum(value) as capital FROM put_win_value()
group by executor  
order by capital desc
limit 1
