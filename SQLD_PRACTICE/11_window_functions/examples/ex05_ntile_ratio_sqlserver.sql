-- ex05 NTILE · PERCENT_RANK · CUME_DIST (PDF E-35 "NTILE (SQL Server는 지원X)" 서술 검증)  | SQL Server
PRINT N'== [Q1] NTILE(3) 그룹 크기';
SELECT grp, COUNT(*) AS cnt FROM (SELECT NTILE(3) OVER (ORDER BY sal, empno) grp FROM emp) t GROUP BY grp ORDER BY grp;
PRINT N'== [Q2] NTILE(2)';
SELECT ename, sal, deptno, NTILE(2) OVER (ORDER BY sal, empno) AS group_no FROM emp ORDER BY sal, empno;
PRINT N'== [Q3] PERCENT_RANK / CUME_DIST (FLOAT 결과)';
SELECT ename, sal, RANK() OVER (ORDER BY sal) rnk, ROUND(PERCENT_RANK() OVER (ORDER BY sal), 3) pct_rank,
       ROUND(CUME_DIST() OVER (ORDER BY sal), 3) cume FROM emp WHERE deptno = 30 ORDER BY sal, ename;
PRINT N'== [Q4] RATIO_TO_REPORT 없음 -> sal / SUM(sal) OVER ()';
SELECT ename, sal, ROUND(sal / SUM(sal) OVER (), 3) same_by_sum FROM emp WHERE deptno = 10 ORDER BY sal DESC;
GO
PRINT N'== [Q5] RATIO_TO_REPORT -> 오류';
GO
-- @expect-error: MSG-195
SELECT RATIO_TO_REPORT(sal) OVER () FROM emp;
GO
