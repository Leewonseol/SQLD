-- ex06 WHERE 절의 집계함수 금지  | SQL Server
PRINT N'== [Q1] WHERE 에 집계함수 -> 오류';
GO
-- @expect-error: MSG-147
SELECT deptno FROM emp WHERE AVG(sal) > 2000 GROUP BY deptno;
GO
PRINT N'== [Q2] HAVING';
SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal FROM emp GROUP BY deptno HAVING AVG(sal) > 2000 ORDER BY deptno;
PRINT N'== [Q3] 서브쿼리';
SELECT ename, sal FROM emp WHERE sal > (SELECT AVG(sal) FROM emp) ORDER BY sal DESC, ename;
GO
