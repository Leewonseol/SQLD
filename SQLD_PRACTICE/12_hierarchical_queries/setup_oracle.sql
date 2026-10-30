-- 12_hierarchical_queries/setup_oracle.sql (재실행 가능)
--   [PDF E-37] H_EMP(사원, 관리자): A(루트) - B, C / C - D
--   [PDF E-37] EMP1 순환 구조: 1000 의 관리자 2000, 2000 의 관리자 1000
EXEC lab_drop('H_EMP')
EXEC lab_drop('EMP1')
CREATE TABLE h_emp (emp_name VARCHAR2(5) CONSTRAINT pk_h_emp PRIMARY KEY, mgr_name VARCHAR2(5) CONSTRAINT fk_h_emp_mgr REFERENCES h_emp(emp_name));
INSERT INTO h_emp VALUES ('A', NULL);
INSERT INTO h_emp VALUES ('B', 'A');
INSERT INTO h_emp VALUES ('C', 'A');
INSERT INTO h_emp VALUES ('D', 'C');
CREATE TABLE emp1 (emp_id NUMBER CONSTRAINT pk_emp1 PRIMARY KEY, deptno NUMBER, mgr_id NUMBER, name VARCHAR2(10 CHAR));
INSERT INTO emp1 VALUES (1000, 10, 2000, '홍길동');
INSERT INTO emp1 VALUES (2000, 10, 1000, '강감찬');
COMMIT;
