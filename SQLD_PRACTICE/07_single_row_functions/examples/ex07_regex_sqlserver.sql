-- ex07 정규 표현식  | SQL Server 2022 에는 REGEXP_* 함수가 없다 (SQL Server 2025 / Azure SQL 에서 추가됨 — 외부 문서 기준, 이 환경에서 미실행)
PRINT N'== [Q0] REGEXP_LIKE -> 2022 에서는 오류';
GO
-- @expect-error: MSG-195
SELECT id FROM w_code WHERE REGEXP_LIKE(code, '^[0-9]+$');
GO
PRINT N'== [Q1] LIKE 패턴으로 대체: 숫자가 아닌 글자가 하나도 없는 값';
SELECT id, code FROM w_code WHERE code NOT LIKE '%[^0-9]%' AND code <> '' ORDER BY id;
PRINT N'== [Q2] 일부 기능 대체: PATINDEX (첫 숫자 위치), 끝 4자리 마스킹';
SELECT PATINDEX('%[0-9]%', 'ab1c') first_digit_pos, LEFT('010-1234-5678', LEN('010-1234-5678') - 4) + '****' masked;
GO
