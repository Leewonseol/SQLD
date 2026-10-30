-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex05_non_equi_join | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_non_equi_join.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 등급 4 이상 사원';
GO
CREATE OR ALTER VIEW ans04_05_g1 (ename, sal, grade) AS
SELECT e.ename, e.sal, s.grade FROM emp e JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal WHERE s.grade >= 4;
GO
CREATE OR ALTER VIEW exp04_05_g1 (ename, sal, grade) AS
SELECT * FROM (VALUES (N'BLAKE', 2850, 4),
       (N'CLARK', 2450, 4),
       (N'FORD', 3000, 4),
       (N'JONES', 2975, 4),
       (N'KING', 5000, 5),
       (N'SCOTT', 3000, 4)) v(ename, sal, grade);
GO
EXEC lab_check N'04-ex05-G1', N'ans04_05_g1', N'exp04_05_g1';
SELECT * FROM ans04_05_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 등급별 사원 수';
-- 합계 3+3+2+5+1 = 14 = EMP 전체 행 수. 구간에 틈·겹침이 없다는 뜻이다.
GO
CREATE OR ALTER VIEW ans04_05_g2 (grade, cnt) AS
SELECT s.grade, COUNT(*) FROM emp e, salgrade s WHERE e.sal BETWEEN s.losal AND s.hisal GROUP BY s.grade;
GO
CREATE OR ALTER VIEW exp04_05_g2 (grade, cnt) AS
SELECT * FROM (VALUES (1, 3),
       (2, 3),
       (3, 2),
       (4, 5),
       (5, 1)) v(grade, cnt);
GO
EXEC lab_check N'04-ex05-G2', N'ans04_05_g2', N'exp04_05_g2';
SELECT * FROM ans04_05_g2 ORDER BY 1, 2;
GO
