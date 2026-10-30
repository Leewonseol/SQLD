-- ex02 다중행 서브쿼리 IN·ANY·ALL (PDF E-22 ② 다중행 비교 연산자 표, ">ANY 최소값…" 표)  | Oracle
PROMPT == [Q1] IN: 10번 부서 사원들의 직무와 같은 직무
SELECT ename, job FROM emp WHERE job IN (SELECT job FROM emp WHERE deptno = 10) ORDER BY job, ename;

PROMPT == [Q2] PDF 예: > ANY = 최솟값보다 크면 참 (10번 부서 최소 1300)
SELECT ename, sal FROM emp WHERE sal > ANY (SELECT sal FROM emp WHERE deptno = 10) ORDER BY sal, ename;

PROMPT == [Q3] > ALL = 최댓값보다 커야 참 (30번 부서 최대 2850)
SELECT ename, sal FROM emp WHERE sal > ALL (SELECT sal FROM emp WHERE deptno = 30) ORDER BY sal, ename;

PROMPT == [Q4] < ANY = 최댓값보다 작으면 참, < ALL = 최솟값보다 작아야 참 (리터럴 목록: Oracle 허용)
SELECT (SELECT COUNT(*) FROM emp WHERE sal < ANY (1000, 3000)) lt_any,
       (SELECT COUNT(*) FROM emp WHERE sal < ALL (1000, 3000)) lt_all FROM dual;

PROMPT == [Q5] 빈 집합: ALL 은 항상 참(14행), ANY 는 항상 거짓(0행)
SELECT (SELECT COUNT(*) FROM emp WHERE sal > ALL (SELECT sal FROM emp WHERE deptno = 40)) all_empty,
       (SELECT COUNT(*) FROM emp WHERE sal > ANY (SELECT sal FROM emp WHERE deptno = 40)) any_empty FROM dual;

PROMPT == [Q6] = ANY 는 IN 과 같고, <> ALL 은 NOT IN 과 같다 (NULL 함정도 같다)
SELECT (SELECT COUNT(*) FROM emp WHERE empno = ANY (SELECT mgr FROM emp)) eq_any,
       (SELECT COUNT(*) FROM emp WHERE empno <> ALL (SELECT mgr FROM emp)) ne_all FROM dual;
