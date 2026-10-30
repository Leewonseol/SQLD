-- ex01 비교·논리·부정 연산자와 우선순위 (PDF E-06)  | SQL Server
PRINT N'== [Q1] 괄호 없음';
SELECT ename, job, sal FROM emp WHERE job = 'SALESMAN' OR job = 'MANAGER' AND sal > 2800 ORDER BY empno;
PRINT N'== [Q2] 괄호로 OR 를 먼저';
SELECT ename, job, sal FROM emp WHERE (job = 'SALESMAN' OR job = 'MANAGER') AND sal > 2800 ORDER BY empno;
PRINT N'== [Q3] NOT deptno = 10 AND sal > 2000';
SELECT ename, deptno, sal FROM emp WHERE NOT deptno = 10 AND sal > 2000 ORDER BY empno;
PRINT N'== [Q4] 부정 비교 연산자 != , <> , NOT 컬럼 = (^= 는 SQL Server 에 없다)';
SELECT (SELECT COUNT(*) FROM emp WHERE deptno != 30) AS ne1,
       (SELECT COUNT(*) FROM emp WHERE deptno <> 30) AS ne3,
       (SELECT COUNT(*) FROM emp WHERE NOT deptno = 30) AS ne4,
       (SELECT COUNT(*) FROM emp WHERE NOT sal > 2000) AS not_gt;
PRINT N'== [Q5] SQL 연산자의 부정';
SELECT ename, sal, comm FROM emp
WHERE sal NOT BETWEEN 1000 AND 3000 AND deptno NOT IN (30) AND ename NOT LIKE 'K%' ORDER BY empno;
GO
PRINT N'== [Q6] ^= 연산자 -> 구문 오류';
GO
-- @expect-error: MSG-102
SELECT COUNT(*) FROM emp WHERE deptno ^= 30;
GO
