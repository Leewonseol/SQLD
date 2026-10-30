-- ex03 제1정규형(1NF)  | SQL Server (STRING_SPLIT 으로 펼치기)
DROP TABLE IF EXISTS n03_hobby_raw, n03_hobby;
PRINT N'== [Q1] 1NF 위반 테이블';
CREATE TABLE n03_hobby_raw (stu_no VARCHAR(5) PRIMARY KEY, hobbies NVARCHAR(50));
INSERT INTO n03_hobby_raw VALUES ('S1', N'SQL,독서'), ('S2', N'NoSQL'), ('S3', N'독서,등산,SQL');
PRINT N'== [Q2] LIKE 함정';
SELECT stu_no FROM n03_hobby_raw WHERE hobbies LIKE '%SQL%' ORDER BY stu_no;
PRINT N'== [Q3] 1NF 로 분해';
CREATE TABLE n03_hobby (stu_no VARCHAR(5), hobby NVARCHAR(20), CONSTRAINT pk_n03_hobby PRIMARY KEY (stu_no, hobby));
INSERT INTO n03_hobby SELECT r.stu_no, s.value FROM n03_hobby_raw r CROSS APPLY STRING_SPLIT(r.hobbies, ',') s;
SELECT stu_no, hobby FROM n03_hobby ORDER BY stu_no, hobby;
PRINT N'== [Q4] 정확한 검색';
SELECT stu_no FROM n03_hobby WHERE hobby = 'SQL' ORDER BY stu_no;
DROP TABLE IF EXISTS n03_hobby_raw, n03_hobby;
GO
