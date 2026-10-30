-- 09_set_operations/setup_sqlserver.sql (재실행 가능)
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS s_a, s_b, s_c;
GO
CREATE TABLE s_a (v INT);
CREATE TABLE s_b (v INT);
CREATE TABLE s_c (v INT);
INSERT INTO s_a VALUES (1), (2), (2), (NULL);
INSERT INTO s_b VALUES (2), (3), (NULL);
INSERT INTO s_c VALUES (2);
GO
