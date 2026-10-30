-- ex01 문자 함수  | SQL Server 2022
PRINT N'== [Q1] LOWER / UPPER (INITCAP 없음)';
SELECT LOWER('SQL Developer') lo, UPPER('SQL Developer') up;
PRINT N'== [Q2] LEN 은 뒤 공백을 세지 않는다. DATALENGTH 는 바이트(NVARCHAR 한글 2바이트)';
SELECT LEN('AB  ') len_trailing, DATALENGTH('AB  ') dlen, LEN(N'홍길동') len_ko, DATALENGTH(N'홍길동') dlen_ko, LEN('') len_empty;
PRINT N'== [Q3] SUBSTRING(문자열, 시작, 길이) - 길이 필수, 음수 시작 없음 -> RIGHT';
SELECT SUBSTRING('SQL Developer', 5, 3) s1, RIGHT('SQL Developer', 3) s2, SUBSTRING('SQL Developer', 5, 100) s3;
PRINT N'== [Q4] CHARINDEX(찾을값, 문자열, 시작) - 인수 순서가 INSTR 와 반대, n번째 지정 없음';
SELECT CHARINDEX('OR', 'CORPORATE FLOOR') i1, CHARINDEX('OR', 'CORPORATE FLOOR', 3) i2_from3, CHARINDEX('XX', 'CORPORATE FLOOR') i3;
PRINT N'== [Q5] TRIM 계열 (2022: LTRIM/RTRIM 두 번째 인수, TRIM LEADING 지원)';
SELECT LTRIM('xxABxx', 'x') l, RTRIM('xxABxx', 'x') r, TRIM('x' FROM 'xxABxx') b,
       TRIM(LEADING 'x' FROM 'xxABxx') lead, '[' + TRIM('  AB  ') + ']' sp;
PRINT N'== [Q6] LPAD/RPAD 없음 -> RIGHT(REPLICATE(...) + 값) / LEFT(값 + REPLICATE(...))';
SELECT RIGHT(REPLICATE('0', 3) + '7', 3) lp, LEFT('AB' + REPLICATE('*', 5), 5) rp, LEFT('ABCDE', 3) cut;
PRINT N'== [Q7] REPLACE / TRANSLATE (2017+). REPLACE 의 세 번째 인수는 필수';
SELECT REPLACE('2024-03-15', '-', '') rep, REPLACE('ABAB', 'B', '') rep_del, TRANSLATE('2024-03-15', '-0', '/o') tr;
PRINT N'== [Q8] CONCAT(인수 여러 개), +, ASCII, CHAR';
SELECT CONCAT('A', 'B', 'C') c3, 'A' + 'B' + 'C' plus, ASCII('A') asc_a, CHAR(66) chr_66;
GO
PRINT N'== [Q9] INITCAP 은 없는 함수 -> 오류';
GO
-- @expect-error: MSG-195
SELECT INITCAP('sql developer');
GO
