-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex05_null_three_valued | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_null_three_valued.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 커미션 500 미만 또는 NULL';
-- comm < 500 만 쓰면 2(ALLEN 300, TURNER 0).
GO
CREATE OR ALTER VIEW ans05_05_g1 (cnt) AS
SELECT COUNT(*) FROM emp WHERE comm < 500 OR comm IS NULL;
GO
CREATE OR ALTER VIEW exp05_05_g1 (cnt) AS
SELECT * FROM (VALUES (12)) v(cnt);
GO
EXEC lab_check N'05-ex05-G1', N'ans05_05_g1', N'exp05_05_g1';
SELECT * FROM ans05_05_g1 ORDER BY 1;
GO

PRINT N'== [G2] 관리자 7698 아님: NULL 제외/포함';
GO
CREATE OR ALTER VIEW ans05_05_g2 (excl_null, incl_null) AS
SELECT (SELECT COUNT(*) FROM emp WHERE mgr <> 7698), (SELECT COUNT(*) FROM emp WHERE mgr <> 7698 OR mgr IS NULL);
GO
CREATE OR ALTER VIEW exp05_05_g2 (excl_null, incl_null) AS
SELECT * FROM (VALUES (8, 9)) v(excl_null, incl_null);
GO
EXEC lab_check N'05-ex05-G2', N'ans05_05_g2', N'exp05_05_g2';
SELECT * FROM ans05_05_g2 ORDER BY 1, 2;
GO
