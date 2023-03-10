drop table if exists football_teams;

create table football_teams (
	team1 text,
	team2 text,
	result varchar(2)
);

insert into football_teams values
('Локомотив','ЦСКА','w2'),
('Крылья Советов','Ростов','w1'),
('Крылья Советов','Ахмат','w2'),
('Ахмат','Зенит','dr'),
('Сочи','ЦСКА','w2'),
('ЦСКА','Урал','dr'),
('Спартак','Ростов','dr'),
('ЦСКА','Торпедо','dr'),
('Локомотив','Крылья Советов','w2'),
('Динамо','ЦСКА','dr'),
('Нижний Новгород','Ахмат','dr'),
('Ахмат','Спартак','dr'),
('Спартак','Сочи','w2'),
('Крылья Советов','Урал','dr'),
('Динамо','Ростов','w2'),
('ЦСКА','Нижний Новгород','w1'),
('Факел','Торпедо','w1'),
('Химки','Нижний Новгород','dr'),
('Нижний Новгород','Спартак','w1'),
('Нижний Новгород','Оренбург','w2'),
('Нижний Новгород','Сочи','dr'),
('ЦСКА','Сочи','w1'),
('ЦСКА','Ростов','w1'),
('Торпедо','Зенит','dr'),
('Урал','ЦСКА','w1'),
('Зенит','Спартак','dr'),
('Крылья Советов','Спартак','dr'),
('Ахмат','Факел','dr'),
('Химки','Зенит','w2'),
('Динамо','Зенит','w1'),
('Факел','Нижний Новгород','dr'),
('Зенит','Сочи','w1'),
('Нижний Новгород','Зенит','w2'),
('Торпедо','Ростов','dr'),
('Торпедо','Оренбург','w2'),
('Факел','Урал','dr'),
('Факел','Спартак','w1'),
('Локомотив','Динамо','dr'),
('Оренбург','Торпедо','w2'),
('Урал','Факел','w1'),
('Сочи','Торпедо','w1'),
('Урал','Химки','w2'),
('Спартак','Факел','dr'),
('Ахмат','Урал','dr'),
('Факел','Ростов','w1'),
('Динамо','Торпедо','w2'),
('Нижний Новгород','Химки','w1'),
('Химки','Оренбург','w2'),
('Оренбург','Ростов','w2'),
('Химки','Торпедо','w1'),
('Краснодар','Спартак','w1'),
('Спартак','Крылья Советов','w1'),
('Спартак','Локомотив','w2'),
('Оренбург','Локомотив','dr'),
('Оренбург','Химки','w2'),
('Сочи','Крылья Советов','w1'),
('Торпедо','Ахмат','w1'),
('Зенит','Ахмат','dr'),
('Спартак','Краснодар','w2'),
('Химки','Сочи','w2'),
('Локомотив','Ростов','dr'),
('Ростов','Химки','w2'),
('ЦСКА','Ахмат','w1'),
('Оренбург','Динамо','w2'),
('Динамо','Урал','w2'),
('Ростов','ЦСКА','w1'),
('Краснодар','Химки','dr'),
('Локомотив','Спартак','dr'),
('Зенит','Урал','w2'),
('Зенит','Оренбург','w2'),
('Урал','Краснодар','w1'),
('Спартак','Динамо','w2'),
('ЦСКА','Факел','w1'),
('Факел','Локомотив','dr'),
('Краснодар','ЦСКА','w2'),
('Оренбург','ЦСКА','dr'),
('Торпедо','Локомотив','w1'),
('Спартак','Нижний Новгород','w2'),
('Ростов','Локомотив','w1'),
('Торпедо','Урал','w1'),
('ЦСКА','Краснодар','w1'),
('Химки','Локомотив','dr'),
('Сочи','Нижний Новгород','w1'),
('Химки','Динамо','dr'),
('Торпедо','Спартак','w2'),
('Крылья Советов','Локомотив','w2'),
('Ахмат','Ростов','dr'),
('Крылья Советов','Торпедо','w1'),
('Факел','Оренбург','w2'),
('Урал','Нижний Новгород','w2'),
('ЦСКА','Химки','dr'),
('Локомотив','Ахмат','dr'),
('Локомотив','Урал','dr'),
('Нижний Новгород','Урал','dr'),
('Краснодар','Сочи','w2'),
('Сочи','Локомотив','w1'),
('Урал','Торпедо','dr'),
('Локомотив','Зенит','w2'),
('Динамо','Сочи','w1'),
('Сочи','Оренбург','w1'),
('Факел','Химки','w1'),
('Краснодар','Ростов','w1'),
('Крылья Советов','Динамо','dr'),
('Сочи','Факел','w1'),
('Сочи','Зенит','w2'),
('Ростов','Факел','w1'),
('Торпедо','Динамо','w1'),
('Нижний Новгород','Динамо','w2'),
('Спартак','Оренбург','w2'),
('Торпедо','Крылья Советов','w2'),
('Оренбург','Нижний Новгород','w2'),
('Ростов','Нижний Новгород','w1'),
('Сочи','Химки','w1'),
('Спартак','ЦСКА','dr'),
('Крылья Советов','Факел','w1'),
('Урал','Ахмат','w1'),
('Динамо','Локомотив','w1'),
('Зенит','ЦСКА','dr'),
('Зенит','Нижний Новгород','dr'),
('Ахмат','Нижний Новгород','w1'),
('Факел','Краснодар','w2'),
('Факел','Крылья Советов','w1'),
('Ростов','Сочи','w2'),
('Краснодар','Оренбург','w1'),
('Ахмат','Динамо','w1'),
('Сочи','Урал','dr'),
('Локомотив','Краснодар','w2'),
('Ростов','Крылья Советов','w2'),
('Краснодар','Торпедо','dr'),
('Спартак','Зенит','w1'),
('Спартак','Ахмат','w1'),
('Ахмат','ЦСКА','dr'),
('Сочи','Динамо','w2'),
('Сочи','Краснодар','dr'),
('ЦСКА','Спартак','w2'),
('Нижний Новгород','Краснодар','w2'),
('Зенит','Торпедо','w1'),
('Крылья Советов','Зенит','w1'),
('Нижний Новгород','Торпедо','dr'),
('Факел','ЦСКА','dr'),
('Торпедо','Химки','w1'),
('Ахмат','Химки','w2'),
('Урал','Локомотив','dr'),
('Оренбург','Сочи','dr'),
('Зенит','Ростов','w1'),
('Динамо','Крылья Советов','w1'),
('Оренбург','Спартак','w2'),
('Локомотив','Оренбург','w1'),
('Спартак','Урал','w1'),
('Краснодар','Ахмат','dr'),
('Ростов','Ахмат','w2'),
('Урал','Динамо','dr'),
('Крылья Советов','Краснодар','dr'),
('Динамо','Краснодар','dr'),
('Зенит','Динамо','w2'),
('Спартак','Торпедо','w1'),
('Оренбург','Факел','dr'),
('Ростов','Динамо','w1'),
('Нижний Новгород','Ростов','w2'),
('Краснодар','Локомотив','dr'),
('Химки','Ростов','dr'),
('Динамо','Факел','w1'),
('Химки','Факел','dr'),
('Факел','Сочи','w1'),
('Крылья Советов','Нижний Новгород','w1'),
('Оренбург','Урал','w2'),
('Зенит','Локомотив','w1'),
('Оренбург','Ахмат','dr'),
('Факел','Ахмат','w1'),
('Ахмат','Локомотив','w1'),
('ЦСКА','Оренбург','dr'),
('Ростов','Оренбург','w1'),
('Крылья Советов','Сочи','w2'),
('Химки','Ахмат','dr'),
('Зенит','Факел','dr'),
('Ахмат','Сочи','w2'),
('Ахмат','Оренбург','w2'),
('Локомотив','Химки','w1'),
('Краснодар','Крылья Советов','dr'),
('Ростов','Зенит','dr'),
('Нижний Новгород','ЦСКА','dr'),
('Нижний Новгород','Факел','w2'),
('Нижний Новгород','Крылья Советов','dr'),
('Динамо','Химки','w1'),
('Динамо','Нижний Новгород','w2'),
('Торпедо','Факел','w2'),
('Зенит','Химки','w1'),
('Химки','Крылья Советов','w1'),
('Химки','Урал','w2'),
('Нижний Новгород','Локомотив','w1'),
('Химки','Краснодар','w1'),
('ЦСКА','Крылья Советов','w2'),
('Краснодар','Зенит','dr'),
('Динамо','Оренбург','w2'),
('Факел','Зенит','w2'),
('Урал','Зенит','w1'),
('Сочи','Спартак','w2'),
('Ахмат','Крылья Советов','w1'),
('Крылья Советов','Химки','w1'),
('Урал','Сочи','w1'),
('Зенит','Краснодар','w1'),
('Краснодар','Нижний Новгород','w2'),
('Сочи','Ростов','w1'),
('ЦСКА','Локомотив','w1'),
('ЦСКА','Динамо','w2'),
('Оренбург','Зенит','dr'),
('Локомотив','Торпедо','w1'),
('Крылья Советов','ЦСКА','dr'),
('Ахмат','Торпедо','w2'),
('Локомотив','Факел','w2'),
('Локомотив','Сочи','dr'),
('Крылья Советов','Оренбург','dr'),
('ЦСКА','Зенит','w2'),
('Локомотив','Нижний Новгород','w2'),
('Ростов','Краснодар','w1'),
('Ростов','Урал','w2'),
('Краснодар','Динамо','dr'),
('Оренбург','Краснодар','dr'),
('Краснодар','Урал','dr'),
('Урал','Оренбург','w2'),
('Торпедо','Сочи','dr'),
('Урал','Спартак','w1'),
('Зенит','Крылья Советов','dr'),
('Спартак','Химки','w1'),
('Ахмат','Краснодар','dr'),
('Оренбург','Крылья Советов','w1'),
('Динамо','Спартак','w1'),
('Урал','Крылья Советов','w1'),
('Динамо','Ахмат','w2'),
('Ростов','Спартак','w2'),
('Торпедо','ЦСКА','w1'),
('Ростов','Торпедо','w2'),
('Факел','Динамо','w1'),
('Урал','Ростов','w2'),
('Химки','Спартак','w2'),
('Краснодар','Факел','w1'),
('Торпедо','Краснодар','w1'),
('Химки','ЦСКА','dr'),
('Торпедо','Нижний Новгород','dr'),
('Сочи','Ахмат','w1');