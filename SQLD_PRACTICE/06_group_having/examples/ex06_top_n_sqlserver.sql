-- ex06 TOP-N 과 행 제한  | SQL Server (ROWNUM 없음 -> TOP, OFFSET-FETCH)
PRINT N'== [Q1] ROWNUM 은 없는 컬럼 -> 오류';
GO
-- @expect-error: MSG-207
SELECT COUNT(*) FROM emp WHERE ROWNUM <= 3;
GO
PRINT N'== [Q4] ORDER BY 없는 TOP 3 : 어떤 3행인지 단정 불가';
SELECT TOP 3 ename, sal FROM emp;
PRINT N'== [Q6] TOP 3 + ORDER BY (동점은 ename)';
SELECT TOP 3 ename, sal FROM emp ORDER BY sal DESC, ename;
PRINT N'== [Q7] TOP 2 WITH TIES / TOP 20 PERCENT / OFFSET-FETCH';
SELECT TOP 2 WITH TIES ename, sal FROM emp ORDER BY sal DESC;
SELECT COUNT(*) AS pct20_rows FROM (SELECT TOP 20 PERCENT ename FROM emp ORDER BY sal DESC) t;
SELECT ename, sal FROM emp ORDER BY sal DESC, ename OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;
GO
PRINT N'== [Q9] WITH TIES 에 ORDER BY 없음 -> 오류';
GO
-- @expect-error: MSG-1062
SELECT TOP 2 WITH TIES ename, sal FROM emp;
GO
PRINT N'== [Q10] OFFSET-FETCH 에 ORDER BY 없음 -> 구문 오류';
GO
-- @expect-error: MSG-102, MSG-153
SELECT ename FROM emp OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;
GO
