-- ex02 IN / NOT IN 과 NULL (요구목록 §7, PDF E-06 연산자 표)  | Oracle
PROMPT == [Q1] IN (목록) = OR 의 연속
SELECT ename, mgr FROM emp WHERE mgr IN (7698, 7839) ORDER BY empno;

PROMPT == [Q2] IN 목록에 NULL 을 넣어도 mgr 이 NULL 인 KING 은 나오지 않는다 (NULL = NULL 은 UNKNOWN)
SELECT ename, mgr FROM emp WHERE mgr IN (7839, NULL) ORDER BY empno;

PROMPT == [Q3] NOT IN (7839) : mgr 이 NULL 인 KING 은 'mgr <> 7839' 가 UNKNOWN 이라 제외
SELECT COUNT(*) AS cnt FROM emp WHERE mgr NOT IN (7839);

PROMPT == [Q4] NOT IN 목록에 NULL 이 하나라도 있으면 결과는 항상 0행
SELECT COUNT(*) AS cnt FROM emp WHERE mgr NOT IN (7839, NULL);

PROMPT == [Q5] 다중 컬럼 IN (Oracle 지원)
SELECT ename, deptno, job FROM emp WHERE (deptno, job) IN ((10, 'CLERK'), (20, 'ANALYST')) ORDER BY empno;
