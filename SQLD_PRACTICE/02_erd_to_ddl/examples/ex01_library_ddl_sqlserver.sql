-- ex01 도서관 논리 ERD -> 물리 테이블  | SQL Server (자료형: NUMBER->INT/DECIMAL, VARCHAR2->NVARCHAR, DATE->DATE)
DROP TABLE IF EXISTS l02_writing, l02_author, l02_loan, l02_copy, l02_book, l02_card, l02_member, l02_grade;
CREATE TABLE l02_grade (
  grade_cd CHAR(1)      CONSTRAINT pk_l02_grade PRIMARY KEY,
  grade_nm NVARCHAR(10) NOT NULL,
  max_loan TINYINT      NOT NULL CONSTRAINT ck_l02_grade_max CHECK (max_loan BETWEEN 1 AND 10)
);
CREATE TABLE l02_member (
  member_id      INT          CONSTRAINT pk_l02_member PRIMARY KEY,                                   -- R1
  name           NVARCHAR(20) NOT NULL,
  phone          VARCHAR(15)  CONSTRAINT uq_l02_member_phone UNIQUE,                                  -- R1 대체키 (SQL Server: NULL 은 1개만)
  grade_cd       CHAR(1)      NOT NULL CONSTRAINT fk_l02_member_grade REFERENCES l02_grade(grade_cd), -- R2
  recommender_id INT          CONSTRAINT fk_l02_member_rec REFERENCES l02_member(member_id),          -- R8
  CONSTRAINT ck_l02_member_rec CHECK (recommender_id <> member_id)
);
CREATE TABLE l02_card (
  card_no   BIGINT CONSTRAINT pk_l02_card PRIMARY KEY,
  member_id INT    NOT NULL CONSTRAINT uq_l02_card_member UNIQUE
                   CONSTRAINT fk_l02_card_member REFERENCES l02_member(member_id) ON DELETE CASCADE     -- R9
);
CREATE TABLE l02_book (isbn CHAR(13) CONSTRAINT pk_l02_book PRIMARY KEY, title NVARCHAR(60) NOT NULL);
CREATE TABLE l02_copy (
  isbn     CHAR(13) CONSTRAINT fk_l02_copy_book REFERENCES l02_book(isbn),
  copy_seq SMALLINT CONSTRAINT ck_l02_copy_seq CHECK (copy_seq >= 1),
  CONSTRAINT pk_l02_copy PRIMARY KEY (isbn, copy_seq)                                                  -- R3 식별 관계
);
CREATE TABLE l02_loan (
  loan_id   BIGINT   CONSTRAINT pk_l02_loan PRIMARY KEY,
  member_id INT      NOT NULL CONSTRAINT fk_l02_loan_member REFERENCES l02_member(member_id),
  isbn      CHAR(13) NOT NULL,
  copy_seq  SMALLINT NOT NULL,
  loan_dt   DATE     NOT NULL,
  return_dt DATE,
  CONSTRAINT fk_l02_loan_copy FOREIGN KEY (isbn, copy_seq) REFERENCES l02_copy (isbn, copy_seq),
  CONSTRAINT ck_l02_loan_dt CHECK (return_dt >= loan_dt)                                               -- R5
);
CREATE TABLE l02_author (author_id INT CONSTRAINT pk_l02_author PRIMARY KEY, author_nm NVARCHAR(30) NOT NULL);
CREATE TABLE l02_writing (
  isbn      CHAR(13) CONSTRAINT fk_l02_writing_book REFERENCES l02_book(isbn),
  author_id INT      CONSTRAINT fk_l02_writing_author REFERENCES l02_author(author_id),
  CONSTRAINT pk_l02_writing PRIMARY KEY (isbn, author_id)                                              -- R7
);
INSERT INTO l02_grade VALUES ('N', N'일반', 3), ('V', N'우수', 5);
INSERT INTO l02_member VALUES (1, N'가', '010-1', 'N', NULL), (2, N'나', '010-2', 'V', 1);
INSERT INTO l02_book VALUES ('9780000000001', N'SQL 입문');
INSERT INTO l02_copy VALUES ('9780000000001', 1), ('9780000000001', 2);
INSERT INTO l02_loan VALUES (1, 1, '9780000000001', 1, '2024-03-01', NULL);
GO
PRINT N'== [T1] 규칙별 위반 INSERT';
GO
-- @expect-error: MSG-2627, MSG-515, MSG-547
INSERT INTO l02_member VALUES (3, N'다', '010-1', 'N', NULL);
GO
INSERT INTO l02_member VALUES (4, N'라', '010-4', NULL, NULL);
GO
INSERT INTO l02_loan VALUES (2, 1, '9780000000001', 9, '2024-03-01', NULL);
GO
INSERT INTO l02_loan VALUES (3, 2, '9780000000001', 2, '2024-03-05', '2024-03-01');
GO
INSERT INTO l02_member VALUES (5, N'마', '010-5', 'N', 5);
GO
INSERT INTO l02_card VALUES (10, 1);
GO
INSERT INTO l02_card VALUES (11, 1);
GO
PRINT N'== [T2] 정상 데이터';
SELECT (SELECT COUNT(*) FROM l02_member) members, (SELECT COUNT(*) FROM l02_loan) loans, (SELECT COUNT(*) FROM l02_card) cards;
PRINT N'== [T3] 제약조건 목록';
SELECT OBJECT_NAME(parent_object_id) AS table_name, type_desc, COUNT(*) cnt FROM sys.objects
WHERE type IN ('PK', 'F', 'UQ', 'C') AND OBJECT_NAME(parent_object_id) LIKE 'l02[_]%' GROUP BY parent_object_id, type_desc ORDER BY 1, 2;
GO
