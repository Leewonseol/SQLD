-- ex02 MERGE (PDF E-04 "DML: MERGE", 요구목록 §7)  | Oracle
EXEC lab_drop('D13_STOCK')
EXEC lab_drop('D13_STOCK_IN')
CREATE TABLE d13_stock (item VARCHAR2(10) CONSTRAINT pk_d13_stock PRIMARY KEY, qty NUMBER NOT NULL);
CREATE TABLE d13_stock_in (item VARCHAR2(10), qty NUMBER);
INSERT INTO d13_stock VALUES ('pen', 10);
INSERT INTO d13_stock VALUES ('ink', 5);
INSERT INTO d13_stock VALUES ('cap', 1);
INSERT INTO d13_stock_in VALUES ('pen', 3);
INSERT INTO d13_stock_in VALUES ('cap', -1);
INSERT INTO d13_stock_in VALUES ('box', 7);
COMMIT;

PROMPT == [Q1] 있으면 UPDATE, 없으면 INSERT. Oracle 은 ON 조건에 괄호 필수. MATCHED 안의 DELETE WHERE 로 0 이 된 행 삭제
MERGE INTO d13_stock t
USING d13_stock_in s
ON (t.item = s.item)
WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty DELETE WHERE t.qty = 0
WHEN NOT MATCHED THEN INSERT (item, qty) VALUES (s.item, s.qty);
SELECT * FROM d13_stock ORDER BY item;
ROLLBACK;

PROMPT == [Q2] ON 절에 쓴 컬럼을 UPDATE SET 으로 바꾸면 오류
-- @expect-error: ORA-38104
MERGE INTO d13_stock t USING d13_stock_in s ON (t.item = s.item) WHEN MATCHED THEN UPDATE SET t.item = s.item;

PROMPT == [Q3] 원본에 같은 키가 두 번 있으면(대상 1행에 원본 2행이 매칭) 오류
INSERT INTO d13_stock_in VALUES ('pen', 2);
-- @expect-error: ORA-30926
MERGE INTO d13_stock t USING d13_stock_in s ON (t.item = s.item) WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty;
ROLLBACK;
EXEC lab_drop('D13_STOCK')
EXEC lab_drop('D13_STOCK_IN')
