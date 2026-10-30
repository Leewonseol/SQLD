-- ex04 제2정규형(2NF)  | SQL Server (SELECT INTO 로 분해)
DROP TABLE IF EXISTS n03_enr2, n03_stu2, n03_course2;
PRINT N'== [Q1] 분해';
SELECT DISTINCT stu_no, stu_name, dept, dept_head INTO n03_stu2 FROM n03_enroll;
SELECT DISTINCT course_cd, course_nm INTO n03_course2 FROM n03_enroll;
SELECT stu_no, course_cd, grade INTO n03_enr2 FROM n03_enroll;
ALTER TABLE n03_stu2 ALTER COLUMN stu_no VARCHAR(5) NOT NULL;
ALTER TABLE n03_course2 ALTER COLUMN course_cd VARCHAR(5) NOT NULL;
ALTER TABLE n03_stu2 ADD CONSTRAINT pk_n03_stu2 PRIMARY KEY (stu_no);
ALTER TABLE n03_course2 ADD CONSTRAINT pk_n03_course2 PRIMARY KEY (course_cd);
ALTER TABLE n03_enr2 ADD CONSTRAINT pk_n03_enr2 PRIMARY KEY (stu_no, course_cd);
ALTER TABLE n03_enr2 ADD CONSTRAINT fk_n03_enr2_stu FOREIGN KEY (stu_no) REFERENCES n03_stu2(stu_no);
ALTER TABLE n03_enr2 ADD CONSTRAINT fk_n03_enr2_course FOREIGN KEY (course_cd) REFERENCES n03_course2(course_cd);
SELECT (SELECT COUNT(*) FROM n03_stu2) students, (SELECT COUNT(*) FROM n03_course2) courses, (SELECT COUNT(*) FROM n03_enr2) enrolls;
PRINT N'== [Q2] 무손실 분해 검증';
WITH j AS (SELECT s.stu_no, s.stu_name, s.dept, s.dept_head, c.course_cd, c.course_nm, e.grade
           FROM n03_enr2 e JOIN n03_stu2 s ON e.stu_no = s.stu_no JOIN n03_course2 c ON e.course_cd = c.course_cd),
     o AS (SELECT stu_no, stu_name, dept, dept_head, course_cd, course_nm, grade FROM n03_enroll)
SELECT (SELECT COUNT(*) FROM (SELECT * FROM o EXCEPT SELECT * FROM j) a) + (SELECT COUNT(*) FROM (SELECT * FROM j EXCEPT SELECT * FROM o) b) AS diff_rows;
PRINT N'== [Q3] 새 과목 등록 가능';
BEGIN TRAN;
INSERT INTO n03_course2 VALUES ('C4', N'데이터베이스');
SELECT COUNT(*) AS courses_now FROM n03_course2;
ROLLBACK;
GO
