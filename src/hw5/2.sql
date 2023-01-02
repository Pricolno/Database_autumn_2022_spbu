--select * from Dog;

select * from generate_series(1, 
							  (select (count(*) + 1)::int count_dog from Dog),
							  1) ser(i)
where NOT EXISTS(select 1 from Dog 
				where ser.i = Dog.name)
							  