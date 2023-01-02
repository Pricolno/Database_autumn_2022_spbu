drop table if exists map_breed2num;
create table map_breed2num(
	breed text,
	num float
);
insert into map_breed2num values
('American', 0.5),
('British', 1),
('Munchkin', 1.5),
('Siberian', 2),
('Bengal', 3);

--select * from map_breed2num;


select * from cat;


select 	cat.name, (((cat.sex * (map_breed2num.num ^ 3) * cat.count ) +
		 (1 - cat.sex) * ((map_breed2num.num ^ 2) * cat.count)) / ((cat.age * 12) * 
		(select  count(*) from cat nested_cat 
		where nested_cat.breed = cat.breed)::float)) catGrade
from Cat
join map_breed2num on Cat.breed = map_breed2num.breed
order by catGrade desc


							  