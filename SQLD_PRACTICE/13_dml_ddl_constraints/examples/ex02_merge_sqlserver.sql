-- ex02 MERGE  | SQL Server (문장 끝 세미콜론 필수, WHEN NOT MATCHED BY SOURCE 지원, MATCHED 안의 DELETE WHERE 대신 AND 조건 분기)
DROP TABLE IF EXISTS d13_stock, d13_stock_in;
CREATE TABLE d13_stock (item VARCHAR(10) CONSTRAINT pk_d13_stock PRIMARY KEY, qty INT NOT NULL);
CREATE TABLE d13_stock_in (item VARCHAR(10), qty INT);
INSERT INTO d13_stock VALUES ('pen', 10), ('ink', 5), ('cap', 1);
INSERT INTO d13_stock_in VALUES ('pen', 3), ('cap', -1), ('box', 7);
GO
PRINT N'== [Q1] MERGE: 합계가 0 이 되는 행은 DELETE, 나머지 UPDATE, 없으면 INSERT';
BEGIN TRAN;
MERGE INTO d13_stock AS t
USING d13_stock_in AS s
ON t.item = s.item
WHEN MATCHED AND t.qty + s.qty = 0 THEN DELETE
WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty
WHEN NOT MATCHED THEN INSERT (item, qty) VALUES (s.item, s.qty);
SELECT * FROM d13_stock ORDER BY item;
ROLLBACK;
PRINT N'== [Q1b] WHEN NOT MATCHED BY SOURCE: 원본에 없는 대상 행(ink) 삭제';
BEGIN TRAN;
MERGE INTO d13_stock AS t USING d13_stock_in AS s ON t.item = s.item
WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty
WHEN NOT MATCHED BY TARGET THEN INSERT (item, qty) VALUES (s.item, s.qty)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
SELECT * FROM d13_stock ORDER BY item;
ROLLBACK;
GO
PRINT N'== [Q2] 세미콜론 없는 MERGE -> 오류';
GO
-- @expect-error: MSG-10713
MERGE INTO d13_stock AS t USING d13_stock_in AS s ON t.item = s.item WHEN MATCHED THEN UPDATE SET t.qty = s.qty
GO
PRINT N'== [Q3] 원본 키 중복 -> 오류';
INSERT INTO d13_stock_in VALUES ('pen', 2);
GO
-- @expect-error: MSG-8672
MERGE INTO d13_stock AS t USING d13_stock_in AS s ON t.item = s.item WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty;
GO
DROP TABLE IF EXISTS d13_stock, d13_stock_in;
GO
