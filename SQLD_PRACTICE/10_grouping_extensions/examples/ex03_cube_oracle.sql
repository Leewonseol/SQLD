-- ex03 CUBE (PDF E-30 "결합 가능한 모든 값에 대하여 다차원 집계", "18개의 행", "인수의 순서가 바뀌어도 […] 데이터의 결과는 같다")  | Oracle
PROMPT == [Q1] PDF 재현: CUBE(DNAME, JOB) = (DNAME,JOB) 9 + DNAME 3 + JOB 5 + 총계 1 = 18행
SELECT d.dname, e.job, COUNT(*) "Total Empl", SUM(e.sal) "Total Sal"
FROM emp e, dept d WHERE d.deptno = e.deptno
GROUP BY CUBE (d.dname, e.job)
ORDER BY GROUPING(d.dname), d.dname, GROUPING(e.job), e.job;

PROMPT == [Q2] CUBE(JOB, DNAME) 과 행 집합이 같은가: 차집합 양방향 0행
SELECT COUNT(*) AS diff_rows FROM (
  (SELECT d.dname, e.job, COUNT(*) c, SUM(e.sal) s FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY CUBE (d.dname, e.job)
   MINUS SELECT d.dname, e.job, COUNT(*), SUM(e.sal) FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY CUBE (e.job, d.dname))
  UNION ALL
  (SELECT d.dname, e.job, COUNT(*), SUM(e.sal) FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY CUBE (e.job, d.dname)
   MINUS SELECT d.dname, e.job, COUNT(*), SUM(e.sal) FROM emp e JOIN dept d ON d.deptno = e.deptno GROUP BY CUBE (d.dname, e.job)));

PROMPT == [Q3] 인수 n개 CUBE 의 그룹 조합 수 = 2^n (ROLLUP 은 n+1)
SELECT COUNT(DISTINCT gid) AS cube_sets FROM (SELECT GROUPING_ID(deptno, job, mgr) gid FROM emp GROUP BY CUBE (deptno, job, mgr));
SELECT COUNT(*) AS cube3_rows FROM (SELECT deptno, job, mgr FROM emp GROUP BY CUBE (deptno, job, mgr));
