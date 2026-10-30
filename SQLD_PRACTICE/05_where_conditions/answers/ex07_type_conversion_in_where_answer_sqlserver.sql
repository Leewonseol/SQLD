-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex07_type_conversion_in_where | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_type_conversion_in_where.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] code = ''10''';
GO
CREATE OR ALTER VIEW ans05_07_g1 (id, code) AS
SELECT id, code FROM w_code WHERE code = '10';
GO
CREATE OR ALTER VIEW exp05_07_g1 (id, code) AS
SELECT * FROM (VALUES (4, N'10')) v(id, code);
GO
EXEC lab_check N'05-ex07-G1', N'ans05_07_g1', N'exp05_07_g1';
SELECT * FROM ans05_07_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 숫자 1 로 해석되는 code 수(오류 없이)';
-- Oracle: TO_NUMBER(... DEFAULT NULL ON CONVERSION ERROR) 는 12.2 이상(19c 포함). VALIDATE_CONVERSION(code AS NUMBER) = 1 로 판별도 가능.
-- SQL Server: TRY_CAST / TRY_CONVERT 는 2012 이상. 변환 실패 시 NULL.
GO
CREATE OR ALTER VIEW ans05_07_g2 (cnt) AS
SELECT COUNT(*) FROM w_code WHERE TRY_CAST(code AS INT) = 1;
GO
CREATE OR ALTER VIEW exp05_07_g2 (cnt) AS
SELECT * FROM (VALUES (3)) v(cnt);
GO
EXEC lab_check N'05-ex07-G2', N'ans05_07_g2', N'exp05_07_g2';
SELECT * FROM ans05_07_g2 ORDER BY 1;
GO
