-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex04_correlated_subquery | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_correlated_subquery.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 자기 직무 평균보다 적은 급여';
GO
CREATE OR ALTER VIEW ans08_04_g1 (ename, job, sal) AS
SELECT e.ename, e.job, e.sal FROM emp e WHERE e.sal < (SELECT AVG(x.sal) FROM emp x WHERE x.job = e.job);
GO
CREATE OR ALTER VIEW exp08_04_g1 (ename, job, sal) AS
SELECT * FROM (VALUES (N'CLARK', N'MANAGER', 2450),
       (N'JAMES', N'CLERK', 950),
       (N'MARTIN', N'SALESMAN', 1250),
       (N'SMITH', N'CLERK', 800),
       (N'WARD', N'SALESMAN', 1250)) v(ename, job, sal);
GO
EXEC lab_check N'08-ex04-G1', N'ans08_04_g1', N'exp08_04_g1';
SELECT * FROM ans08_04_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 부서별 상위 2명(연관 서브쿼리)';
-- 20번 부서: SCOTT·FORD 동점 3000 은 '더 높은 사람 0명'. JONES 2975 는 2명이라 빠진다. RANK() <= 2 와 같은 결과(11단원).
GO
CREATE OR ALTER VIEW ans08_04_g2 (deptno, ename) AS
SELECT e.deptno, e.ename FROM emp e WHERE (SELECT COUNT(*) FROM emp x WHERE x.deptno = e.deptno AND x.sal > e.sal) < 2;
GO
CREATE OR ALTER VIEW exp08_04_g2 (deptno, ename) AS
SELECT * FROM (VALUES (10, N'CLARK'),
       (10, N'KING'),
       (20, N'FORD'),
       (20, N'SCOTT'),
       (30, N'ALLEN'),
       (30, N'BLAKE')) v(deptno, ename);
GO
EXEC lab_check N'08-ex04-G2', N'ans08_04_g2', N'exp08_04_g2';
SELECT * FROM ans08_04_g2 ORDER BY 1, 2;
GO
