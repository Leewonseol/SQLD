-- ex01 COMMIT · ROLLBACK · SAVEPOINT 와 DDL 자동 커밋 (PDF E-04 TCL, "DDL: AUTO COMMIT ROLLBACK 불가능")  | Oracle
-- Oracle 은 첫 DML 에서 트랜잭션이 자동으로 시작되고 COMMIT/ROLLBACK 으로 끝난다 (BEGIN 문이 없다).
EXEC lab_drop('D14_ACC')
EXEC lab_drop('D14_TMP')
CREATE TABLE d14_acc (id NUMBER PRIMARY KEY, bal NUMBER NOT NULL);
INSERT INTO d14_acc VALUES (1, 100);
INSERT INTO d14_acc VALUES (2, 100);
COMMIT;

PROMPT == [Q1] ROLLBACK: 마지막 COMMIT 이후의 변경을 모두 취소
UPDATE d14_acc SET bal = bal - 50 WHERE id = 1;
ROLLBACK;
SELECT id, bal FROM d14_acc ORDER BY id;

PROMPT == [Q2] SAVEPOINT: 중간 지점까지만 취소 -> 1번 변경은 남고 2번 변경만 취소
UPDATE d14_acc SET bal = bal - 30 WHERE id = 1;
SAVEPOINT sp1;
UPDATE d14_acc SET bal = bal + 30 WHERE id = 2;
ROLLBACK TO SAVEPOINT sp1;
COMMIT;
SELECT id, bal FROM d14_acc ORDER BY id;

PROMPT == [Q3] DDL 은 실행 직전에 암묵적 COMMIT -> 앞의 INSERT 가 확정되어 ROLLBACK 해도 남는다
INSERT INTO d14_acc VALUES (3, 300);
CREATE TABLE d14_tmp (x NUMBER);
ROLLBACK;
SELECT COUNT(*) AS rows_after_ddl_rollback FROM d14_acc;

PROMPT == [Q4] 실패한 DDL(이미 있는 테이블 생성)도 앞의 트랜잭션을 커밋했는가?
INSERT INTO d14_acc VALUES (4, 400);
-- @expect-error: ORA-00955
CREATE TABLE d14_tmp (x NUMBER);
ROLLBACK;
SELECT COUNT(*) AS rows_after_failed_ddl_rollback FROM d14_acc;

PROMPT == [Q5] 문장 단위 롤백: 트랜잭션 안의 한 문장이 실패해도 앞 문장은 그대로 (트랜잭션은 계속)
UPDATE d14_acc SET bal = 0 WHERE id = 2;
-- @expect-error: ORA-00001
INSERT INTO d14_acc VALUES (1, 999);
COMMIT;
SELECT id, bal FROM d14_acc WHERE id = 2;

PROMPT == [Q6] 존재하지 않는 SAVEPOINT 로 ROLLBACK -> 오류
-- @expect-error: ORA-01086
ROLLBACK TO SAVEPOINT nope;
EXEC lab_drop('D14_ACC')
EXEC lab_drop('D14_TMP')
