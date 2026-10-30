-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex01_single_row_subquery | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_single_row_subquery.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 가장 늦게 입사한 사원과 같은 부서';
-- 가장 늦은 입사일(1987-05-23 ADAMS)이 동점이면 바깥 = 가 ORA-01427/Msg 512 로 실패한다. 안전하게 하려면 deptno IN (...).
GO
CREATE OR ALTER VIEW ans08_01_g1 (ename) AS
SELECT ename FROM emp WHERE deptno = (SELECT deptno FROM emp WHERE hiredate = (SELECT MAX(hiredate) FROM emp));
GO
CREATE OR ALTER VIEW exp08_01_g1 (ename) AS
SELECT * FROM (VALUES (N'ADAMS'),
       (N'FORD'),
       (N'JONES'),
       (N'SCOTT'),
       (N'SMITH')) v(ename);
GO
EXEC lab_check N'08-ex01-G1', N'ans08_01_g1', N'exp08_01_g1';
SELECT * FROM ans08_01_g1 ORDER BY 1;
GO

PRINT N'== [G2] SMITH 와 같은 직무, 급여가 더 많은 사원';
GO
CREATE OR ALTER VIEW ans08_01_g2 (ename, sal) AS
SELECT ename, sal FROM emp WHERE job = (SELECT job FROM emp WHERE ename = 'SMITH') AND sal > (SELECT sal FROM emp WHERE ename = 'SMITH');
GO
CREATE OR ALTER VIEW exp08_01_g2 (ename, sal) AS
SELECT * FROM (VALUES (N'ADAMS', 1100),
       (N'JAMES', 950),
       (N'MILLER', 1300)) v(ename, sal);
GO
EXEC lab_check N'08-ex01-G2', N'ans08_01_g2', N'exp08_01_g2';
SELECT * FROM ans08_01_g2 ORDER BY 1, 2;
GO
