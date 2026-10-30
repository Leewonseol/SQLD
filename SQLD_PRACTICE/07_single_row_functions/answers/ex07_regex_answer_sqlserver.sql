-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex07_regex | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_regex.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 모음 2개 이상 이름';
-- SQL Server: TRANSLATE 로 모음을 # 으로 바꾸고, # 을 지운 길이와의 차이로 모음 수를 센다.
GO
CREATE OR ALTER VIEW ans07_07_g1 (ename) AS
SELECT ename FROM emp WHERE LEN(ename) - LEN(REPLACE(TRANSLATE(ename, 'AEIOU', '#####'), '#', '')) >= 2;
GO
CREATE OR ALTER VIEW exp07_07_g1 (ename) AS
SELECT * FROM (VALUES (N'ADAMS'),
       (N'ALLEN'),
       (N'BLAKE'),
       (N'JAMES'),
       (N'JONES'),
       (N'MARTIN'),
       (N'MILLER'),
       (N'TURNER')) v(ename);
GO
EXEC lab_check N'07-ex07-G1', N'ans07_07_g1', N'exp07_07_g1';
SELECT * FROM ans07_07_g1 ORDER BY 1;
GO

PRINT N'== [G2] 전화번호 가운데 덩어리';
GO
CREATE OR ALTER VIEW ans07_07_g2 (mid) AS
SELECT SUBSTRING('010-1234-5678', CHARINDEX('-', '010-1234-5678') + 1, CHARINDEX('-', '010-1234-5678', CHARINDEX('-', '010-1234-5678') + 1) - CHARINDEX('-', '010-1234-5678') - 1);
GO
CREATE OR ALTER VIEW exp07_07_g2 (mid) AS
SELECT * FROM (VALUES (N'1234')) v(mid);
GO
EXEC lab_check N'07-ex07-G2', N'ans07_07_g2', N'exp07_07_g2';
SELECT * FROM ans07_07_g2 ORDER BY 1;
GO
