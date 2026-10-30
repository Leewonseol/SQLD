-- H. 정답 및 검증 | 14 ex01 | SQL Server
DROP TABLE IF EXISTS d14_g_acc;
CREATE TABLE d14_g_acc (id INT PRIMARY KEY, bal INT);
INSERT INTO d14_g_acc VALUES (1, 100), (2, 100);
-- [학습자 작성 구간 시작]
BEGIN TRAN;
INSERT INTO d14_g_acc VALUES (3, 300);
SAVE TRANSACTION a;
UPDATE d14_g_acc SET bal = 0 WHERE id = 1;
SAVE TRANSACTION b;
DELETE FROM d14_g_acc WHERE id = 2;
ROLLBACK TRANSACTION a;
COMMIT;
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans14_01_g1 AS SELECT id, bal FROM d14_g_acc;
GO
CREATE OR ALTER VIEW exp14_01_g1 (id, bal) AS SELECT * FROM (VALUES (1, 100), (2, 100), (3, 300)) v(a, b);
GO
EXEC lab_check N'14-ex01-G1', N'ans14_01_g1', N'exp14_01_g1';
SELECT * FROM ans14_01_g1 ORDER BY id;
GO
