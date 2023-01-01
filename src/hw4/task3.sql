drop table if exists scores;
create table scores (
	title text,
	score int,
	rev bool
);
insert into scores values
('w1', 3, false),
('w2', 0, false),
('dr', 1, false),
('w1', 0, true),
('w2', 3, true),
('dr', 1, true);


select team, sum(all_score_one_direct) all_score  from
(select team1 team, sum(score) all_score_one_direct
from football_teams ft
join scores on scores.title = ft.result and not scores.rev
group by team1
union all
select team2 team, sum(score) all_score_one_direct
from football_teams ft
join scores on scores.title = ft.result and scores.rev
group by team2) Team_Scores
group by team 
order by all_score desc
limit 3
