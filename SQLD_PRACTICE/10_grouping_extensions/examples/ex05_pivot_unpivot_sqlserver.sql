-- ex05 PIVOT · UNPIVOT  | SQL Server (IN 목록은 대괄호 식별자, 별칭은 AS 로 테이블에 필수)
PRINT N'== [Q1] PIVOT';
SELECT job, [10] AS d10, [20] AS d20, [30] AS d30
FROM (SELECT job, deptno, sal FROM emp) s
PIVOT (SUM(sal) FOR deptno IN ([10], [20], [30])) p
ORDER BY job;
PRINT N'== [Q2] CASE + 집계';
SELECT job, SUM(CASE WHEN deptno = 10 THEN sal END) d10, SUM(CASE WHEN deptno = 20 THEN sal END) d20,
       SUM(CASE WHEN deptno = 30 THEN sal END) d30
FROM emp GROUP BY job ORDER BY job;
PRINT N'== [Q3] 원본 테이블 전체로 PIVOT 하면 남은 컬럼이 모두 그룹 기준';
SELECT COUNT(*) AS rows_without_derived_table FROM emp PIVOT (SUM(sal) FOR deptno IN ([10], [20], [30])) p;
PRINT N'== [Q4] UNPIVOT (SQL Server 는 NULL 칸을 항상 제외, INCLUDE NULLS 없음)';
WITH p AS (SELECT job, [10] AS d10, [20] AS d20, [30] AS d30 FROM (SELECT job, deptno, sal FROM emp) s PIVOT (SUM(sal) FOR deptno IN ([10], [20], [30])) pv)
SELECT job, dept, total FROM p UNPIVOT (total FOR dept IN (d10, d20, d30)) u ORDER BY job, dept;
GO
