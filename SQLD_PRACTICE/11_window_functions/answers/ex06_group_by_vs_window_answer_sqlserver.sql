-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex06_group_by_vs_window | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_group_by_vs_window.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부서 평균보다 많은 급여(윈도우)';
GO
CREATE OR ALTER VIEW ans11_06_g1 (deptno, ename, sal) AS
SELECT deptno, ename, sal FROM (SELECT deptno, ename, sal, AVG(sal) OVER (PARTITION BY deptno) a FROM emp) t WHERE sal > a;
GO
CREATE OR ALTER VIEW exp11_06_g1 (deptno, ename, sal) AS
SELECT * FROM (VALUES (10, N'KING', 5000),
       (20, N'FORD', 3000),
       (20, N'JONES', 2975),
       (20, N'SCOTT', 3000),
       (30, N'ALLEN', 1600),
       (30, N'BLAKE', 2850)) v(deptno, ename, sal);
GO
EXEC lab_check N'11-ex06-G1', N'ans11_06_g1', N'exp11_06_g1';
SELECT * FROM ans11_06_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 부서 합계와 전체 대비 비율';
GO
CREATE OR ALTER VIEW ans11_06_g2 (deptno, dept_sum, pct) AS
SELECT deptno, SUM(sal), ROUND(SUM(sal) * 100 / SUM(SUM(sal)) OVER (), 1) FROM emp GROUP BY deptno;
GO
CREATE OR ALTER VIEW exp11_06_g2 (deptno, dept_sum, pct) AS
SELECT * FROM (VALUES (10, 8750, 30.1),
       (20, 10875, 37.5),
       (30, 9400, 32.4)) v(deptno, dept_sum, pct);
GO
EXEC lab_check N'11-ex06-G2', N'ans11_06_g2', N'exp11_06_g2';
SELECT * FROM ans11_06_g2 ORDER BY 1, 2, 3;
GO
