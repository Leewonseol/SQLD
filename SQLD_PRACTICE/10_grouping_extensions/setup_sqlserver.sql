-- 10_grouping_extensions/setup_sqlserver.sql (재실행 가능)  age 는 DECIMAL (INT 면 AVG 가 정수가 된다: 06단원 ex01)
USE SQLD_LAB;
GO
IF DB_NAME() <> N'SQLD_LAB' THROW 50000, N'SQLD_LAB DB에서만 실행한다.', 1;
DROP TABLE IF EXISTS animal_hotel, ah_null;
GO
CREATE TABLE animal_hotel (id INT CONSTRAINT pk_animal_hotel PRIMARY KEY, species NVARCHAR(10) NOT NULL,
                           breed NVARCHAR(20) NOT NULL, age DECIMAL(4,1) NOT NULL);
INSERT INTO animal_hotel VALUES (1, N'강아지', N'말티즈', 6), (2, N'강아지', N'말티즈', 6), (3, N'강아지', N'푸들', 7),
  (4, N'강아지', N'푸들', 6), (5, N'고양이', N'샴', 3), (6, N'고양이', N'샴', 4), (7, N'고양이', N'페르시안', 5), (8, N'토끼', N'미니렉스', 2);
CREATE TABLE ah_null (species VARCHAR(5), breed VARCHAR(5), cnt INT);
INSERT INTO ah_null VALUES ('A', 'x', 1), ('A', NULL, 3), ('B', 'y', 5);
GO
