-- ex02 SELECT 문의 작성 순서와 논리적 처리 순서 (PDF E-05)  | SQL Server
-- 오류 문장은 배치(GO)를 분리한다. 구문 오류는 같은 배치의 다른 문장까지 실행하지 못하게 한다.
PRINT N'== [Q1] 작성 순서대로 쓴 쿼리';
SELECT deptno, COUNT(*) AS cnt
FROM emp
WHERE sal >= 1000
GROUP BY deptno
HAVING COUNT(*) >= 3
ORDER BY cnt DESC, deptno;
GO
PRINT N'== [Q2] SELECT 절 별칭을 WHERE 에서 사용 -> 오류';
GO
-- @expect-error: MSG-207
SELECT ename, sal * 12 AS annual FROM emp WHERE annual > 30000;
GO
PRINT N'== [Q3] SELECT 절 별칭을 ORDER BY 에서 사용 -> 가능';
SELECT ename, sal * 12 AS annual FROM emp WHERE sal * 12 > 30000 ORDER BY annual DESC, ename;
GO
PRINT N'== [Q4] HAVING 을 GROUP BY 앞에 작성 -> SQL Server 는 구문 오류';
GO
-- @expect-error: MSG-156
SELECT deptno, COUNT(*) AS cnt FROM emp HAVING COUNT(*) >= 5 GROUP BY deptno ORDER BY deptno;
GO
PRINT N'== [Q5] GROUP BY 에 SELECT 별칭 사용 -> 오류';
GO
-- @expect-error: MSG-207
SELECT deptno AS d, COUNT(*) AS cnt FROM emp GROUP BY d;
GO
