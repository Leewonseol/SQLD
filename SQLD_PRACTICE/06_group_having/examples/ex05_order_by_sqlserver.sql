-- ex05 ORDER BY (PDF E-08)  | SQL Server
PRINT N'== [Q1] ASC: SQL Server 는 NULL 을 가장 작은 값으로 보아 맨 앞에';
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm, ename;
PRINT N'== [Q2] DESC: NULL 이 맨 뒤';
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm DESC, ename;
GO
PRINT N'== [Q3] NULLS LAST 키워드 없음 -> 구문 오류';
GO
-- @expect-error: MSG-102
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY comm NULLS LAST;
GO
PRINT N'== [Q3b] CASE 로 NULLS FIRST / NULLS LAST 흉내';
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY CASE WHEN comm IS NULL THEN 0 ELSE 1 END, comm, ename;
SELECT ename, comm FROM emp WHERE deptno = 30 ORDER BY CASE WHEN comm IS NULL THEN 1 ELSE 0 END, comm DESC, ename;
PRINT N'== [Q4] 별칭·위치 번호·여러 키';
SELECT deptno, ename, sal * 12 AS annual FROM emp WHERE deptno IN (10, 20) ORDER BY 1 DESC, annual, ename;
PRINT N'== [Q5] SELECT 에 없는 컬럼으로 정렬';
SELECT ename FROM emp WHERE deptno = 10 ORDER BY sal DESC;
GO
PRINT N'== [Q6] DISTINCT + SELECT 에 없는 컬럼 정렬 -> 오류';
GO
-- @expect-error: MSG-145
SELECT DISTINCT job FROM emp ORDER BY sal;
GO
PRINT N'== [Q7] GROUP BY + 비그룹 컬럼 정렬 -> 오류';
GO
-- @expect-error: MSG-8127
SELECT deptno, COUNT(*) FROM emp GROUP BY deptno ORDER BY ename;
GO
PRINT N'== [Q8] GROUP BY + SELECT 에 없는 그룹 컬럼·집계 정렬 -> 허용';
SELECT TOP 4 deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno, job ORDER BY job, deptno;
SELECT deptno FROM emp GROUP BY deptno ORDER BY MAX(sal);
GO
PRINT N'== [Q9] 파생 테이블 안의 ORDER BY (TOP 없이) -> 오류';
GO
-- @expect-error: MSG-1033
SELECT * FROM (SELECT ename, sal FROM emp ORDER BY sal DESC) t;
GO
