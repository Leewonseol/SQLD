-- ex02 GROUP BY 규칙  | SQL Server
PRINT N'== [Q1] GROUP BY 에 없는 컬럼 -> 오류';
GO
-- @expect-error: MSG-8120
SELECT deptno, ename, COUNT(*) FROM emp GROUP BY deptno;
GO
PRINT N'== [Q2] 여러 컬럼 GROUP BY';
SELECT deptno, job, COUNT(*) AS cnt, SUM(sal) AS sum_sal FROM emp GROUP BY deptno, job ORDER BY deptno, job;
PRINT N'== [Q3] NULL 그룹';
SELECT grp, COUNT(*) AS cnt, SUM(v) AS sum_v FROM g_num GROUP BY grp ORDER BY grp;
PRINT N'== [Q4] 집계 없는 GROUP BY';
SELECT job FROM emp GROUP BY job ORDER BY job;
PRINT N'== [Q5] GROUP BY 없는 집계';
SELECT COUNT(*) AS cnt, SUM(sal) AS total FROM emp;
GO
PRINT N'== [Q6] 집계와 일반 컬럼 혼용 -> 오류';
GO
-- @expect-error: MSG-8120
SELECT ename, SUM(sal) FROM emp;
GO
PRINT N'== [Q7] GROUP BY 에 표현식';
SELECT YEAR(hiredate) AS hire_year, COUNT(*) AS cnt FROM emp GROUP BY YEAR(hiredate) ORDER BY hire_year;
GO
