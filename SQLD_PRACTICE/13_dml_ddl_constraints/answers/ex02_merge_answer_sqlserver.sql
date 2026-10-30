-- H. 정답 및 검증 | 13 ex02 | SQL Server
DROP TABLE IF EXISTS d13_g_stock;
CREATE TABLE d13_g_stock (item VARCHAR(10) PRIMARY KEY, qty INT NOT NULL);
INSERT INTO d13_g_stock VALUES ('pen', 10), ('ink', 5);
-- [학습자 작성 구간 시작]
MERGE INTO d13_g_stock AS t
USING (VALUES ('pen', 2), ('box', 4)) AS s (item, qty)
ON t.item = s.item
WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty
WHEN NOT MATCHED THEN INSERT (item, qty) VALUES (s.item, s.qty);
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans13_02_g1 AS SELECT item, qty FROM d13_g_stock;
GO
CREATE OR ALTER VIEW exp13_02_g1 (item, qty) AS SELECT * FROM (VALUES ('box', 4), ('ink', 5), ('pen', 12)) v(a, b);
GO
EXEC lab_check N'13-ex02-G1', N'ans13_02_g1', N'exp13_02_g1';
SELECT * FROM ans13_02_g1 ORDER BY item;
GO
