-- ex03 SELECT·DISTINCT·ALIAS·산술·결합·DUAL (PDF E-07, 요구목록 §7)  | Oracle
PROMPT == [Q1] DISTINCT 한 컬럼
SELECT DISTINCT job FROM emp ORDER BY job;

PROMPT == [Q2] DISTINCT 두 컬럼 = (deptno, job) 조합 기준 중복 제거
SELECT DISTINCT deptno, job FROM emp ORDER BY deptno, job;

PROMPT == [Q3] 별칭: AS 생략 가능, 큰따옴표 없으면 대문자로 출력, 있으면 그대로
SELECT ename AS 이름, sal monthly, sal * 12 AS "Annual Sal" FROM emp WHERE deptno = 10 ORDER BY empno;

PROMPT == [Q4] NULL 이 섞인 산술 연산 결과는 NULL
SELECT ename, sal, comm, sal + comm AS sal_plus_comm, sal + NVL(comm, 0) AS sal_plus_nvl
FROM emp WHERE deptno = 30 ORDER BY empno;

PROMPT == [Q5] 문자열 결합: || 는 NULL 을 빈 문자열처럼 다룬다, CONCAT 은 인수 2개
SELECT ename || '(' || job || ')' AS who, 'X' || NULL AS x_null, CONCAT('X', NULL) AS concat_null
FROM emp WHERE empno = 7369;

PROMPT == [Q6] DUAL: DUMMY 컬럼 하나, 값 'X' 한 행 (PDF E-07)
SELECT * FROM dual;
SELECT 1 + 1 AS two, SYSDATE - SYSDATE AS zero FROM dual;

PROMPT == [Q7] 21c 에서 FROM 생략 -> 오류 (PDF E-07: 23c 이전은 FROM 필수)
-- @expect-error: ORA-00923
SELECT 1 + 1 AS two;
