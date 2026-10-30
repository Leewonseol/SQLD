-- H. 정답 및 검증 | 13 ex02 | Oracle
EXEC lab_drop('D13_G_STOCK')
CREATE TABLE d13_g_stock (item VARCHAR2(10) PRIMARY KEY, qty NUMBER NOT NULL);
INSERT INTO d13_g_stock VALUES ('pen', 10);
INSERT INTO d13_g_stock VALUES ('ink', 5);
COMMIT;
-- [학습자 작성 구간 시작]
MERGE INTO d13_g_stock t
USING (SELECT 'pen' item, 2 qty FROM dual UNION ALL SELECT 'box', 4 FROM dual) s
ON (t.item = s.item)
WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty
WHEN NOT MATCHED THEN INSERT (item, qty) VALUES (s.item, s.qty);
COMMIT;
-- [학습자 작성 구간 끝]
CREATE OR REPLACE VIEW ans13_02_g1 AS SELECT item, qty FROM d13_g_stock;
CREATE OR REPLACE VIEW exp13_02_g1 (item, qty) AS
SELECT 'box', 4 FROM dual UNION ALL SELECT 'ink', 5 FROM dual UNION ALL SELECT 'pen', 12 FROM dual;
EXEC lab_check('13-ex02-G1', 'ANS13_02_G1', 'EXP13_02_G1')
SELECT * FROM ans13_02_g1 ORDER BY item;
