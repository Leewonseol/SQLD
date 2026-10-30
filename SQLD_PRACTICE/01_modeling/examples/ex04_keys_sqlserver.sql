-- ex04 키의 종류  | SQL Server
DROP TABLE IF EXISTS m01_student, m01_order;
CREATE TABLE m01_student (stu_no VARCHAR(8) NOT NULL, email VARCHAR(30), name NVARCHAR(10), birth DATE, dept VARCHAR(10));
INSERT INTO m01_student VALUES ('S001', 'a@u.ac', N'김하나', '2004-03-01', 'DB'), ('S002', 'b@u.ac', N'이둘', '2004-03-01', 'DB'),
                               ('S003', 'c@u.ac', N'김하나', '2005-07-07', 'AI'), ('S004', 'd@u.ac', N'박넷', '2004-03-01', 'AI');
GO
PRINT N'== [Q1] 유일성 검사';
SELECT 'stu_no' AS attr, COUNT(*) AS dup_groups FROM (SELECT stu_no FROM m01_student GROUP BY stu_no HAVING COUNT(*) > 1) t
UNION ALL SELECT 'email', COUNT(*) FROM (SELECT email FROM m01_student GROUP BY email HAVING COUNT(*) > 1) t
UNION ALL SELECT 'name', COUNT(*) FROM (SELECT name FROM m01_student GROUP BY name HAVING COUNT(*) > 1) t
UNION ALL SELECT 'birth', COUNT(*) FROM (SELECT birth FROM m01_student GROUP BY birth HAVING COUNT(*) > 1) t
UNION ALL SELECT 'name+birth', COUNT(*) FROM (SELECT name, birth FROM m01_student GROUP BY name, birth HAVING COUNT(*) > 1) t
UNION ALL SELECT 'stu_no+name', COUNT(*) FROM (SELECT stu_no, name FROM m01_student GROUP BY stu_no, name HAVING COUNT(*) > 1) t;
PRINT N'== [Q2] PK 와 대체키(UNIQUE) 지정 (SQL Server 는 PK 컬럼이 미리 NOT NULL 이어야 한다)';
ALTER TABLE m01_student ADD CONSTRAINT pk_m01_student PRIMARY KEY (stu_no);
ALTER TABLE m01_student ADD CONSTRAINT uq_m01_student_email UNIQUE (email);
GO
PRINT N'== [Q3] PK·대체키 위반';
GO
-- @expect-error: MSG-515, MSG-2627
INSERT INTO m01_student VALUES (NULL, 'e@u.ac', N'최다섯', '2004-01-01', 'DB');
GO
INSERT INTO m01_student VALUES ('S005', 'a@u.ac', N'최다섯', '2004-01-01', 'DB');
GO
INSERT INTO m01_student VALUES ('S006', NULL, N'정여섯', '2004-01-01', 'DB');
SELECT COUNT(*) AS rows_now FROM m01_student;
PRINT N'== [Q4] 인조 식별자: IDENTITY';
CREATE TABLE m01_order (order_id INT IDENTITY(1, 1) CONSTRAINT pk_m01_order PRIMARY KEY, cust VARCHAR(10), ordered DATE);
INSERT INTO m01_order (cust, ordered) VALUES ('kim', '2024-01-01'), ('kim', '2024-01-01');
SELECT order_id, cust, ordered FROM m01_order ORDER BY order_id;
DROP TABLE IF EXISTS m01_student, m01_order;
GO
