-- ex04 변환 함수와 암시적 형변환  | SQL Server
PRINT N'== [Q1] CONVERT(형, 값, 스타일) / FORMAT';
SELECT CONVERT(VARCHAR(19), CAST('2024-03-05 14:07:09' AS DATETIME2(0)), 120) d1,
       CONVERT(CHAR(8), CAST('2024-03-05' AS DATE), 112) d2,
       FORMAT(1234567.891, 'N2') n1, FORMAT(7, '000') n2;
PRINT N'== [Q2] CAST / CONVERT 로 숫자·날짜';
SELECT CAST(REPLACE('1,234.5', ',', '') AS DECIMAL(10,1)) + 1 n, CONVERT(DATE, '20240315', 112) d;
PRINT N'== [Q3] CAST (DECIMAL 로 줄이면 반올림)';
SELECT CAST('123' AS INT) + 1 c1, CAST(CAST('2024-03-15' AS DATE) AS DATETIME2(0)) c2, CAST(12.7 AS DECIMAL(3,0)) c3, CAST(12.7 AS INT) c4;
PRINT N'== [Q4] 암시적 변환: + 는 문자끼리면 결합, 숫자가 섞이면 자료형 우선순위로 숫자';
SELECT '10' + 1 a, '10' + '1' b, CONCAT(10, 1) c;
PRINT N'== [Q5] TRY_CAST / TRY_CONVERT: 실패하면 NULL';
SELECT TRY_CAST('12A' AS INT) t1, TRY_CONVERT(DATE, '2024-13-01') t2;
GO
PRINT N'== [Q6] CAST 실패 -> 오류';
GO
-- @expect-error: MSG-245
SELECT CAST('12A' AS INT);
GO
PRINT N'== [Q7] 잘못된 날짜 문자열 -> 오류';
GO
-- @expect-error: MSG-242
SELECT CAST('2024-13-01' AS DATETIME);
GO
