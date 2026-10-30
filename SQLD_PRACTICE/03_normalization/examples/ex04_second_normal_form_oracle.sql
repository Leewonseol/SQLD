-- ex04 제2정규형(2NF): 부분 함수 종속 제거 (요구목록 §6)  | Oracle
EXEC lab_drop('N03_ENR2')
EXEC lab_drop('N03_STU2')
EXEC lab_drop('N03_COURSE2')
PROMPT == [Q1] 분해: 학번에만 종속된 속성 -> 학생, 과목코드에만 종속 -> 과목, 키 전체에 종속 -> 수강
CREATE TABLE n03_stu2 AS SELECT DISTINCT stu_no, stu_name, dept, dept_head FROM n03_enroll;
CREATE TABLE n03_course2 AS SELECT DISTINCT course_cd, course_nm FROM n03_enroll;
CREATE TABLE n03_enr2 AS SELECT stu_no, course_cd, grade FROM n03_enroll;
ALTER TABLE n03_stu2 ADD CONSTRAINT pk_n03_stu2 PRIMARY KEY (stu_no);
ALTER TABLE n03_course2 ADD CONSTRAINT pk_n03_course2 PRIMARY KEY (course_cd);
ALTER TABLE n03_enr2 ADD CONSTRAINT pk_n03_enr2 PRIMARY KEY (stu_no, course_cd);
ALTER TABLE n03_enr2 ADD CONSTRAINT fk_n03_enr2_stu FOREIGN KEY (stu_no) REFERENCES n03_stu2(stu_no);
ALTER TABLE n03_enr2 ADD CONSTRAINT fk_n03_enr2_course FOREIGN KEY (course_cd) REFERENCES n03_course2(course_cd);
SELECT (SELECT COUNT(*) FROM n03_stu2) students, (SELECT COUNT(*) FROM n03_course2) courses, (SELECT COUNT(*) FROM n03_enr2) enrolls FROM dual;

PROMPT == [Q2] 무손실 분해 검증: 분해한 테이블을 JOIN 하면 원래 테이블과 정확히 같은가 (양방향 차집합 0)
SELECT COUNT(*) AS diff_rows FROM (
  (SELECT stu_no, stu_name, dept, dept_head, course_cd, course_nm, grade FROM n03_enroll
   MINUS SELECT s.stu_no, s.stu_name, s.dept, s.dept_head, c.course_cd, c.course_nm, e.grade
         FROM n03_enr2 e JOIN n03_stu2 s ON e.stu_no = s.stu_no JOIN n03_course2 c ON e.course_cd = c.course_cd)
  UNION ALL
  (SELECT s.stu_no, s.stu_name, s.dept, s.dept_head, c.course_cd, c.course_nm, e.grade
   FROM n03_enr2 e JOIN n03_stu2 s ON e.stu_no = s.stu_no JOIN n03_course2 c ON e.course_cd = c.course_cd
   MINUS SELECT stu_no, stu_name, dept, dept_head, course_cd, course_nm, grade FROM n03_enroll));

PROMPT == [Q3] 이상 현상 해소: 수강생 없는 새 과목을 등록할 수 있다
INSERT INTO n03_course2 VALUES ('C4', '데이터베이스');
SELECT COUNT(*) AS courses_now FROM n03_course2;
ROLLBACK;
