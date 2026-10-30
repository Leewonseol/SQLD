-- 12_hierarchical_queries/setup_sqlserver.sql (재실행 가능)
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS h_emp, emp1;
GO
CREATE TABLE h_emp (emp_name VARCHAR(5) CONSTRAINT pk_h_emp PRIMARY KEY, mgr_name VARCHAR(5) CONSTRAINT fk_h_emp_mgr REFERENCES h_emp(emp_name));
INSERT INTO h_emp VALUES ('A', NULL), ('B', 'A'), ('C', 'A'), ('D', 'C');
CREATE TABLE emp1 (emp_id INT CONSTRAINT pk_emp1 PRIMARY KEY, deptno INT, mgr_id INT, name NVARCHAR(10));
INSERT INTO emp1 VALUES (1000, 10, 2000, N'홍길동'), (2000, 10, 1000, N'강감찬');
GO
