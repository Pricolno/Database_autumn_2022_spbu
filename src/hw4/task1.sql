drop table if exists numbers;
create table numbers(
	num int
);

drop table if exists tatoos;
create table tatoos(
	num int
);

INSERT INTO numbers values
  (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11);
  
INSERT INTO tatoos values
  (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11);
  
SELECT numbers.num , tatoos.num as tatoo, numbers.num * tatoos.num as score 
from numbers
join tatoos on True;