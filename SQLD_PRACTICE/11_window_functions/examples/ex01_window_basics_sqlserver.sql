-- ex01 윈도우 함수의 효과와 집계 윈도우 (PDF E-32)  | SQL Server
PRINT N'== [Q1] 집계와 행 정보 동시 출력 -> 오류';
GO
-- @expect-error: MSG-8120
SELECT empno, ename, sal, SUM(sal) AS total FROM emp;
GO
PRINT N'== [Q2] 스칼라 서브쿼리 / SUM() OVER ()';
SELECT empno, ename, sal, (SELECT SUM(sal) FROM emp) AS total_subq, SUM(sal) OVER () AS total_win FROM emp WHERE deptno = 10 ORDER BY empno;
PRINT N'== [Q3] 출판사별 가격순 누적합';
SELECT book_name, publisher, price, SUM(price) OVER (PARTITION BY publisher ORDER BY price) AS total FROM bookshelf ORDER BY publisher, price;
PRINT N'== [Q4] 누적 평균';
SELECT book_name, publisher, price, ROUND(AVG(price) OVER (PARTITION BY publisher ORDER BY price), 2) AS avg FROM bookshelf ORDER BY publisher, price;
PRINT N'== [Q5] ORDER BY 없으면 파티션 전체';
SELECT book_name, publisher, price, SUM(price) OVER (PARTITION BY publisher) AS total FROM bookshelf ORDER BY publisher, price;
PRINT N'== [Q6] COUNT·MAX·MIN 윈도우';
SELECT ename, deptno, sal, COUNT(*) OVER (PARTITION BY deptno) cnt, MAX(sal) OVER (PARTITION BY deptno) mx, MIN(sal) OVER (PARTITION BY deptno) mn
FROM emp WHERE deptno = 10 ORDER BY sal DESC;
GO
