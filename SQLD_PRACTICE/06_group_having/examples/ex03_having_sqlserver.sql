-- ex03 HAVING  | SQL Server
PRINT N'== [Q1] SELECT 에 없는 집계로 HAVING';
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno HAVING MAX(sal) >= 3000 ORDER BY deptno;
PRINT N'== [Q2] 그룹 컬럼 조건 WHERE vs HAVING';
SELECT deptno, COUNT(*) AS cnt FROM emp WHERE deptno <> 30 GROUP BY deptno ORDER BY deptno;
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno HAVING deptno <> 30 ORDER BY deptno;
PRINT N'== [Q3] 급여 조건 WHERE vs HAVING';
SELECT deptno, COUNT(*) AS cnt FROM emp WHERE sal > 1500 GROUP BY deptno ORDER BY deptno;
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno HAVING MIN(sal) > 1500 ORDER BY deptno;
PRINT N'== [Q4] GROUP BY 없는 HAVING';
SELECT COUNT(*) AS cnt FROM emp HAVING COUNT(*) > 100;
SELECT COUNT(*) AS cnt FROM emp HAVING COUNT(*) > 10;
GO
PRINT N'== [Q5] HAVING 에 비그룹 컬럼 -> 오류';
GO
-- @expect-error: MSG-8121
SELECT deptno, COUNT(*) FROM emp GROUP BY deptno HAVING sal > 1000;
GO
