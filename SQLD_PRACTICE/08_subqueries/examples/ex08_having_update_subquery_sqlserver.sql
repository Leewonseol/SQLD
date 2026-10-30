-- ex08 HAVING 절 서브쿼리와 UPDATE SET 절 서브쿼리  | SQL Server (명시적 트랜잭션으로 되돌린다)
PRINT N'== [Q1] HAVING 서브쿼리';
SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal FROM emp GROUP BY deptno HAVING AVG(sal) > (SELECT AVG(sal) FROM emp) ORDER BY deptno;
PRINT N'== [Q2] 실험용 복사본';
DROP TABLE IF EXISTS emp_u;
SELECT empno, ename, comm INTO emp_u FROM emp WHERE deptno = 30;
PRINT N'== [Q3] WHERE 없는 SET 서브쿼리 -> 짝 없는 행이 NULL';
BEGIN TRAN;
UPDATE u SET comm = (SELECT b.amt FROM bonus b WHERE b.empno = u.empno) FROM emp_u u;
SELECT empno, ename, comm FROM emp_u ORDER BY empno;
ROLLBACK;
PRINT N'== [Q4] WHERE EXISTS';
BEGIN TRAN;
UPDATE u SET comm = (SELECT b.amt FROM bonus b WHERE b.empno = u.empno) FROM emp_u u
WHERE EXISTS (SELECT 1 FROM bonus b WHERE b.empno = u.empno);
SELECT empno, ename, comm FROM emp_u ORDER BY empno;
ROLLBACK;
PRINT N'== [Q5] SQL Server 식 UPDATE ... FROM JOIN (짝 있는 행만 갱신)';
BEGIN TRAN;
UPDATE u SET comm = b.amt FROM emp_u u JOIN bonus b ON b.empno = u.empno;
SELECT empno, ename, comm FROM emp_u ORDER BY empno;
ROLLBACK;
DROP TABLE IF EXISTS emp_u;
GO
