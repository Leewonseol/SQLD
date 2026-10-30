-- ex04 GROUPING SETS (PDF E-31)  | Oracle
PROMPT == [Q1] PDF 재현: GROUPING SETS (DNAME, JOB) = DNAME 소계 3 + JOB 소계 5 = 8행 (총계 없음)
SELECT d.dname, e.job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY GROUPING SETS (d.dname, e.job)
ORDER BY GROUPING(d.dname), d.dname, e.job;

PROMPT == [Q2] 총계를 추가: () 표기 -> 9행
SELECT d.dname, e.job, COUNT(*) cnt FROM emp e JOIN dept d ON d.deptno = e.deptno
GROUP BY GROUPING SETS (d.dname, e.job, ()) ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;

PROMPT == [Q3] PDF 의 다른 표기 GROUPING SETS (A, B, NULL): Oracle 은 허용 (SQL Server 는 오류 -> sqlserver 파일 Q3)
SELECT d.dname, e.job, COUNT(*) cnt FROM emp e JOIN dept d ON d.deptno = e.deptno
GROUP BY GROUPING SETS (d.dname, e.job, NULL) ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;

PROMPT == [Q4] PDF: UNION ALL 로 대체 가능 — 두 번째 SELECT 의 NULL AS DNAME 은 NULL 만 써도 된다
SELECT d.dname, NULL AS job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal" FROM emp e, dept d WHERE d.deptno = e.deptno GROUP BY d.dname
UNION ALL
SELECT NULL, e.job, COUNT(*), SUM(e.sal) FROM emp e, dept d WHERE d.deptno = e.deptno GROUP BY e.job
ORDER BY 1 NULLS LAST, 2;

PROMPT == [Q5] 동치 관계: ROLLUP(a, b) = GROUPING SETS ((a, b), (a), ()), CUBE(a, b) = GROUPING SETS ((a, b), (a), (b), ())
SELECT (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY ROLLUP (deptno, job))) rollup_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY GROUPING SETS ((deptno, job), (deptno), ()))) gs_rollup_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY CUBE (deptno, job))) cube_rows,
       (SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY GROUPING SETS ((deptno, job), (deptno), (job), ()))) gs_cube_rows
FROM dual;
