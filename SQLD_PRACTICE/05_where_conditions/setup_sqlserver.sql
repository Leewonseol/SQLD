-- 05_where_conditions/setup_sqlserver.sql  (재실행 가능)  데이터: [가상]
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS w_like, w_ts, w_code;
GO
CREATE TABLE w_like (id INT CONSTRAINT pk_w_like PRIMARY KEY, txt VARCHAR(20));
INSERT INTO w_like VALUES (1, 'A_B'), (2, 'AXB'), (3, 'AB'), (4, '100%'), (5, '1000'), (6, 'ab'), (7, NULL);
CREATE TABLE w_ts (id INT CONSTRAINT pk_w_ts PRIMARY KEY, ts DATETIME2(0));
INSERT INTO w_ts VALUES (1, '2024-03-01 00:00:00'), (2, '2024-03-15 09:30:00'), (3, '2024-03-31 00:00:00'),
                        (4, '2024-03-31 15:00:00'), (5, '2024-04-01 00:00:00');
CREATE TABLE w_code (id INT CONSTRAINT pk_w_code PRIMARY KEY, code VARCHAR(5));
INSERT INTO w_code VALUES (1, '001'), (2, '01'), (3, '1'), (4, '10'), (5, 'A1');
GO
PRINT N'05 setup done';
