-- ex02 자료형 매핑과 DBMS 차이  | SQL Server (VARCHAR 는 바이트·코드 페이지, NVARCHAR 는 UTF-16 문자 단위)
DROP TABLE IF EXISTS l02_types;
CREATE TABLE l02_types (b VARCHAR(10), c NVARCHAR(10), fixed CHAR(5), num DECIMAL(5,2), dt DATE, dt2 DATETIME2(0));
GO
PRINT N'== [Q1] VARCHAR 에 한글: DB 기본 데이터 정렬(SQL_Latin1_General_CP1_CI_AS)의 코드 페이지 1252 로는 표현 불가 -> ?';
INSERT INTO l02_types (b) VALUES (N'가나다라');
INSERT INTO l02_types (c) VALUES (N'가나다라');
SELECT b, c, LEN(c) chars, DATALENGTH(c) bytes FROM l02_types WHERE b IS NOT NULL OR c IS NOT NULL;
DELETE FROM l02_types;
PRINT N'== [Q2] CHAR 패딩과 비교';
INSERT INTO l02_types (fixed) VALUES ('AB');
SELECT '[' + fixed + ']' AS padded, LEN(fixed) len, DATALENGTH(fixed) dlen FROM l02_types WHERE fixed IS NOT NULL;
SELECT COUNT(*) AS eq_char FROM l02_types WHERE fixed = 'AB';
PRINT N'== [Q3] DECIMAL(5,2): 반올림 / 정수부 초과 오류';
INSERT INTO l02_types (num) VALUES (123.456);
SELECT num FROM l02_types WHERE num IS NOT NULL;
GO
-- @expect-error: MSG-8115
INSERT INTO l02_types (num) VALUES (1234.5);
GO
PRINT N'== [Q4] DATE 는 날짜만, DATETIME2 는 날짜+시각';
INSERT INTO l02_types (dt, dt2) VALUES ('2024-03-15 13:45:10', '2024-03-15 13:45:10');
SELECT dt, dt2 FROM l02_types WHERE dt IS NOT NULL;
PRINT N'== [Q5] 빈 문자열은 NULL 이 아니다';
INSERT INTO l02_types (c) VALUES ('');
SELECT COUNT(*) AS all_rows, COUNT(c) AS non_null_c FROM l02_types;
DROP TABLE IF EXISTS l02_types;
GO
