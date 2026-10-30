-- ex01 계층형 질의 START WITH · CONNECT BY PRIOR · 가상 컬럼 · 가상 함수 (PDF E-37)  | Oracle 전용 구문
PROMPT == [Q1] PDF 예 (순방향, 위 -> 아래): PRIOR 사원 = 관리자 -> "부모 행의 사원 = 자식 행의 관리자"
SELECT CONNECT_BY_ROOT emp_name AS 루트사원, SYS_CONNECT_BY_PATH(emp_name, '/') AS 경로, emp_name AS 사원, mgr_name AS 관리자,
       LEVEL AS lvl, CONNECT_BY_ISLEAF AS is_leaf
FROM h_emp
START WITH mgr_name IS NULL
CONNECT BY PRIOR emp_name = mgr_name
ORDER SIBLINGS BY emp_name;

PROMPT == [Q2] 역방향(아래 -> 위): PRIOR 를 반대편에 두면 D 에서 루트까지 올라간다
SELECT LEVEL AS lvl, emp_name, mgr_name, SYS_CONNECT_BY_PATH(emp_name, '/') AS path
FROM h_emp START WITH emp_name = 'D' CONNECT BY emp_name = PRIOR mgr_name;

PROMPT == [Q3] EMP(SCOTT) 전체 조직도: 들여쓰기 + ORDER SIBLINGS BY (형제 사이만 정렬, 계층 구조 유지)
SELECT LPAD(' ', 2 * (LEVEL - 1), '.') || ename AS org, LEVEL lvl, CONNECT_BY_ISLEAF leaf
FROM emp START WITH mgr IS NULL CONNECT BY PRIOR empno = mgr ORDER SIBLINGS BY ename;

PROMPT == [Q4] 일반 ORDER BY 를 쓰면 계층 순서가 깨진다
SELECT LEVEL lvl, ename FROM emp START WITH mgr IS NULL CONNECT BY PRIOR empno = mgr ORDER BY ename FETCH FIRST 5 ROWS ONLY;

PROMPT == [Q5] WHERE 는 전개가 끝난 뒤 행을 거른다(자식은 남음) / CONNECT BY 의 조건은 그 가지 전체를 잘라낸다
SELECT LEVEL lvl, ename FROM emp WHERE ename <> 'JONES' START WITH mgr IS NULL CONNECT BY PRIOR empno = mgr ORDER SIBLINGS BY ename;
SELECT LEVEL lvl, ename FROM emp START WITH mgr IS NULL CONNECT BY PRIOR empno = mgr AND ename <> 'JONES' ORDER SIBLINGS BY ename;

PROMPT == [Q6] START WITH 를 빼면 모든 행이 각각 루트가 된다 (행 수 증가)
SELECT COUNT(*) AS rows_no_start_with FROM h_emp CONNECT BY PRIOR emp_name = mgr_name;
