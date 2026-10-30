-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex03_multi_column_subquery | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_multi_column_subquery.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 직무별 최저 급여자';
GO
CREATE OR ALTER VIEW ans08_03_g1 (ename, job, sal) AS
SELECT e.ename, e.job, e.sal FROM emp e JOIN (SELECT job, MIN(sal) AS min_sal FROM emp GROUP BY job) m ON e.job = m.job AND e.sal = m.min_sal;
GO
CREATE OR ALTER VIEW exp08_03_g1 (ename, job, sal) AS
SELECT * FROM (VALUES (N'CLARK', N'MANAGER', 2450),
       (N'FORD', N'ANALYST', 3000),
       (N'KING', N'PRESIDENT', 5000),
       (N'MARTIN', N'SALESMAN', 1250),
       (N'SCOTT', N'ANALYST', 3000),
       (N'SMITH', N'CLERK', 800),
       (N'WARD', N'SALESMAN', 1250)) v(ename, job, sal);
GO
EXEC lab_check N'08-ex03-G1', N'ans08_03_g1', N'exp08_03_g1';
SELECT * FROM ans08_03_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 부서별 최초 입사자';
GO
CREATE OR ALTER VIEW ans08_03_g2 (deptno, ename) AS
SELECT e.deptno, e.ename FROM emp e WHERE EXISTS (SELECT 1 FROM emp x WHERE x.deptno = e.deptno GROUP BY x.deptno HAVING MIN(x.hiredate) = e.hiredate);
GO
CREATE OR ALTER VIEW exp08_03_g2 (deptno, ename) AS
SELECT * FROM (VALUES (10, N'CLARK'),
       (20, N'SMITH'),
       (30, N'ALLEN')) v(deptno, ename);
GO
EXEC lab_check N'08-ex03-G2', N'ans08_03_g2', N'exp08_03_g2';
SELECT * FROM ans08_03_g2 ORDER BY 1, 2;
GO
