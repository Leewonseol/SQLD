-- ex05 제3정규형(3NF) (PDF E-01)  | SQL Server
DROP TABLE IF EXISTS n03_emp3, n03_dept3;
PRINT N'== [Q1] 정규화 전';
SELECT emp_no, name, dept_no, dept_name, dept_loc FROM n03_emp_orig ORDER BY emp_no;
PRINT N'== [Q2] 정규화 전 쿼리';
SELECT emp_no, name, dept_name FROM n03_emp_orig WHERE emp_no = '2401';
PRINT N'== [Q3] 3NF 분해';
SELECT DISTINCT dept_no, dept_name, dept_loc INTO n03_dept3 FROM n03_emp_orig;
SELECT emp_no, name, dept_no INTO n03_emp3 FROM n03_emp_orig;
ALTER TABLE n03_dept3 ALTER COLUMN dept_no VARCHAR(3) NOT NULL;
ALTER TABLE n03_dept3 ADD CONSTRAINT pk_n03_dept3 PRIMARY KEY (dept_no);
ALTER TABLE n03_emp3 ADD CONSTRAINT pk_n03_emp3 PRIMARY KEY (emp_no);
ALTER TABLE n03_emp3 ADD CONSTRAINT fk_n03_emp3_dept FOREIGN KEY (dept_no) REFERENCES n03_dept3(dept_no);
PRINT N'== [Q4] 정규화 후 쿼리(조인)';
SELECT a.emp_no, a.name, b.dept_name FROM n03_emp3 a, n03_dept3 b WHERE a.dept_no = b.dept_no AND a.emp_no = '2401';
PRINT N'== [Q5] 무손실 검증';
WITH j AS (SELECT e.emp_no, e.name, e.dept_no, d.dept_name, d.dept_loc FROM n03_emp3 e JOIN n03_dept3 d ON e.dept_no = d.dept_no),
     o AS (SELECT emp_no, name, dept_no, dept_name, dept_loc FROM n03_emp_orig)
SELECT (SELECT COUNT(*) FROM (SELECT * FROM o EXCEPT SELECT * FROM j) a) + (SELECT COUNT(*) FROM (SELECT * FROM j EXCEPT SELECT * FROM o) b) AS diff_rows;
PRINT N'== [Q6] 부서 위치 변경은 한 행만';
BEGIN TRAN;
UPDATE n03_dept3 SET dept_loc = N'대전' WHERE dept_no = '100';
SELECT e.emp_no, d.dept_loc FROM n03_emp3 e JOIN n03_dept3 d ON e.dept_no = d.dept_no WHERE d.dept_no = '100';
ROLLBACK;
GO
