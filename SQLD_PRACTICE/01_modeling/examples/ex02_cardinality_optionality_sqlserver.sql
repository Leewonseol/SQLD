-- ex02 관계의 차수와 선택성 구현  | SQL Server
DROP TABLE IF EXISTS m01_writing, m01_author, m01_copy, m01_book, m01_card, m01_member, m01_grade;
CREATE TABLE m01_grade  (grade_cd CHAR(1) CONSTRAINT pk_m01_grade PRIMARY KEY, grade_nm NVARCHAR(10) NOT NULL);
CREATE TABLE m01_member (member_id INT CONSTRAINT pk_m01_member PRIMARY KEY, name NVARCHAR(20) NOT NULL,
                         grade_cd CHAR(1) NOT NULL CONSTRAINT fk_m01_member_grade REFERENCES m01_grade(grade_cd));
CREATE TABLE m01_card   (card_no INT CONSTRAINT pk_m01_card PRIMARY KEY,
                         member_id INT NOT NULL CONSTRAINT uq_m01_card_member UNIQUE CONSTRAINT fk_m01_card_member REFERENCES m01_member(member_id));
CREATE TABLE m01_book   (isbn VARCHAR(13) CONSTRAINT pk_m01_book PRIMARY KEY, title NVARCHAR(40) NOT NULL);
CREATE TABLE m01_copy   (isbn VARCHAR(13) CONSTRAINT fk_m01_copy_book REFERENCES m01_book(isbn), copy_seq INT,
                         CONSTRAINT pk_m01_copy PRIMARY KEY (isbn, copy_seq));
CREATE TABLE m01_author (author_id INT CONSTRAINT pk_m01_author PRIMARY KEY, author_nm NVARCHAR(20) NOT NULL);
CREATE TABLE m01_writing(isbn VARCHAR(13) CONSTRAINT fk_m01_writing_book REFERENCES m01_book(isbn),
                         author_id INT CONSTRAINT fk_m01_writing_author REFERENCES m01_author(author_id),
                         CONSTRAINT pk_m01_writing PRIMARY KEY (isbn, author_id));
INSERT INTO m01_grade VALUES ('N', N'일반'), ('V', N'우수');
INSERT INTO m01_member VALUES (1, N'가', 'N'), (2, N'나', 'N');
INSERT INTO m01_book VALUES ('9780000000001', N'SQL 입문');
INSERT INTO m01_copy VALUES ('9780000000001', 1), ('9780000000001', 2);
INSERT INTO m01_author VALUES (10, N'김'), (20, N'이');
GO
PRINT N'== [Q1] 자식 쪽 필수';
GO
-- @expect-error: MSG-515, MSG-547
INSERT INTO m01_member VALUES (3, N'다', NULL);
GO
INSERT INTO m01_member VALUES (3, N'다', 'X');
GO
PRINT N'== [Q2] 부모 쪽 선택';
SELECT g.grade_cd, COUNT(m.member_id) AS members FROM m01_grade g LEFT JOIN m01_member m ON m.grade_cd = g.grade_cd GROUP BY g.grade_cd ORDER BY 1;
PRINT N'== [Q3] 1:1';
INSERT INTO m01_card VALUES (100, 1);
GO
-- @expect-error: MSG-2627
INSERT INTO m01_card VALUES (101, 1);
GO
INSERT INTO m01_card VALUES (102, NULL);
GO
PRINT N'== [Q4] M:N';
INSERT INTO m01_writing VALUES ('9780000000001', 10), ('9780000000001', 20);
GO
INSERT INTO m01_writing VALUES ('9780000000001', 10);
GO
SELECT COUNT(*) AS writing_rows FROM m01_writing;
PRINT N'== [Q5] 부모 쪽 필수는 막지 못한다';
INSERT INTO m01_book VALUES ('9780000000002', N'소장본 없는 책');
SELECT b.isbn, COUNT(c.copy_seq) AS copies FROM m01_book b LEFT JOIN m01_copy c ON c.isbn = b.isbn GROUP BY b.isbn ORDER BY 1;
GO
