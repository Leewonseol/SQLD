-- ex06 3개 이상 테이블 조인 (PDF E-11)  | SQL Server
PRINT N'== [Q1] WHERE 방식';
SELECT p.player_name, p.position, t.region_name, t.team_name, s.stadium_name
FROM player p, team t, stadium s
WHERE p.team_id = t.team_id
  AND t.stadium_id = s.stadium_id
ORDER BY p.player_id;
PRINT N'== [Q2] ANSI 방식';
SELECT p.player_name, p.position, t.region_name, t.team_name, s.stadium_name
FROM player p
INNER JOIN team t    ON p.team_id = t.team_id
INNER JOIN stadium s ON t.stadium_id = s.stadium_id
ORDER BY p.player_id;
PRINT N'== [Q3] 조인 조건 하나 누락';
SELECT COUNT(*) AS rows_missing_condition
FROM player p, team t, stadium s
WHERE p.team_id = t.team_id;
PRINT N'== [Q4] LEFT JOIN 연쇄';
SELECT p.player_name, t.team_name, s.stadium_name
FROM player p
LEFT JOIN team t    ON p.team_id = t.team_id
LEFT JOIN stadium s ON t.stadium_id = s.stadium_id
ORDER BY p.player_id;
