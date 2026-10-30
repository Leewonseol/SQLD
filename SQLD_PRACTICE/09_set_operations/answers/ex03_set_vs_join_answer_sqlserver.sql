-- =====================================================================
-- H. 정답 및 검증 | 09_set_operations ex03_set_vs_join | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_set_vs_join.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] NULL 을 같게 보는 NOT EXISTS';
GO
CREATE OR ALTER VIEW ans09_03_g1 (v) AS
SELECT DISTINCT a.v FROM s_a a WHERE NOT EXISTS (SELECT 1 FROM s_b b WHERE b.v = a.v OR (b.v IS NULL AND a.v IS NULL));
GO
CREATE OR ALTER VIEW exp09_03_g1 (v) AS
SELECT * FROM (VALUES (1)) v(v);
GO
EXEC lab_check N'09-ex03-G1', N'ans09_03_g1', N'exp09_03_g1';
SELECT * FROM ans09_03_g1 ORDER BY 1;
GO

PRINT N'== [G2] 공통 값 INNER JOIN';
-- INTERSECT 는 {2, NULL}. JOIN 은 NULL 을 짝짓지 못해 {2}.
GO
CREATE OR ALTER VIEW ans09_03_g2 (v) AS
SELECT DISTINCT a.v FROM s_a a JOIN s_b b ON a.v = b.v;
GO
CREATE OR ALTER VIEW exp09_03_g2 (v) AS
SELECT * FROM (VALUES (2)) v(v);
GO
EXEC lab_check N'09-ex03-G2', N'ans09_03_g2', N'exp09_03_g2';
SELECT * FROM ans09_03_g2 ORDER BY 1;
GO
