-- ex01 비교·논리·부정 연산자와 우선순위 (PDF E-06)  | Oracle  데이터: EMP
PROMPT == [Q1] 괄호 없음: AND 가 OR 보다 먼저 -> job='SALESMAN' OR (job='MANAGER' AND sal > 2800)
SELECT ename, job, sal FROM emp WHERE job = 'SALESMAN' OR job = 'MANAGER' AND sal > 2800 ORDER BY empno;

PROMPT == [Q2] 괄호로 OR 를 먼저
SELECT ename, job, sal FROM emp WHERE (job = 'SALESMAN' OR job = 'MANAGER') AND sal > 2800 ORDER BY empno;

PROMPT == [Q3] NOT 은 비교 연산자보다 늦게, AND 보다 먼저: NOT deptno = 10 AND sal > 2000 = (NOT (deptno = 10)) AND sal > 2000
SELECT ename, deptno, sal FROM emp WHERE NOT deptno = 10 AND sal > 2000 ORDER BY empno;

PROMPT == [Q4] 부정 비교 연산자 != , ^= , <> , NOT 컬럼 = (모두 같은 결과 건수)
SELECT (SELECT COUNT(*) FROM emp WHERE deptno != 30) AS ne1,
       (SELECT COUNT(*) FROM emp WHERE deptno ^= 30) AS ne2,
       (SELECT COUNT(*) FROM emp WHERE deptno <> 30) AS ne3,
       (SELECT COUNT(*) FROM emp WHERE NOT deptno = 30) AS ne4,
       (SELECT COUNT(*) FROM emp WHERE NOT sal > 2000) AS not_gt
FROM dual;

PROMPT == [Q5] SQL 연산자의 부정: NOT BETWEEN, NOT IN, NOT LIKE, IS NOT NULL
SELECT ename, sal, comm FROM emp
WHERE sal NOT BETWEEN 1000 AND 3000 AND deptno NOT IN (30) AND ename NOT LIKE 'K%' ORDER BY empno;
