-- ex04 DELETE · TRUNCATE · DROP 비교  | SQL Server (자동 커밋 모드에서는 각 문장이 바로 커밋. 명시적 트랜잭션 안에서는 TRUNCATE 도 ROLLBACK 가능 -> 14단원 ex01)
DROP TABLE IF EXISTS d13_child, d13_parent;
CREATE TABLE d13_parent (id INT CONSTRAINT pk_d13_parent PRIMARY KEY);
CREATE TABLE d13_child (id INT, pid INT CONSTRAINT fk_d13_child REFERENCES d13_parent(id));
INSERT INTO d13_parent VALUES (1), (2), (3), (4), (5);
INSERT INTO d13_child VALUES (1, 1);
GO
PRINT N'== [Q1] DELETE 를 명시적 트랜잭션 안에서 -> ROLLBACK 으로 복구';
BEGIN TRAN;
DELETE FROM d13_child;
SELECT COUNT(*) AS after_delete FROM d13_child;
ROLLBACK;
SELECT COUNT(*) AS after_rollback FROM d13_child;
PRINT N'== [Q2] 자동 커밋 모드의 TRUNCATE: 이미 커밋됨 (ROLLBACK 할 트랜잭션이 없다)';
TRUNCATE TABLE d13_child;
SELECT COUNT(*) AS after_truncate FROM d13_child;
GO
PRINT N'== [Q2b] 트랜잭션 없이 ROLLBACK -> 오류';
GO
-- @expect-error: MSG-3903
ROLLBACK;
GO
PRINT N'== [Q3] FK 가 참조하는 부모 TRUNCATE -> 오류';
GO
-- @expect-error: MSG-4712
TRUNCATE TABLE d13_parent;
GO
PRINT N'== [Q5] 자식 FK 가 있는 부모 DROP -> 오류 (SQL Server 는 CASCADE 옵션이 없다: FK 먼저 삭제)';
GO
-- @expect-error: MSG-3726
DROP TABLE d13_parent;
GO
ALTER TABLE d13_child DROP CONSTRAINT fk_d13_child;
DROP TABLE d13_parent;
DROP TABLE IF EXISTS d13_child;
GO
