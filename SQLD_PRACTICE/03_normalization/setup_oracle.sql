-- 03_normalization/setup_oracle.sql (재실행 가능)
--   [가상] N03_ENROLL: 정규화 전 수강 테이블(1NF, 복합 PK 학번+과목코드)
--   [PDF E-01] N03_EMP_ORIG: 3차 정규화 전 사원 테이블(사번 2401~2403)
EXEC lab_drop('N03_ENROLL')
EXEC lab_drop('N03_EMP_ORIG')
CREATE TABLE n03_enroll (stu_no VARCHAR2(5), stu_name VARCHAR2(10 CHAR), dept VARCHAR2(10), dept_head VARCHAR2(10 CHAR),
                         course_cd VARCHAR2(5), course_nm VARCHAR2(10 CHAR), grade CHAR(1),
                         CONSTRAINT pk_n03_enroll PRIMARY KEY (stu_no, course_cd));
INSERT INTO n03_enroll VALUES ('S1', '김', 'DB', '박교수', 'C1', 'SQL', 'A');
INSERT INTO n03_enroll VALUES ('S1', '김', 'DB', '박교수', 'C2', '모델링', 'B');
INSERT INTO n03_enroll VALUES ('S2', '이', 'DB', '박교수', 'C1', 'SQL', 'B');
INSERT INTO n03_enroll VALUES ('S3', '최', 'AI', '정교수', 'C2', '모델링', 'A');
INSERT INTO n03_enroll VALUES ('S3', '최', 'AI', '정교수', 'C3', '통계', 'A');
CREATE TABLE n03_emp_orig (emp_no VARCHAR2(4) CONSTRAINT pk_n03_emp_orig PRIMARY KEY, name VARCHAR2(10 CHAR),
                           dept_no VARCHAR2(3), dept_name VARCHAR2(10 CHAR), dept_loc VARCHAR2(10 CHAR));
INSERT INTO n03_emp_orig VALUES ('2401', '김지민', '100', '영업부', '서울');
INSERT INTO n03_emp_orig VALUES ('2402', '이사원', '101', '개발부', '서울');
INSERT INTO n03_emp_orig VALUES ('2403', '유현지', '201', '생산부', '부산');
COMMIT;
