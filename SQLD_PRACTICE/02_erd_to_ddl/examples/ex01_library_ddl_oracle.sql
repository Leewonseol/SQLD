-- ex01 01단원 도서관 논리 ERD -> 물리 테이블 (요구목록 §6 "ERD마다 실제 CREATE TABLE 문을 제시하고 […] 대응표")  | Oracle
-- 업무 규칙 번호(R1~R10)는 01_modeling/explanation.md. 각 제약 위의 주석이 대응 규칙이다.
EXEC lab_drop('L02_WRITING')
EXEC lab_drop('L02_AUTHOR')
EXEC lab_drop('L02_LOAN')
EXEC lab_drop('L02_COPY')
EXEC lab_drop('L02_BOOK')
EXEC lab_drop('L02_CARD')
EXEC lab_drop('L02_MEMBER')
EXEC lab_drop('L02_GRADE')
CREATE TABLE l02_grade (
  grade_cd CHAR(1)            CONSTRAINT pk_l02_grade PRIMARY KEY,
  grade_nm VARCHAR2(10 CHAR)  NOT NULL,
  max_loan NUMBER(2)          NOT NULL CONSTRAINT ck_l02_grade_max CHECK (max_loan BETWEEN 1 AND 10)
);
CREATE TABLE l02_member (
  member_id      NUMBER(8)          CONSTRAINT pk_l02_member PRIMARY KEY,                               -- R1 식별자
  name           VARCHAR2(20 CHAR)  NOT NULL,                                                           -- R1
  phone          VARCHAR2(15)       CONSTRAINT uq_l02_member_phone UNIQUE,                              -- R1 '전화번호는 회원마다 다르다' (대체키)
  grade_cd       CHAR(1)            NOT NULL CONSTRAINT fk_l02_member_grade REFERENCES l02_grade(grade_cd), -- R2 필수
  recommender_id NUMBER(8)          CONSTRAINT fk_l02_member_rec REFERENCES l02_member(member_id),     -- R8 자기참조, 선택
  CONSTRAINT ck_l02_member_rec CHECK (recommender_id <> member_id)                                     -- R8 자기 자신 추천 금지
);
CREATE TABLE l02_card (
  card_no   NUMBER(10) CONSTRAINT pk_l02_card PRIMARY KEY,
  member_id NUMBER(8)  NOT NULL CONSTRAINT uq_l02_card_member UNIQUE                                   -- R9 1:1, 카드 쪽 필수
                       CONSTRAINT fk_l02_card_member REFERENCES l02_member(member_id) ON DELETE CASCADE -- 회원 삭제 시 카드도 삭제
);
CREATE TABLE l02_book (
  isbn  CHAR(13)           CONSTRAINT pk_l02_book PRIMARY KEY,                                         -- R3 본질 식별자
  title VARCHAR2(60 CHAR)  NOT NULL
);
CREATE TABLE l02_copy (
  isbn     CHAR(13)   CONSTRAINT fk_l02_copy_book REFERENCES l02_book(isbn),                           -- R3 식별 관계
  copy_seq NUMBER(4)  CONSTRAINT ck_l02_copy_seq CHECK (copy_seq >= 1),
  CONSTRAINT pk_l02_copy PRIMARY KEY (isbn, copy_seq)
);
CREATE TABLE l02_loan (
  loan_id   NUMBER(10) CONSTRAINT pk_l02_loan PRIMARY KEY,                                             -- R4 인조 식별자
  member_id NUMBER(8)  NOT NULL CONSTRAINT fk_l02_loan_member REFERENCES l02_member(member_id),
  isbn      CHAR(13)   NOT NULL,
  copy_seq  NUMBER(4)  NOT NULL,
  loan_dt   DATE       NOT NULL,                                                                       -- R5
  return_dt DATE,                                                                                      -- R5 반납 전 NULL
  CONSTRAINT fk_l02_loan_copy FOREIGN KEY (isbn, copy_seq) REFERENCES l02_copy (isbn, copy_seq),
  CONSTRAINT ck_l02_loan_dt CHECK (return_dt >= loan_dt)                                               -- R5
);
CREATE TABLE l02_author (author_id NUMBER(6) CONSTRAINT pk_l02_author PRIMARY KEY, author_nm VARCHAR2(30 CHAR) NOT NULL);
CREATE TABLE l02_writing (                                                                             -- R7 M:N 해소
  isbn      CHAR(13)  CONSTRAINT fk_l02_writing_book REFERENCES l02_book(isbn),
  author_id NUMBER(6) CONSTRAINT fk_l02_writing_author REFERENCES l02_author(author_id),
  CONSTRAINT pk_l02_writing PRIMARY KEY (isbn, author_id)
);
INSERT INTO l02_grade VALUES ('N', '일반', 3);
INSERT INTO l02_grade VALUES ('V', '우수', 5);
INSERT INTO l02_member VALUES (1, '가', '010-1', 'N', NULL);
INSERT INTO l02_member VALUES (2, '나', '010-2', 'V', 1);
INSERT INTO l02_book VALUES ('9780000000001', 'SQL 입문');
INSERT INTO l02_copy VALUES ('9780000000001', 1);
INSERT INTO l02_copy VALUES ('9780000000001', 2);
INSERT INTO l02_loan VALUES (1, 1, '9780000000001', 1, DATE '2024-03-01', NULL);
COMMIT;

PROMPT == [T1] 규칙별 위반 INSERT 가 모두 거부되는지 검증 (R1 UNIQUE, R2 NOT NULL, R3 FK, R5 CHECK, R8 CHECK, R9 UNIQUE)
-- @expect-error: ORA-00001, ORA-01400, ORA-02291, ORA-02290
INSERT INTO l02_member VALUES (3, '다', '010-1', 'N', NULL);
INSERT INTO l02_member VALUES (4, '라', '010-4', NULL, NULL);
INSERT INTO l02_loan VALUES (2, 1, '9780000000001', 9, DATE '2024-03-01', NULL);
INSERT INTO l02_loan VALUES (3, 2, '9780000000001', 2, DATE '2024-03-05', DATE '2024-03-01');
INSERT INTO l02_member VALUES (5, '마', '010-5', 'N', 5);
INSERT INTO l02_card VALUES (10, 1);
INSERT INTO l02_card VALUES (11, 1);

PROMPT == [T2] 정상 데이터는 남아 있다
SELECT (SELECT COUNT(*) FROM l02_member) members, (SELECT COUNT(*) FROM l02_loan) loans, (SELECT COUNT(*) FROM l02_card) cards FROM dual;

PROMPT == [T3] 제약조건 목록 (데이터 사전): 유형 P=PK, R=FK, U=UNIQUE, C=CHECK/NOT NULL
SELECT table_name, constraint_type, COUNT(*) cnt FROM user_constraints WHERE table_name LIKE 'L02\_%' ESCAPE '\'
GROUP BY table_name, constraint_type ORDER BY table_name, constraint_type;
ROLLBACK;
