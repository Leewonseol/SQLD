-- ex04 키의 종류: 슈퍼키·후보키·기본키·대체키·외래키, 본질·인조 식별자 (요구목록 §6)  | Oracle
-- 데이터로는 "키가 아님"을 반증할 수만 있다. "키임"은 업무 규칙이 정한다(앞으로 들어올 데이터까지 포함).
EXEC lab_drop('M01_STUDENT')
CREATE TABLE m01_student (stu_no VARCHAR2(8), email VARCHAR2(30), name VARCHAR2(10 CHAR), birth DATE, dept VARCHAR2(10));
INSERT INTO m01_student VALUES ('S001', 'a@u.ac', '김하나', DATE '2004-03-01', 'DB');
INSERT INTO m01_student VALUES ('S002', 'b@u.ac', '이둘',   DATE '2004-03-01', 'DB');
INSERT INTO m01_student VALUES ('S003', 'c@u.ac', '김하나', DATE '2005-07-07', 'AI');
INSERT INTO m01_student VALUES ('S004', 'd@u.ac', '박넷',   DATE '2004-03-01', 'AI');
COMMIT;

PROMPT == [Q1] 유일성 검사: 각 속성(조합)에 중복 값이 있는가 (dup_groups 0 이면 현재 데이터에서 유일)
SELECT 'stu_no' AS attr, COUNT(*) AS dup_groups FROM (SELECT stu_no FROM m01_student GROUP BY stu_no HAVING COUNT(*) > 1)
UNION ALL SELECT 'email', COUNT(*) FROM (SELECT email FROM m01_student GROUP BY email HAVING COUNT(*) > 1)
UNION ALL SELECT 'name', COUNT(*) FROM (SELECT name FROM m01_student GROUP BY name HAVING COUNT(*) > 1)
UNION ALL SELECT 'birth', COUNT(*) FROM (SELECT birth FROM m01_student GROUP BY birth HAVING COUNT(*) > 1)
UNION ALL SELECT 'name+birth', COUNT(*) FROM (SELECT name, birth FROM m01_student GROUP BY name, birth HAVING COUNT(*) > 1)
UNION ALL SELECT 'stu_no+name', COUNT(*) FROM (SELECT stu_no, name FROM m01_student GROUP BY stu_no, name HAVING COUNT(*) > 1);

PROMPT == [Q2] 결정: 후보키 = {stu_no}, {email} (유일 + 최소). {stu_no, name} 은 유일하지만 최소가 아니다 = 슈퍼키
PROMPT          {name, birth} 는 지금은 유일하지만 업무상 동명이인·같은 생일이 가능 -> 키가 아니다(데이터가 아니라 규칙으로 판단)
ALTER TABLE m01_student ADD CONSTRAINT pk_m01_student PRIMARY KEY (stu_no);
ALTER TABLE m01_student ADD CONSTRAINT uq_m01_student_email UNIQUE (email);

PROMPT == [Q3] 기본키는 NULL·중복 불가, 대체키(UNIQUE)는 중복 불가·NULL 허용(Oracle)
-- @expect-error: ORA-01400, ORA-00001
INSERT INTO m01_student VALUES (NULL, 'e@u.ac', '최다섯', DATE '2004-01-01', 'DB');
INSERT INTO m01_student VALUES ('S005', 'a@u.ac', '최다섯', DATE '2004-01-01', 'DB');
INSERT INTO m01_student VALUES ('S006', NULL, '정여섯', DATE '2004-01-01', 'DB');
SELECT COUNT(*) AS rows_now FROM m01_student;
ROLLBACK;

PROMPT == [Q4] 인조 식별자: 업무 의미가 없는 일련번호. Oracle 12c+ IDENTITY 컬럼
EXEC lab_drop('M01_ORDER')
CREATE TABLE m01_order (order_id NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_m01_order PRIMARY KEY, cust VARCHAR2(10), ordered DATE);
INSERT INTO m01_order (cust, ordered) VALUES ('kim', DATE '2024-01-01');
INSERT INTO m01_order (cust, ordered) VALUES ('kim', DATE '2024-01-01');
SELECT order_id, cust, ordered FROM m01_order ORDER BY order_id;
PROMPT (본질 식별자 (cust, ordered) 로는 같은 날 두 번 주문을 구별할 수 없어 인조 식별자를 쓴 예)
EXEC lab_drop('M01_ORDER')
EXEC lab_drop('M01_STUDENT')
