-- ex06 스칼라 서브쿼리 (PDF E-20)  | SQL Server
PRINT N'== [Q1] 스칼라 서브쿼리';
SELECT p.id, p.name, p.price, (SELECT a.name FROM artists a WHERE a.id = p.artist_id) AS artist_name
FROM paintings p ORDER BY p.id;
PRINT N'== [Q2] LEFT JOIN';
SELECT p.id, p.name, p.price, a.name AS artist_name FROM paintings p LEFT JOIN artists a ON p.artist_id = a.id ORDER BY p.id;
PRINT N'== [Q3] 두 결과 비교';
SELECT COUNT(*) AS diff_rows FROM (
  SELECT * FROM (SELECT p.id, (SELECT a.name FROM artists a WHERE a.id = p.artist_id) n FROM paintings p
                 EXCEPT SELECT p.id, a.name FROM paintings p LEFT JOIN artists a ON p.artist_id = a.id) x
  UNION ALL
  SELECT * FROM (SELECT p.id, a.name FROM paintings p LEFT JOIN artists a ON p.artist_id = a.id
                 EXCEPT SELECT p.id, (SELECT a.name FROM artists a WHERE a.id = p.artist_id) FROM paintings p) y) z;
PRINT N'== [Q4] 전체 급여 합계를 한 행에';
SELECT empno, ename, deptno, sal, (SELECT SUM(sal) FROM emp) AS total_sal FROM emp WHERE deptno = 10 ORDER BY empno;
GO
PRINT N'== [Q5] 스칼라 서브쿼리 2행 이상 -> 오류';
GO
-- @expect-error: MSG-512
SELECT d.dname, (SELECT e.ename FROM emp e WHERE e.deptno = d.deptno) AS ename FROM dept d;
GO
PRINT N'== [Q6] 스칼라 서브쿼리 2개 컬럼 -> 오류';
GO
-- @expect-error: MSG-116
SELECT d.dname, (SELECT MIN(e.sal), MAX(e.sal) FROM emp e WHERE e.deptno = d.deptno) AS x FROM dept d;
GO
