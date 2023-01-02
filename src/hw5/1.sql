select  breed, avg(milk_per_second) average_milk_per_second from Cow
group by breed
having count(name) > 3


