select * from Casinos;
select * from SlotMachines;
select * from SlotMachinesOrders;

select * from SlotMachinesOrders
where slot_machine_id = 196
order by event_date;

select id::int from SlotMachines;
--select '{id: -1}::json'.form from SlotMachines;

drop function if exists next_event;
create or replace function next_event(ev text)
returns text as
$body$
begin
	if ev = 'installation' then return 'launch';
	elseif ev = 'launch' then return 'dismantling';
	elseif ev = 'dismantling' then return 'loading';
	elseif ev = 'loading' then return 'on the way';
	elseif ev ='on the way' then return 'acceptance';
	elseif ev='acceptance' then return 'installation';
	else return -1;
 	end if;

end;
$body$
language plpgsql;

drop table if exists all_chips cascade;
create temp table all_chips(
	id_slot_machine int,
	chip_sum int,
	is_valid bool
);


drop function if exists solve;
create or replace function solve()
--returns INT[] as 
returns setof all_chips as
$body$
declare 
	r SlotMachinesOrders%rowtype;
	h SlotMachinesOrders%rowtype;
	last_order INT[];
	earn_chips INT[];
	i int;
	cur_hours int;
	cur_earn_rate float;
	cur_stars int;
	last_date timestamp;
	
	
begin
	select date into last_date from (select '2022-11-03 00:00:00'::timestamp as date) as date_t;
	raise notice 'last_date=%', last_date;
	
	for i in (select id::int from SlotMachines)
	loop
		last_order := last_order || -1;
		earn_chips := earn_chips || 0;
	end loop;
	
	--last_order := array_to_json('{1,5, 99,100}'::int[]);
	--return last_order;
	--select * from Casinos;
	--select * from SlotMachines;
	--select * from SlotMachinesOrders;
	
	raise notice 'Какое-то безумие, когда это закончитcя :(';
	
	for r in 
		select * from SlotMachinesOrders 
		order by event_date 
	loop
		if last_order[r.slot_machine_id] = -1 then
			--raise note
			last_order[r.slot_machine_id] = r.id;
			continue;
		end if;
		
		if last_order[r.slot_machine_id] = -2 then
			continue;
		end if;
		
		select * into h 
		from  SlotMachinesOrders
		where SlotMachinesOrders.id = last_order[r.slot_machine_id];
		
		
		
		-- check ord condition 
		if next_event(h.event_type) <> r.event_type then 
		
			--raise notice 'assign -2 % % % ', h.event_type, r.event_type, next_event(h.event_type);
			
			last_order[r.slot_machine_id] = -2;
			continue;
		end if;
		
		--earn money in interval [launch, dismantling]
		--not forget about last launch
		if r.event_type = 'dismantling' then
			
			--raise notice 'TIME =% =% =%', h.event_date, r.event_date,  r.event_date - h.event_date;
			select (extract / 3600)::int into cur_hours from EXTRACT(epoch FROM  (r.event_date - h.event_date));

			--SELECT * into cur_hours from EXTRACT(HOUR FROM (r.event_date - h.event_date));
			
			select earning_rate into cur_earn_rate from SlotMachines 
			where SlotMachines.id = r.slot_machine_id;
			
			select stars into cur_stars from Casinos 
			where Casinos.id = r.casino_id;
			
			--raise notice 'EARN CHEEPS!= % % % % ', cur_hours, cur_earn_rate, cur_stars, cur_hours::float * cur_earn_rate * cur_stars::float;
			earn_chips[r.slot_machine_id] = earn_chips[r.slot_machine_id] + cur_hours::float * cur_earn_rate * cur_stars::float;
			
		end if;
		
		last_order[r.slot_machine_id] = r.id;
	end loop;
	
	--todo: earn last launch
	for i in (select id::int from SlotMachines)
	loop
		if last_order[i]::int = -2
			then continue;
		end if;
		
		select * into h 
		from  SlotMachinesOrders
		where SlotMachinesOrders.id = last_order[i];
		
		if not (h.event_type = 'launch') 
			then continue;
		end if;
		
		
		--raise notice 'TIME =% =% =%', h.event_date, r.event_date,  r.event_date - h.event_date;
		select (extract / 3600)::int into cur_hours from EXTRACT(epoch FROM  (last_date - h.event_date));
		
		--raise notice 'cur_hours per last_time=%', cur_hours;
		
		select earning_rate into cur_earn_rate from SlotMachines 
		where SlotMachines.id = h.slot_machine_id;
			
		select stars into cur_stars from Casinos 
		where Casinos.id = h.casino_id;
		
		earn_chips[h.slot_machine_id] = earn_chips[h.slot_machine_id] + cur_hours::float * cur_earn_rate * cur_stars::float;
		
	end loop;
		
	--prepare output 
	for i in (select id::int from SlotMachines)
	loop
		if last_order[i]::int = -2 then
			return next (i, earn_chips[i]::integer, false);
		else  
			return next (i, earn_chips[i]::integer, true);
		end if;
		
	end loop;
	
	return;

end;
$body$
language plpgsql;


select * from solve()
where is_valid
order by chip_sum desc; 


  