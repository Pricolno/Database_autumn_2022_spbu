--select * from Horse;

--select * from Horse_type;


select h0.name, h1.name from Horse h0
join Horse h1 on 
h0.sex = 'male' 
and h1.sex = 'female' 
and abs(h0.age - h1.age) <= 2
and 
-- same breed
(
	(substring(h0.code from 1 for 3) = substring(h1.code from 1 for 3))
or
-- dog and abc is same color
	(substring(h0.code from 1 for 3) = 'dog' and substring(h1.code from 1 for 3) = 'abc' 
	and h0.color = h1.color) 	
or
	(substring(h1.code from 1 for 3) = 'dog' and substring(h0.code from 1 for 3) = 'abc'
	and h0.color = h1.color)
-- abc and dnd is delta_height <= 20
or
	(substring(h0.code from 1 for 3) = 'abc' and substring(h1.code from 1 for 3) = 'dnd' 
	 and abs(h0.height - h1.height) <= 20)
or 
	(substring(h1.code from 1 for 3) = 'abc' and substring(h0.code from 1 for 3) = 'dnd' 
	 and abs(h0.height - h1.height) <= 20)
)





