-- ex05 NULL 관련 함수 NVL·NVL2·NULLIF·COALESCE (요구목록 §7)  | Oracle
PROMPT == [Q1] NVL(a, b): a 가 NULL 이면 b / NVL2(a, b, c): a 가 NULL 이 아니면 b, NULL 이면 c
SELECT ename, comm, NVL(comm, 0) nvl_c, NVL2(comm, sal + comm, sal) nvl2_pay FROM emp WHERE deptno = 30 ORDER BY empno;

PROMPT == [Q2] NULLIF(a, b): 같으면 NULL, 다르면 a / COALESCE: 처음으로 NULL 이 아닌 값
SELECT NULLIF(10, 10) n1, NULLIF(10, 20) n2, COALESCE(NULL, NULL, 'third') c1, COALESCE(NULL, NULL) c2 FROM dual;

PROMPT == [Q3] 0 으로 나누기 회피: NULLIF 로 분모 0 을 NULL 로
SELECT ename, sal, comm, ROUND(sal / NULLIF(comm, 0), 2) ratio FROM emp WHERE deptno = 30 ORDER BY empno;

PROMPT == [Q4] NVL(SUM) 과 SUM(NVL) : 대상 행이 없으면 SUM(NVL()) 도 NULL
SELECT NVL(SUM(sal), 0) nvl_sum, SUM(NVL(sal, 0)) sum_nvl FROM emp WHERE deptno = 40;

PROMPT == [Q5] NVL 의 두 인수 자료형: 숫자 컬럼에 문자 기본값 -> 오류
-- @expect-error: ORA-01722
SELECT NVL(comm, 'none') FROM emp;

PROMPT == [Q6] 문자 기본값을 쓰려면 먼저 문자로 변환
SELECT ename, NVL(TO_CHAR(comm), 'none') comm_txt FROM emp WHERE deptno = 30 ORDER BY empno;
