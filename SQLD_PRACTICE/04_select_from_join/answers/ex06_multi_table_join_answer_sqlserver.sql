-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex06_multi_table_join | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_multi_table_join.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 팀별 경기장·선수 수';
-- 경기장이 없는 숲시티를 남기려면 stadium 쪽도 LEFT JOIN. COUNT(*) 를 쓰면 선수 0명 팀이 1로 세어진다(이 데이터에는 0명 팀이 없다).
GO
CREATE OR ALTER VIEW ans04_06_g1 (team_name, stadium_name, player_cnt) AS
SELECT t.team_name, s.stadium_name, COUNT(p.player_id)
FROM team t LEFT JOIN stadium s ON t.stadium_id = s.stadium_id
            LEFT JOIN player p ON p.team_id = t.team_id
GROUP BY t.team_name, s.stadium_name;
GO
CREATE OR ALTER VIEW exp04_06_g1 (team_name, stadium_name, player_cnt) AS
SELECT * FROM (VALUES (N'바다유나이티드', N'바다경기장', 2),
       (N'숲시티', NULL, 1),
       (N'하늘FC', N'하늘경기장', 2)) v(team_name, stadium_name, player_cnt);
GO
EXEC lab_check N'04-ex06-G1', N'ans04_06_g1', N'exp04_06_g1';
SELECT * FROM ans04_06_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 10번 부서 부서명·사원·등급';
-- EQUI 조건 1개 + NON EQUI 조건 1개 = 조인 조건 2개(테이블 3개).
GO
CREATE OR ALTER VIEW ans04_06_g2 (dname, ename, grade) AS
SELECT d.dname, e.ename, s.grade FROM emp e, dept d, salgrade s
WHERE e.deptno = d.deptno AND e.sal BETWEEN s.losal AND s.hisal AND e.deptno = 10;
GO
CREATE OR ALTER VIEW exp04_06_g2 (dname, ename, grade) AS
SELECT * FROM (VALUES (N'ACCOUNTING', N'CLARK', 4),
       (N'ACCOUNTING', N'KING', 5),
       (N'ACCOUNTING', N'MILLER', 2)) v(dname, ename, grade);
GO
EXEC lab_check N'04-ex06-G2', N'ans04_06_g2', N'exp04_06_g2';
SELECT * FROM ans04_06_g2 ORDER BY 1, 2, 3;
GO
