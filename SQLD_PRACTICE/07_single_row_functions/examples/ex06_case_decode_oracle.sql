-- ex06 CASE 표현식과 DECODE (요구목록 §7, PDF E-29 DECODE 사용례)  | Oracle
PROMPT == [Q1] 단순 CASE (값 비교) 와 검색 CASE (조건)
SELECT ename, deptno,
       CASE deptno WHEN 10 THEN 'ACC' WHEN 20 THEN 'RES' ELSE 'ETC' END simple_case,
       CASE WHEN sal >= 3000 THEN 'HIGH' WHEN sal >= 1500 THEN 'MID' ELSE 'LOW' END searched_case
FROM emp WHERE empno IN (7369, 7499, 7839, 7902) ORDER BY empno;

PROMPT == [Q2] 첫 번째로 참인 WHEN 에서 멈춘다 (순서 함정): 5000 은 첫 WHEN(>= 1000) 에서 끝
SELECT ename, sal, CASE WHEN sal >= 1000 THEN '1000+' WHEN sal >= 3000 THEN '3000+' END wrong_order
FROM emp WHERE empno IN (7369, 7839) ORDER BY empno;

PROMPT == [Q3] ELSE 생략 -> 해당 없으면 NULL
SELECT ename, CASE WHEN comm > 0 THEN 'Y' END has_comm FROM emp WHERE deptno = 30 ORDER BY empno;

PROMPT == [Q4] 단순 CASE 로는 NULL 을 찾지 못한다 (CASE comm WHEN NULL ... 은 comm = NULL 비교)
SELECT ename, comm, CASE comm WHEN NULL THEN 'NULL!' ELSE 'not matched' END simple_null,
       CASE WHEN comm IS NULL THEN 'NULL!' ELSE 'value' END searched_null
FROM emp WHERE empno IN (7499, 7698) ORDER BY empno;

PROMPT == [Q5] DECODE 는 NULL 과 NULL 을 같다고 본다 (CASE 와 다른 점)
SELECT ename, comm, DECODE(comm, NULL, 'NULL!', 'value') decode_null FROM emp WHERE empno IN (7499, 7698) ORDER BY empno;

PROMPT == [Q6] DECODE(값, 비교1, 결과1, 비교2, 결과2, 기본값)
SELECT ename, DECODE(job, 'CLERK', 'C', 'SALESMAN', 'S', 'X') job_code FROM emp WHERE deptno = 30 ORDER BY empno;

PROMPT == [Q7] CASE 결과의 자료형은 통일되어야 한다 -> 오류
-- @expect-error: ORA-00932
SELECT CASE WHEN sal > 1000 THEN 'big' ELSE 0 END FROM emp;
