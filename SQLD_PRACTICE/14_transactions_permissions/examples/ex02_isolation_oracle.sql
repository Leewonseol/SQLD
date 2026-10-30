-- ex02 트랜잭션 격리 수준 (요구목록 §7 트랜잭션. 추출본에 격리 수준 본문 없음)  | Oracle
-- 두 세션이 필요한 현상(Dirty Read·블로킹)은 tools/concurrency_demo.py 로 실제 실행한다 -> expected_results/ex02_concurrency_demo.txt
EXEC lab_drop('D14_ISO')
CREATE TABLE d14_iso (id NUMBER PRIMARY KEY, v NUMBER);
INSERT INTO d14_iso VALUES (1, 100);
COMMIT;

PROMPT == [Q1] Oracle 이 지원하는 격리 수준: READ COMMITTED(기본), SERIALIZABLE, 그리고 READ ONLY 트랜잭션
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT v FROM d14_iso;
COMMIT;

PROMPT == [Q2] READ UNCOMMITTED 는 지원하지 않는다 -> 오류
-- @expect-error: ORA-02179
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

PROMPT == [Q3] READ ONLY 트랜잭션에서 DML -> 오류
SET TRANSACTION READ ONLY;
-- @expect-error: ORA-01456
UPDATE d14_iso SET v = 1;
COMMIT;

PROMPT == [Q4] SET TRANSACTION 은 트랜잭션의 첫 문장이어야 한다 -> DML 뒤에 쓰면 오류
UPDATE d14_iso SET v = 101;
-- @expect-error: ORA-01453
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
ROLLBACK;
EXEC lab_drop('D14_ISO')
