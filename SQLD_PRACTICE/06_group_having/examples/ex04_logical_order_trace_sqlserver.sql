-- ex04 논리적 처리 순서 단계별 추적  | SQL Server (행 제한: OFFSET ... FETCH, ORDER BY 필수)
PRINT N'== [S1] FROM + JOIN ON';
SELECT e.empno, e.ename, e.job, e.sal, d.dname FROM emp e JOIN dept d ON e.deptno = d.deptno ORDER BY e.empno;
PRINT N'== [S2] WHERE';
SELECT COUNT(*) AS rows_after_where FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job <> 'PRESIDENT';
PRINT N'== [S3] GROUP BY (STRING_AGG 로 그룹 구성원 표시)';
SELECT d.dname, STRING_AGG(e.ename, ',') WITHIN GROUP (ORDER BY e.ename) AS members, COUNT(*) AS cnt, SUM(e.sal) AS total
FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job <> 'PRESIDENT' GROUP BY d.dname ORDER BY d.dname;
PRINT N'== [S4~S6] HAVING -> SELECT -> ORDER BY';
SELECT d.dname, COUNT(*) AS cnt, SUM(e.sal) AS total
FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job <> 'PRESIDENT'
GROUP BY d.dname HAVING COUNT(*) >= 2 ORDER BY total DESC;
PRINT N'== [S7] 행 제한: 최종 결과';
SELECT d.dname, COUNT(*) AS cnt, SUM(e.sal) AS total
FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.job <> 'PRESIDENT'
GROUP BY d.dname
HAVING COUNT(*) >= 2
ORDER BY total DESC
OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;
PRINT N'== [T1] DISTINCT -> ORDER BY -> 행 제한';
SELECT DISTINCT TOP 3 job FROM emp ORDER BY job;
PRINT N'== [T2] (비교) 행 제한 먼저';
SELECT DISTINCT job FROM (SELECT TOP 3 job FROM emp ORDER BY ename) t ORDER BY job;
GO
