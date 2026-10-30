-- ex03 순위 함수  | SQL Server
PRINT N'== [Q1] 동점 처리 차이';
SELECT ename, sal, RANK() OVER (ORDER BY sal DESC) rnk, DENSE_RANK() OVER (ORDER BY sal DESC) drnk,
       ROW_NUMBER() OVER (ORDER BY sal DESC, ename) rn
FROM emp WHERE sal >= 2450 ORDER BY sal DESC, ename;
PRINT N'== [Q2] PARTITION BY';
SELECT deptno, ename, sal, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) dept_rnk FROM emp ORDER BY deptno, dept_rnk, ename;
GO
PRINT N'== [Q3] WHERE 에 윈도우 함수 -> 오류';
GO
-- @expect-error: MSG-4108
SELECT ename FROM emp WHERE RANK() OVER (ORDER BY sal DESC) <= 3;
GO
PRINT N'== [Q4] 부서별 TOP 2 (RANK)';
SELECT deptno, ename, sal, rnk FROM (
  SELECT deptno, ename, sal, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) rnk FROM emp
) t WHERE rnk <= 2 ORDER BY deptno, rnk, ename;
PRINT N'== [Q5] ROW_NUMBER 정확히 2명';
SELECT deptno, ename, sal, rn FROM (
  SELECT deptno, ename, sal, ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC, empno) rn FROM emp
) t WHERE rn <= 2 ORDER BY deptno, rn;
GO
PRINT N'== [Q6] 순위 함수에 ORDER BY 없음 -> 오류';
GO
-- @expect-error: MSG-4112
SELECT ename, RANK() OVER (PARTITION BY deptno) FROM emp;
GO
