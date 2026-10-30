-- H. 정답 및 검증 | 13 ex03 | SQL Server
DROP TABLE IF EXISTS d13_g_book;
-- [학습자 작성 구간 시작]
CREATE TABLE d13_g_book (id INT PRIMARY KEY, title VARCHAR(30) NOT NULL);
ALTER TABLE d13_g_book ADD price INT DEFAULT 0;
EXEC sp_rename 'd13_g_book.title', 'book_title', 'COLUMN';
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans13_03_g1 AS
SELECT LOWER(column_name) AS column_name, CASE is_nullable WHEN 'YES' THEN 'Y' ELSE 'N' END AS nullable FROM information_schema.columns WHERE table_name = 'd13_g_book';
GO
CREATE OR ALTER VIEW exp13_03_g1 (column_name, nullable) AS SELECT * FROM (VALUES ('id', 'N'), ('book_title', 'N'), ('price', 'Y')) v(a, b);
GO
EXEC lab_check N'13-ex03-G1', N'ans13_03_g1', N'exp13_03_g1';
SELECT * FROM ans13_03_g1 ORDER BY 1;
DROP TABLE IF EXISTS d13_g_book;
GO
