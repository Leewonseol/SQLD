-- ex02 다중행 서브쿼리 IN·ANY·ALL  | SQL Server (ANY/SOME/ALL 은 서브쿼리만 받는다)
PRINT N'== [Q1] IN';
SELECT ename, job FROM emp WHERE job IN (SELECT job FROM emp WHERE deptno = 10) ORDER BY job, ename;
PRINT N'== [Q2] > ANY';
SELECT ename, sal FROM emp WHERE sal > ANY (SELECT sal FROM emp WHERE deptno = 10) ORDER BY sal, ename;
PRINT N'== [Q3] > ALL';
SELECT ename, sal FROM emp WHERE sal > ALL (SELECT sal FROM emp WHERE deptno = 30) ORDER BY sal, ename;
PRINT N'== [Q4] < ANY / < ALL (값 목록은 VALUES 서브쿼리로)';
SELECT (SELECT COUNT(*) FROM emp WHERE sal < ANY (SELECT v FROM (VALUES (1000), (3000)) t(v))) lt_any,
       (SELECT COUNT(*) FROM emp WHERE sal < ALL (SELECT v FROM (VALUES (1000), (3000)) t(v))) lt_all;
PRINT N'== [Q5] 빈 집합';
SELECT (SELECT COUNT(*) FROM emp WHERE sal > ALL (SELECT sal FROM emp WHERE deptno = 40)) all_empty,
       (SELECT COUNT(*) FROM emp WHERE sal > ANY (SELECT sal FROM emp WHERE deptno = 40)) any_empty;
PRINT N'== [Q6] = ANY / <> ALL';
SELECT (SELECT COUNT(*) FROM emp WHERE empno = ANY (SELECT mgr FROM emp)) eq_any,
       (SELECT COUNT(*) FROM emp WHERE empno <> ALL (SELECT mgr FROM emp)) ne_all;
GO
PRINT N'== [Q7] ANY 에 리터럴 목록 -> 구문 오류';
GO
-- @expect-error: MSG-102
SELECT COUNT(*) FROM emp WHERE sal < ANY (1000, 3000);
GO
