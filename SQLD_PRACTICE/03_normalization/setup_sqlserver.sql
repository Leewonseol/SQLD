-- 03_normalization/setup_sqlserver.sql (재실행 가능)
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS n03_enroll, n03_emp_orig;
GO
CREATE TABLE n03_enroll (stu_no VARCHAR(5), stu_name NVARCHAR(10), dept VARCHAR(10), dept_head NVARCHAR(10),
                         course_cd VARCHAR(5), course_nm NVARCHAR(10), grade CHAR(1),
                         CONSTRAINT pk_n03_enroll PRIMARY KEY (stu_no, course_cd));
INSERT INTO n03_enroll VALUES ('S1', N'김', 'DB', N'박교수', 'C1', N'SQL', 'A'), ('S1', N'김', 'DB', N'박교수', 'C2', N'모델링', 'B'),
  ('S2', N'이', 'DB', N'박교수', 'C1', N'SQL', 'B'), ('S3', N'최', 'AI', N'정교수', 'C2', N'모델링', 'A'), ('S3', N'최', 'AI', N'정교수', 'C3', N'통계', 'A');
CREATE TABLE n03_emp_orig (emp_no VARCHAR(4) CONSTRAINT pk_n03_emp_orig PRIMARY KEY, name NVARCHAR(10), dept_no VARCHAR(3),
                           dept_name NVARCHAR(10), dept_loc NVARCHAR(10));
INSERT INTO n03_emp_orig VALUES ('2401', N'김지민', '100', N'영업부', N'서울'), ('2402', N'이사원', '101', N'개발부', N'서울'), ('2403', N'유현지', '201', N'생산부', N'부산');
GO
