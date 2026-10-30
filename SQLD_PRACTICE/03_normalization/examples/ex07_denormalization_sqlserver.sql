-- ex07 반정규화와 중복 데이터 관리  | SQL Server
DROP TABLE IF EXISTS n03_oline, n03_ord;
CREATE TABLE n03_ord (ord_id INT PRIMARY KEY, total_amt INT NOT NULL DEFAULT 0);
CREATE TABLE n03_oline (ord_id INT REFERENCES n03_ord(ord_id), line_no INT, amt INT NOT NULL, PRIMARY KEY (ord_id, line_no));
INSERT INTO n03_ord (ord_id) VALUES (1);
INSERT INTO n03_oline VALUES (1, 1, 100), (1, 2, 200);
UPDATE o SET total_amt = (SELECT SUM(amt) FROM n03_oline l WHERE l.ord_id = o.ord_id) FROM n03_ord o;
GO
PRINT N'== [Q1] 일치 검사';
SELECT COUNT(*) AS mismatches FROM n03_ord o WHERE o.total_amt <> (SELECT ISNULL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);
PRINT N'== [Q2] 상세만 바꾸면 불일치';
BEGIN TRAN;
UPDATE n03_oline SET amt = 500 WHERE ord_id = 1 AND line_no = 2;
SELECT COUNT(*) AS mismatches FROM n03_ord o WHERE o.total_amt <> (SELECT ISNULL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);
ROLLBACK;
GO
PRINT N'== [Q3] 트리거로 동기화';
GO
CREATE OR ALTER TRIGGER trg_n03_oline_sync ON n03_oline AFTER INSERT, UPDATE, DELETE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE o SET total_amt = ISNULL((SELECT SUM(amt) FROM n03_oline l WHERE l.ord_id = o.ord_id), 0) FROM n03_ord o
  WHERE o.ord_id IN (SELECT ord_id FROM inserted UNION SELECT ord_id FROM deleted);
END;
GO
BEGIN TRAN;
UPDATE n03_oline SET amt = 500 WHERE ord_id = 1 AND line_no = 2;
INSERT INTO n03_oline VALUES (1, 3, 50);
SELECT ord_id, total_amt FROM n03_ord;
SELECT COUNT(*) AS mismatches FROM n03_ord o WHERE o.total_amt <> (SELECT ISNULL(SUM(amt), 0) FROM n03_oline l WHERE l.ord_id = o.ord_id);
ROLLBACK;
DROP TABLE IF EXISTS n03_oline, n03_ord;
GO
