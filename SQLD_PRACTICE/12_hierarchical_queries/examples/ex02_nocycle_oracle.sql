-- ex02 순환 구조와 NOCYCLE · CONNECT_BY_ISCYCLE (PDF E-37 EMP1 예)  | Oracle
PROMPT == [Q1] PDF: 순환 데이터인데 NOCYCLE 을 쓰지 않으면 오류
-- @expect-error: ORA-01436
SELECT emp_id, name, LEVEL FROM emp1 START WITH emp_id = 1000 CONNECT BY PRIOR emp_id = mgr_id;

PROMPT == [Q2] PDF: NOCYCLE + CONNECT_BY_ISCYCLE (자식이 조상과 같아 순환이 생기는 행 = 1)
SELECT emp_id, name, LEVEL, CONNECT_BY_ISCYCLE AS is_cycle
FROM emp1 START WITH emp_id = 1000 CONNECT BY NOCYCLE PRIOR emp_id = mgr_id;

PROMPT == [Q3] NOCYCLE 없이 CONNECT_BY_ISCYCLE 을 쓰면 오류
-- @expect-error: ORA-30930
SELECT emp_id, CONNECT_BY_ISCYCLE FROM emp1 START WITH emp_id = 1000 CONNECT BY PRIOR emp_id = mgr_id;
