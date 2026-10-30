-- ex03 식별 관계 vs 비식별 관계  | SQL Server
DROP TABLE IF EXISTS m01_loan_i, m01_loan_n, m01_copy_i, m01_copy_n, m01_book3;
CREATE TABLE m01_book3 (isbn VARCHAR(13) CONSTRAINT pk_m01_book3 PRIMARY KEY);
CREATE TABLE m01_copy_i (isbn VARCHAR(13) CONSTRAINT fk_m01_copy_i REFERENCES m01_book3(isbn), copy_seq INT,
                         CONSTRAINT pk_m01_copy_i PRIMARY KEY (isbn, copy_seq));
CREATE TABLE m01_copy_n (copy_id INT CONSTRAINT pk_m01_copy_n PRIMARY KEY, isbn VARCHAR(13) CONSTRAINT fk_m01_copy_n REFERENCES m01_book3(isbn));
CREATE TABLE m01_loan_i (loan_id INT PRIMARY KEY, isbn VARCHAR(13), copy_seq INT,
                         CONSTRAINT fk_m01_loan_i FOREIGN KEY (isbn, copy_seq) REFERENCES m01_copy_i (isbn, copy_seq));
CREATE TABLE m01_loan_n (loan_id INT PRIMARY KEY, copy_id INT CONSTRAINT fk_m01_loan_n REFERENCES m01_copy_n(copy_id));
INSERT INTO m01_book3 VALUES ('A'), ('B');
GO
PRINT N'== [Q1] 식별 관계: 도서마다 일련번호';
INSERT INTO m01_copy_i VALUES ('A', 1), ('B', 1);
SELECT * FROM m01_copy_i ORDER BY isbn, copy_seq;
GO
PRINT N'== [Q2] 부모 없는 자식 불가';
GO
-- @expect-error: MSG-515
INSERT INTO m01_copy_i VALUES (NULL, 9);
GO
PRINT N'== [Q3] 비식별 관계: FK NULL 허용';
INSERT INTO m01_copy_n VALUES (1, 'A'), (2, NULL);
SELECT * FROM m01_copy_n ORDER BY copy_id;
PRINT N'== [Q4] 손자 테이블 FK 컬럼 수';
SELECT OBJECT_NAME(fk.parent_object_id) AS table_name, COUNT(*) AS fk_columns
FROM sys.foreign_key_columns fk WHERE OBJECT_NAME(fk.parent_object_id) IN ('m01_loan_i', 'm01_loan_n') GROUP BY fk.parent_object_id ORDER BY 1;
DROP TABLE IF EXISTS m01_loan_i, m01_loan_n, m01_copy_i, m01_copy_n, m01_book3;
GO
