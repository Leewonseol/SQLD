-- ex03 다중컬럼 서브쿼리  | SQL Server : (a, b) IN (SELECT ...) 미지원 -> EXISTS 또는 JOIN 으로
PRINT N'== [Q0] 다중 컬럼 IN -> 오류';
GO
-- @expect-error: MSG-4145
SELECT ename FROM emp WHERE (deptno, sal) IN (SELECT deptno, MAX(sal) FROM emp GROUP BY deptno);
GO
PRINT N'== [Q1] EXISTS 로 대체';
SELECT e.empno, e.ename, e.sal, e.deptno FROM emp e
WHERE EXISTS (SELECT 1 FROM emp x GROUP BY x.deptno HAVING x.deptno = e.deptno AND MAX(x.sal) = e.sal)
ORDER BY e.deptno, e.empno;
PRINT N'== [Q1b] 인라인 뷰 JOIN 으로 대체';
SELECT e.empno, e.ename, e.sal, e.deptno FROM emp e
JOIN (SELECT deptno, MAX(sal) AS max_sal FROM emp GROUP BY deptno) m ON e.deptno = m.deptno AND e.sal = m.max_sal
ORDER BY e.deptno, e.empno;
PRINT N'== [Q2] 쌍 비교(EXISTS) vs 컬럼별 비교';
SELECT e.ename, e.deptno, e.job FROM emp e WHERE EXISTS (SELECT 1 FROM emp x WHERE x.empno IN (7934, 7788) AND x.deptno = e.deptno AND x.job = e.job) ORDER BY e.empno;
SELECT ename, deptno, job FROM emp WHERE deptno IN (SELECT deptno FROM emp WHERE empno IN (7934, 7788))
  AND job IN (SELECT job FROM emp WHERE empno IN (7934, 7788)) ORDER BY empno;
GO
