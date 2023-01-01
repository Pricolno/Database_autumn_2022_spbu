drop table  if exists Team cascade; 
create table Team(
  id serial primary key,	
  title text
);

drop table if exists Pirate_Position cascade; 
create table Pirate_Position(
  id serial primary key,	
  title text
);

drop table if exists Citizen_Case cascade; 
create table Citizen_Case(
	id serial primary key,	
	name text,
	drink boolean, 
	smoke boolean, 
	married boolean,
	profession text
);

drop table if exists Share cascade; 
create table Share(
	id_team int,
	id_position int, 
	share int,
	primary key (id_team, id_position)
);

drop table if exists Progress cascade; 
create table Progress(
	id serial primary key,
	title text
);

drop table if exists Type_Missions cascade; 
create table Type_Missions(
	id serial primary key,
	title text
);

drop table if exists Pirate_Missions cascade; 
create table Pirate_Missions(
	id serial primary key,
	id_type int,
	id_progress int, 
	id_pirate_case int,
	foreign key(id_type) references Type_Missions(id),
	foreign key(id_progress) references Progress(id),
	foreign key(id_pirate_case) references Pirate_Case(id)
);
--проверка: максимум 1 задание в процессе выполнения
-- id_type = 4 <-> type=finish
CREATE UNIQUE INDEX one_mission_in_progress 
ON Pirate_Missions(id_pirate_case)
WHERE not (id_progress = 4);


drop table if exists Pirate_Case cascade; 
create table Pirate_Case(
	id serial primary key,	
	nickname text, 
	cnt_hand integer,
	reward integer,
	id_team int,
	id_position int,
	id_citizen_case int,
	FOREIGN KEY (id_team) REFERENCES Team(id),
	FOREIGN KEY (id_position) REFERENCES Pirate_Position(id), 
	FOREIGN KEY (id_citizen_case) REFERENCES Citizen_Case(id),
	FOREIGN KEY (id_team, id_position) REFERENCES Share(id_team, id_position), 
	--CHECK ((id_position <> 'юнга') or (reward is NULL) or (reward = 0))
	--  id_position = 1 <-> position = 'юнга'
	CHECK ((id_position <> 1) or (reward is NULL) or (reward = 0)) 
	 
);
--проверка: максимум один капитан на команду 
-- id_commander = 2
CREATE UNIQUE INDEX one_commander
ON Pirate_Case(id_team)
WHERE id_position = 2;


-- 
insert into Type_Missions (title) values('грабёж');
insert into Type_Missions (title) values('похищение');
insert into Type_Missions (title) values('закапывание клада');
--select * from Type_Missions;

-- 
insert into Progress (title) values('подготавливается');
insert into Progress (title) values('выполняет');
insert into Progress (title) values('бунтует');
insert into Progress (title) values('завершил');
--select * from Progress;

insert into Team (title) values('Носорог');
insert into Team (title) values('Черная жемчужина');
insert into Team (title) values('Аборигены острова');
insert into Team (title) values('Чернее чёрного');
insert into Team (title) values('7');
--select * from Team;

insert into Pirate_Position (title) values('юнга');
insert into Pirate_Position (title) values('Капитан');
insert into Pirate_Position (title) values('Боцман');
insert into Pirate_Position (title) values('Плотник');
insert into Pirate_Position (title) values('Канонир');
insert into Pirate_Position (title) values('Судовой врач');
--select * from Pirate_Position;

-- id_position = 2 <-> position commander
insert into Share (id_team, id_position, share) values(2, 1, 1);
insert into Share (id_team, id_position, share) values(2, 2, 100);
insert into Share (id_team, id_position, share) values(3, 3, 5);
insert into Share (id_team, id_position, share) values(3, 5, 10);
insert into Share (id_team, id_position, share) values(5, 1, 57);
insert into Share (id_team, id_position, share) values(1, 2, 69);
--select * from Share;

insert into Citizen_Case(name, drink, smoke, married, profession)
values('Roma', true, true, false, 'студент');

insert into Citizen_Case(name, drink, smoke, married, profession)
values('Pety', false, true, true, 'плотник');

insert into Citizen_Case(name, drink, smoke, married, profession)
values('Изабелла', true, true, false, 'красивая девочка');

insert into Citizen_Case(name, drink, smoke, married, profession)
values('Инокентий', false, false, false, 'библиотекарь');
--select * from Citizen_Case;


insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
values ('Дырявая нога', 2, 100, 3, 3, NULL);

insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
values ('Капитан Джек Воробей', 2, 500000, 2, 2, NULL);

-- нарушает ограничение уникальности "one_commander
--insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
--values ('Капитан Джек Воробей НОМЕР 2', 2, 500000, 2, 2, NULL);


insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
values ('Рома матрос', 2, NULL, 2, 1, 1);

--нарушает ограничение-проверку "pirate_case_check"
--insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
--values ('Рома матрос', 2, 70, 2, 1, 1);

insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
values ('Анна Леонхард', 2, 699, 3, 3, 3);

insert into Pirate_Case(nickname, cnt_hand, reward, id_team, id_position, id_citizen_case)
values ('Денис обыкновенный', 2, 0, 2, 1, 2);

--select * from Pirate_Case;




insert into Pirate_Missions(id_type, id_progress, id_pirate_case) 
values(1, 4, 3);
insert into Pirate_Missions(id_type, id_progress, id_pirate_case) 
values(3, 3, 2);
insert into Pirate_Missions(id_type, id_progress, id_pirate_case) 
values(3, 2, 1);
insert into Pirate_Missions(id_type, id_progress, id_pirate_case) 
values(1, 2, 5);
insert into Pirate_Missions(id_type, id_progress, id_pirate_case) 
values(3, 2, 3);
--нарушает ограничение уникальности "one_mission_in_progress"
--insert into Pirate_Missions(id_type, id_progress, id_pirate_case) 
--values(3, 3, 3);
--select * from Pirate_Missions;



