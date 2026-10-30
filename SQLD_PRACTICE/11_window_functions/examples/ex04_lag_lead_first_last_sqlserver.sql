-- ex04 LAG · LEAD · FIRST_VALUE · LAST_VALUE (PDF E-34: "FIRST_VALUE, LAST_VALUE (SQL Server AIX)" 서술 검증)  | SQL Server 2022
PRINT N'== [Q1] LAG / LEAD';
SELECT ename, hiredate, sal, LAG(sal) OVER (ORDER BY hiredate, empno) prev_sal, LAG(sal, 1, 0) OVER (ORDER BY hiredate, empno) prev_or0,
       LEAD(sal) OVER (ORDER BY hiredate, empno) next_sal, LEAD(sal, 2) OVER (ORDER BY hiredate, empno) next2
FROM emp WHERE deptno = 30 ORDER BY hiredate, empno;
PRINT N'== [Q2] PARTITION BY 와 LAG';
SELECT deptno, ename, sal, LAG(sal) OVER (PARTITION BY deptno ORDER BY sal) prev_in_dept FROM emp WHERE deptno IN (10, 20) ORDER BY deptno, sal, ename;
PRINT N'== [Q3] FIRST_VALUE (SQL Server 2012+ 지원)';
SELECT deptno, ename, sal, FIRST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal) min_sal,
       FIRST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal DESC) max_sal
FROM emp WHERE deptno = 10 ORDER BY sal;
PRINT N'== [Q4] LAST_VALUE 기본 프레임 함정';
SELECT deptno, ename, sal,
       LAST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal) v1,
       LAST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) max_sal,
       LAST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) min_sal
FROM emp WHERE deptno = 10 ORDER BY sal;
PRINT N'== [Q5] FIRST_VALUE(ENAME) ROWS UNBOUNDED PRECEDING';
SELECT ename, deptno, sal, FIRST_VALUE(ename) OVER (PARTITION BY deptno ORDER BY sal DESC, ename ROWS UNBOUNDED PRECEDING) ename_fv
FROM emp WHERE deptno IN (10, 20) ORDER BY deptno, sal DESC, ename;
PRINT N'== [Q6] IGNORE NULLS (SQL Server 2022 부터)';
SELECT ename, comm, LAG(comm) IGNORE NULLS OVER (ORDER BY empno) lag_ign, LAST_VALUE(comm) IGNORE NULLS OVER (ORDER BY empno) last_nonnull
FROM emp WHERE deptno = 30 ORDER BY empno;
GO
