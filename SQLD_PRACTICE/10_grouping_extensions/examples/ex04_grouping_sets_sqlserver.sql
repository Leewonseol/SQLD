-- ex04 GROUPING SETS (PDF E-31)  | SQL Server
PRINT N'== [Q1] GROUPING SETS (DNAME, JOB) 8행';
SELECT d.dname, e.job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY GROUPING SETS (d.dname, e.job)
ORDER BY GROUPING(d.dname), d.dname, e.job;
PRINT N'== [Q2] () 로 총계 추가';
SELECT d.dname, e.job, COUNT(*) cnt FROM emp e JOIN dept d ON d.deptno = e.deptno
GROUP BY GROUPING SETS (d.dname, e.job, ()) ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;
GO
PRINT N'== [Q3] PDF 표기 GROUPING SETS (A, B, NULL) -> SQL Server 는 오류';
GO
-- @expect-error: MSG-164
SELECT d.dname, e.job, COUNT(*) cnt FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY GROUPING SETS (d.dname, e.job, NULL);
GO
PRINT N'== [Q4] UNION ALL 대체';
SELECT d.dname, NULL AS job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal" FROM emp e, dept d WHERE d.deptno = e.deptno GROUP BY d.dname
UNION ALL
SELECT NULL, e.job, COUNT(*), SUM(e.sal) FROM emp e, dept d WHERE d.deptno = e.deptno GROUP BY e.job
ORDER BY 1, 2;
PRINT N'== [Q5] ROLLUP·CUBE 와 GROUPING SETS 동치';
SELECT (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY ROLLUP (deptno, job)) t) rollup_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY GROUPING SETS ((deptno, job), (deptno), ())) t) gs_rollup_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY CUBE (deptno, job)) t) cube_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY GROUPING SETS ((deptno, job), (deptno), (job), ())) t) gs_cube_rows;
GO
