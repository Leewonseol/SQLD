-- ex02 IN / NOT IN 과 NULL  | SQL Server
PRINT N'== [Q1] IN (목록)';
SELECT ename, mgr FROM emp WHERE mgr IN (7698, 7839) ORDER BY empno;
PRINT N'== [Q2] IN 목록의 NULL';
SELECT ename, mgr FROM emp WHERE mgr IN (7839, NULL) ORDER BY empno;
PRINT N'== [Q3] NOT IN (7839)';
SELECT COUNT(*) AS cnt FROM emp WHERE mgr NOT IN (7839);
PRINT N'== [Q4] NOT IN 목록에 NULL';
SELECT COUNT(*) AS cnt FROM emp WHERE mgr NOT IN (7839, NULL);
GO
PRINT N'== [Q5] 다중 컬럼 IN -> SQL Server 미지원(구문 오류)';
GO
-- @expect-error: MSG-4145
SELECT ename FROM emp WHERE (deptno, job) IN ((10, 'CLERK'), (20, 'ANALYST'));
GO
PRINT N'== [Q6] 다중 컬럼 IN 대체: OR 로 풀어 쓰기';
SELECT ename, deptno, job FROM emp WHERE (deptno = 10 AND job = 'CLERK') OR (deptno = 20 AND job = 'ANALYST') ORDER BY empno;
GO
