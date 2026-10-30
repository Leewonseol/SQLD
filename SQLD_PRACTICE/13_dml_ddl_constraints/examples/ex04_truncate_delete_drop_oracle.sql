-- ex04 DELETE · TRUNCATE · DROP 비교 (PDF E-04 "TRUNCATE(오토커밋이라)")  | Oracle
EXEC lab_drop('D13_CHILD')
EXEC lab_drop('D13_PARENT')
CREATE TABLE d13_parent (id NUMBER CONSTRAINT pk_d13_parent PRIMARY KEY);
CREATE TABLE d13_child (id NUMBER, pid NUMBER CONSTRAINT fk_d13_child REFERENCES d13_parent(id));
INSERT INTO d13_parent SELECT LEVEL FROM dual CONNECT BY LEVEL <= 5;
INSERT INTO d13_child VALUES (1, 1);
COMMIT;

PROMPT == [Q1] DELETE (DML): WHERE 가능, ROLLBACK 으로 되돌릴 수 있다
DELETE FROM d13_child;
SELECT COUNT(*) AS after_delete FROM d13_child;
ROLLBACK;
SELECT COUNT(*) AS after_rollback FROM d13_child;

PROMPT == [Q2] TRUNCATE (DDL): 자동 커밋 -> ROLLBACK 해도 돌아오지 않는다
TRUNCATE TABLE d13_child;
ROLLBACK;
SELECT COUNT(*) AS after_truncate_rollback FROM d13_child;

PROMPT == [Q3a] 자식 테이블이 비어 있으면 FK 가 참조하는 부모도 TRUNCATE 된다 (21c·23ai 실행 결과. 19c 미실행)
TRUNCATE TABLE d13_parent;
SELECT COUNT(*) AS parent_after_truncate FROM d13_parent;
INSERT INTO d13_parent SELECT LEVEL FROM dual CONNECT BY LEVEL <= 5;
INSERT INTO d13_child VALUES (1, 1);
COMMIT;

PROMPT == [Q3b] 자식에 행이 있으면 부모 TRUNCATE 불가 -> 오류
-- @expect-error: ORA-02266
TRUNCATE TABLE d13_parent;

PROMPT == [Q4] TRUNCATE 에는 WHERE 가 없다 -> 오류
-- @expect-error: ORA-03291
TRUNCATE TABLE d13_child WHERE id = 1;

PROMPT == [Q5] DROP: 구조까지 삭제. 자식 FK 가 있으면 CASCADE CONSTRAINTS 필요
-- @expect-error: ORA-02449
DROP TABLE d13_parent;
DROP TABLE d13_parent CASCADE CONSTRAINTS PURGE;
SELECT COUNT(*) AS fk_left FROM user_constraints WHERE table_name = 'D13_CHILD' AND constraint_type = 'R';
EXEC lab_drop('D13_CHILD')
