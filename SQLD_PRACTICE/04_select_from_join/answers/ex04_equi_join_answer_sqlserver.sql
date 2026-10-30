-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex04_equi_join | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_equi_join.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부산 팀 선수';
GO
CREATE OR ALTER VIEW ans04_04_g1 (player_name, team_name) AS
SELECT p.player_name, t.team_name FROM player p JOIN team t ON p.team_id = t.team_id WHERE t.region_name = N'부산';
GO
CREATE OR ALTER VIEW exp04_04_g1 (player_name, team_name) AS
SELECT * FROM (VALUES (N'권율', N'바다유나이티드'),
       (N'이순신', N'바다유나이티드')) v(player_name, team_name);
GO
EXEC lab_check N'04-ex04-G1', N'ans04_04_g1', N'exp04_04_g1';
SELECT * FROM ans04_04_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] GK 가 아닌 팀 소속 선수';
-- 연개소(MF)는 팀이 없어 EQUI JOIN 에서 빠진다.
GO
CREATE OR ALTER VIEW ans04_04_g2 (player_name, position, team_name) AS
SELECT p.player_name, p.position, t.team_name FROM player p, team t WHERE p.team_id = t.team_id AND p.position <> 'GK';
GO
CREATE OR ALTER VIEW exp04_04_g2 (player_name, position, team_name) AS
SELECT * FROM (VALUES (N'권율', N'FW', N'바다유나이티드'),
       (N'을지문', N'DF', N'하늘FC')) v(player_name, position, team_name);
GO
EXEC lab_check N'04-ex04-G2', N'ans04_04_g2', N'exp04_04_g2';
SELECT * FROM ans04_04_g2 ORDER BY 1, 2, 3;
GO
