-- ex03 CUBE (PDF E-30)  | SQL Server
PRINT N'== [Q1] CUBE(DNAME, JOB) 18행';
SELECT d.dname, e.job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY CUBE (d.dname, e.job)
ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;
PRINT N'== [Q2] CUBE 인수 순서 바꿔도 같은 행 집합';
WITH a AS (SELECT d.dname, e.job, COUNT(*) c, SUM(e.sal) s FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY CUBE (d.dname, e.job)),
     b AS (SELECT d.dname, e.job, COUNT(*) c, SUM(e.sal) s FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY CUBE (e.job, d.dname))
SELECT (SELECT COUNT(*) FROM (SELECT * FROM a EXCEPT SELECT * FROM b) x) + (SELECT COUNT(*) FROM (SELECT * FROM b EXCEPT SELECT * FROM a) y) AS diff_rows;
PRINT N'== [Q3] 3개 인수 CUBE 의 그룹 조합 수와 행 수';
SELECT COUNT(DISTINCT gid) AS cube_sets FROM (SELECT GROUPING_ID(deptno, job, mgr) gid FROM emp GROUP BY CUBE (deptno, job, mgr)) t;
SELECT COUNT(*) AS cube3_rows FROM (SELECT deptno, job, mgr FROM emp GROUP BY CUBE (deptno, job, mgr)) t;
GO
