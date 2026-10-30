-- ex04 LAG · LEAD · FIRST_VALUE · LAST_VALUE (PDF E-34)  | Oracle
PROMPT == [Q1] LAG(col, n, 기본값): n행 앞 값, 없으면 기본값(생략 시 NULL) / LEAD: n행 뒤
SELECT ename, hiredate, sal, LAG(sal) OVER (ORDER BY hiredate, empno) prev_sal, LAG(sal, 1, 0) OVER (ORDER BY hiredate, empno) prev_or0,
       LEAD(sal) OVER (ORDER BY hiredate, empno) next_sal, LEAD(sal, 2) OVER (ORDER BY hiredate, empno) next2
FROM emp WHERE deptno = 30 ORDER BY hiredate, empno;

PROMPT == [Q2] PARTITION BY 와 LAG: 각 파티션의 첫 행은 이전 값이 없어 NULL
SELECT deptno, ename, sal, LAG(sal) OVER (PARTITION BY deptno ORDER BY sal) prev_in_dept FROM emp WHERE deptno IN (10, 20) ORDER BY deptno, sal, ename;

PROMPT == [Q3] FIRST_VALUE: 정렬 순서상 첫 값 -> 부서 최저(ASC)·최고(DESC) 급여
SELECT deptno, ename, sal, FIRST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal) min_sal,
       FIRST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal DESC) max_sal
FROM emp WHERE deptno = 10 ORDER BY sal;

PROMPT == [Q4] PDF 함정: LAST_VALUE 의 기본 프레임은 '처음 ~ 현재 행' -> 현재 행 값(V1)이 나온다
SELECT deptno, ename, sal,
       LAST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal) v1,
       LAST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) max_sal,
       LAST_VALUE(sal) OVER (PARTITION BY deptno ORDER BY sal DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) min_sal
FROM emp WHERE deptno = 10 ORDER BY sal;

PROMPT == [Q5] PDF 예: FIRST_VALUE(ENAME) ... ROWS UNBOUNDED PRECEDING -> 부서 최고 급여자 이름
SELECT ename, deptno, sal, FIRST_VALUE(ename) OVER (PARTITION BY deptno ORDER BY sal DESC, ename ROWS UNBOUNDED PRECEDING) ename_fv
FROM emp WHERE deptno IN (10, 20) ORDER BY deptno, sal DESC, ename;

PROMPT == [Q6] IGNORE NULLS: comm 이 NULL 이 아닌 직전 값
SELECT ename, comm, LAG(comm IGNORE NULLS) OVER (ORDER BY empno) lag_ign, LAST_VALUE(comm IGNORE NULLS) OVER (ORDER BY empno) last_nonnull
FROM emp WHERE deptno = 30 ORDER BY empno;
