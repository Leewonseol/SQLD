-- ex06 3개 이상 테이블 조인 (PDF E-11)  | Oracle   데이터: [가상]
PROMPT == [Q1] 3개 테이블 = 조인 조건 최소 2개 (Oracle WHERE 방식)
SELECT p.player_name, p.position, t.region_name, t.team_name, s.stadium_name
FROM player p, team t, stadium s
WHERE p.team_id = t.team_id
  AND t.stadium_id = s.stadium_id
ORDER BY p.player_id;

PROMPT == [Q2] ANSI 방식
SELECT p.player_name, p.position, t.region_name, t.team_name, s.stadium_name
FROM player p
INNER JOIN team t    ON p.team_id = t.team_id
INNER JOIN stadium s ON t.stadium_id = s.stadium_id
ORDER BY p.player_id;

PROMPT == [Q3] 조인 조건 하나를 빠뜨리면: player-team 은 조인되지만 stadium 과는 카티션 곱 (선수-팀 5행 x 경기장 3 = 15행)
SELECT COUNT(*) AS rows_missing_condition
FROM player p, team t, stadium s
WHERE p.team_id = t.team_id;

PROMPT == [Q4] 모든 선수를 남기려면 LEFT JOIN 을 연쇄해야 한다
SELECT p.player_name, t.team_name, s.stadium_name
FROM player p
LEFT JOIN team t    ON p.team_id = t.team_id
LEFT JOIN stadium s ON t.stadium_id = s.stadium_id
ORDER BY p.player_id;
