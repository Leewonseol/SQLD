-- ex04 EQUI JOIN  | SQL Server
PRINT N'== [Q1] WHERE 절 조인 (SQL Server 도 지원)';
SELECT p.player_name 선수명, p.back_no 등번호, t.team_name 팀명
FROM player p, team t
WHERE p.team_id = t.team_id
  AND p.position = 'GK'
ORDER BY p.back_no;
PRINT N'== [Q2] ANSI INNER JOIN ... ON';
SELECT p.player_name 선수명, p.back_no 등번호, t.team_name 팀명
FROM player p
INNER JOIN team t ON p.team_id = t.team_id
WHERE p.position = 'GK'
ORDER BY p.back_no;
PRINT N'== [Q3] 전체 선수-팀';
SELECT p.player_name, p.team_id, t.team_name, t.region_name
FROM player p JOIN team t ON p.team_id = t.team_id
ORDER BY p.player_id;
GO
PRINT N'== [Q4] 별칭을 준 뒤 원래 테이블명 참조 -> 오류';
GO
-- @expect-error: MSG-4104
SELECT player.player_name, t.team_name FROM player p, team t WHERE p.team_id = t.team_id;
GO
PRINT N'== [Q5] 모호한 컬럼명 -> 오류';
GO
-- @expect-error: MSG-209
SELECT team_id FROM player p JOIN team t ON p.team_id = t.team_id;
GO
PRINT N'== [Q6] INNER JOIN 에서 ON 생략 -> 오류';
GO
-- @expect-error: MSG-102
SELECT p.player_name FROM player p INNER JOIN team t;
GO
