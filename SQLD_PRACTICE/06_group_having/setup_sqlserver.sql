-- 06_group_having/setup_sqlserver.sql (재실행 가능) 데이터: [가상]  v 는 INT (정수 평균 실험용)
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS g_num, g_empty;
GO
CREATE TABLE g_num (id INT CONSTRAINT pk_g_num PRIMARY KEY, grp VARCHAR(5), v INT);
INSERT INTO g_num VALUES (1, 'a', 1), (2, 'a', 2), (3, 'b', NULL), (4, 'b', 4), (5, NULL, 4);
CREATE TABLE g_empty (v INT);
GO
