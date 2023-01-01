-- Задание 4

drop table if exists Working_Shift;
create table Working_Shift(
	hour int
);
insert into Working_Shift values
(9), (10), (11), (12), (13), (14), (15),
(16), (17), (18), (19), (20), (21), (22), (23);

select (hour || ':00' || ' - ' ||  (hour + 1) || ':00') as busiest_work_shift, cnt_visits  
from
(select hour, count(*) cnt_visits from 
(select  extract(hour from arrival_date) h_start,   
extract(hour from leaving_date) h_finish
from football_watch) Intervals
join Working_Shift on
Intervals.h_start <= Working_Shift.hour and Working_Shift.hour <= Intervals.h_finish
group by hour 
order by cnt_visits desc
limit 1) hour_cntVisits


