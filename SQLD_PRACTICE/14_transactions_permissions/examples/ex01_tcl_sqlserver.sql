-- ex01 COMMIT · ROLLBACK · SAVE TRANSACTION 과 DDL 트랜잭션  | SQL Server
-- SQL Server 기본은 자동 커밋 모드: 문장마다 바로 커밋. 여러 문장을 묶으려면 BEGIN TRAN.
DROP TABLE IF EXISTS d14_acc, d14_tmp;
CREATE TABLE d14_acc (id INT PRIMARY KEY, bal INT NOT NULL);
INSERT INTO d14_acc VALUES (1, 100), (2, 100);
GO
PRINT N'== [Q1] 자동 커밋 모드: BEGIN TRAN 없이 UPDATE 하면 바로 확정 -> ROLLBACK 은 오류';
UPDATE d14_acc SET bal = bal - 50 WHERE id = 1;
GO
-- @expect-error: MSG-3903
ROLLBACK;
GO
SELECT id, bal FROM d14_acc ORDER BY id;
UPDATE d14_acc SET bal = 100 WHERE id = 1;
PRINT N'== [Q2] SAVE TRANSACTION / ROLLBACK TRANSACTION 저장점';
BEGIN TRAN;
UPDATE d14_acc SET bal = bal - 30 WHERE id = 1;
SAVE TRANSACTION sp1;
UPDATE d14_acc SET bal = bal + 30 WHERE id = 2;
ROLLBACK TRANSACTION sp1;
COMMIT;
SELECT id, bal FROM d14_acc ORDER BY id;
PRINT N'== [Q3] DDL 도 트랜잭션 안에서 ROLLBACK 된다: INSERT 와 CREATE TABLE 모두 취소';
BEGIN TRAN;
INSERT INTO d14_acc VALUES (3, 300);
CREATE TABLE d14_tmp (x INT);
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback, CASE WHEN OBJECT_ID('d14_tmp') IS NULL THEN 'TABLE ROLLED BACK' ELSE 'TABLE EXISTS' END AS ddl_state FROM d14_acc;
PRINT N'== [Q4] TRUNCATE 도 트랜잭션 안에서 ROLLBACK 된다';
BEGIN TRAN;
TRUNCATE TABLE d14_acc;
SELECT COUNT(*) AS in_tran_after_truncate FROM d14_acc;
ROLLBACK;
SELECT COUNT(*) AS after_rollback FROM d14_acc;
PRINT N'== [Q5] 중첩 트랜잭션: 안쪽 COMMIT 은 @@TRANCOUNT 만 줄인다. 바깥 ROLLBACK 이 전부 취소';
BEGIN TRAN;
UPDATE d14_acc SET bal = 1 WHERE id = 1;
BEGIN TRAN;
SELECT @@TRANCOUNT AS trancount_inner;
COMMIT;
SELECT @@TRANCOUNT AS trancount_after_inner_commit;
ROLLBACK;
SELECT id, bal FROM d14_acc WHERE id = 1;
GO
PRINT N'== [Q6] 문장 단위 롤백 (XACT_ABORT OFF 기본): 실패한 INSERT 만 취소, 앞의 UPDATE 는 커밋됨';
BEGIN TRAN;
UPDATE d14_acc SET bal = 0 WHERE id = 2;
GO
-- @expect-error: MSG-2627
INSERT INTO d14_acc VALUES (1, 999);
GO
COMMIT;
SELECT id, bal FROM d14_acc WHERE id = 2;
UPDATE d14_acc SET bal = 130 WHERE id = 2;
GO
PRINT N'== [Q7] SET XACT_ABORT ON: 오류가 나면 트랜잭션 전체가 롤백된다';
SET XACT_ABORT ON;
BEGIN TRAN;
UPDATE d14_acc SET bal = 0 WHERE id = 2;
INSERT INTO d14_acc VALUES (1, 999);
COMMIT;
GO
SET XACT_ABORT OFF;
SELECT id, bal, @@TRANCOUNT AS trancount FROM d14_acc WHERE id = 2;
GO
PRINT N'== [Q8] IMPLICIT_TRANSACTIONS ON: Oracle 처럼 첫 DML 에서 트랜잭션이 자동 시작';
SET IMPLICIT_TRANSACTIONS ON;
UPDATE d14_acc SET bal = 999 WHERE id = 1;
SELECT @@TRANCOUNT AS trancount_implicit;
ROLLBACK;
SET IMPLICIT_TRANSACTIONS OFF;
SELECT id, bal FROM d14_acc WHERE id = 1;
DROP TABLE IF EXISTS d14_acc, d14_tmp;
GO
