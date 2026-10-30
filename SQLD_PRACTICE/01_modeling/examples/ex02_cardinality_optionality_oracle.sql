-- ex02 관계의 차수(1:1·1:N·M:N)와 선택성(필수·선택)을 제약조건으로 구현하고 검증 (요구목록 §6)  | Oracle
EXEC lab_drop('M01_WRITING')
EXEC lab_drop('M01_AUTHOR')
EXEC lab_drop('M01_COPY')
EXEC lab_drop('M01_BOOK')
EXEC lab_drop('M01_CARD')
EXEC lab_drop('M01_MEMBER')
EXEC lab_drop('M01_GRADE')
CREATE TABLE m01_grade  (grade_cd CHAR(1) CONSTRAINT pk_m01_grade PRIMARY KEY, grade_nm VARCHAR2(10 CHAR) NOT NULL);
-- R2 회원 -> 등급 필수(1:N, 자식 쪽 필수) = FK + NOT NULL
CREATE TABLE m01_member (member_id NUMBER CONSTRAINT pk_m01_member PRIMARY KEY, name VARCHAR2(20 CHAR) NOT NULL,
                         grade_cd CHAR(1) NOT NULL CONSTRAINT fk_m01_member_grade REFERENCES m01_grade(grade_cd));
-- R9 회원 1 : 카드 0..1, 카드 쪽 필수 = FK + NOT NULL + UNIQUE
CREATE TABLE m01_card   (card_no NUMBER CONSTRAINT pk_m01_card PRIMARY KEY,
                         member_id NUMBER NOT NULL CONSTRAINT uq_m01_card_member UNIQUE CONSTRAINT fk_m01_card_member REFERENCES m01_member(member_id));
-- R3·R10 도서 1 : 소장본 1..N (부모 쪽 '최소 1' 은 선언적 제약으로 표현 불가)
CREATE TABLE m01_book   (isbn VARCHAR2(13) CONSTRAINT pk_m01_book PRIMARY KEY, title VARCHAR2(40 CHAR) NOT NULL);
CREATE TABLE m01_copy   (isbn VARCHAR2(13) CONSTRAINT fk_m01_copy_book REFERENCES m01_book(isbn), copy_seq NUMBER,
                         CONSTRAINT pk_m01_copy PRIMARY KEY (isbn, copy_seq));
-- R7 도서 M : 저자 N = 교차 엔터티 + 복합 PK + 두 FK
CREATE TABLE m01_author (author_id NUMBER CONSTRAINT pk_m01_author PRIMARY KEY, author_nm VARCHAR2(20 CHAR) NOT NULL);
CREATE TABLE m01_writing(isbn VARCHAR2(13) CONSTRAINT fk_m01_writing_book REFERENCES m01_book(isbn),
                         author_id NUMBER CONSTRAINT fk_m01_writing_author REFERENCES m01_author(author_id),
                         CONSTRAINT pk_m01_writing PRIMARY KEY (isbn, author_id));
INSERT INTO m01_grade VALUES ('N', '일반');
INSERT INTO m01_grade VALUES ('V', '우수');
INSERT INTO m01_member VALUES (1, '가', 'N');
INSERT INTO m01_member VALUES (2, '나', 'N');
INSERT INTO m01_book VALUES ('9780000000001', 'SQL 입문');
INSERT INTO m01_copy VALUES ('9780000000001', 1);
INSERT INTO m01_copy VALUES ('9780000000001', 2);
INSERT INTO m01_author VALUES (10, '김');
INSERT INTO m01_author VALUES (20, '이');
COMMIT;

PROMPT == [Q1] 1:N 자식 쪽 필수: 등급 없는 회원 -> NOT NULL 위반 / 없는 등급 -> FK 위반
-- @expect-error: ORA-01400, ORA-02291
INSERT INTO m01_member VALUES (3, '다', NULL);
INSERT INTO m01_member VALUES (3, '다', 'X');

PROMPT == [Q2] 1:N 부모 쪽 선택: 회원이 없는 등급 'V' 는 존재할 수 있다
SELECT g.grade_cd, COUNT(m.member_id) AS members FROM m01_grade g LEFT JOIN m01_member m ON m.grade_cd = g.grade_cd GROUP BY g.grade_cd ORDER BY 1;

PROMPT == [Q3] 1:1 : 같은 회원에게 카드 두 번째 -> UNIQUE 위반 / 회원 없는 카드 -> NOT NULL 위반
INSERT INTO m01_card VALUES (100, 1);
-- @expect-error: ORA-00001
INSERT INTO m01_card VALUES (101, 1);
INSERT INTO m01_card VALUES (102, NULL);

PROMPT == [Q4] M:N : 한 도서에 저자 2명, 같은 (도서, 저자) 쌍 중복은 PK 위반
INSERT INTO m01_writing VALUES ('9780000000001', 10);
INSERT INTO m01_writing VALUES ('9780000000001', 20);
INSERT INTO m01_writing VALUES ('9780000000001', 10);
SELECT COUNT(*) AS writing_rows FROM m01_writing;

PROMPT == [Q5] 부모 쪽 필수(R10: 도서는 소장본이 최소 1권)는 막지 못한다 -> 소장본 없는 도서가 들어간다
INSERT INTO m01_book VALUES ('9780000000002', '소장본 없는 책');
SELECT b.isbn, COUNT(c.copy_seq) AS copies FROM m01_book b LEFT JOIN m01_copy c ON c.isbn = b.isbn GROUP BY b.isbn ORDER BY 1;
ROLLBACK;
