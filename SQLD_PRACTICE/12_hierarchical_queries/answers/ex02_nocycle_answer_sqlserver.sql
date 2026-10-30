-- =====================================================================
-- H. 정답 및 검증 | 12_hierarchical_queries ex02_nocycle | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_nocycle.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 2000 부터 전개, 순환 표시';
GO
CREATE OR ALTER VIEW ans12_02_g1 (emp_id, lvl, is_cycle) AS
WITH t (emp_id, lvl, path, is_cycle) AS (
 SELECT emp_id, 1, CAST('/' + CAST(emp_id AS VARCHAR(10)) + '/' AS VARCHAR(200)), 0 FROM emp1 WHERE emp_id = 2000
 UNION ALL
 SELECT c.emp_id, t.lvl + 1, CAST(t.path + CAST(c.emp_id AS VARCHAR(10)) + '/' AS VARCHAR(200)),
        CASE WHEN EXISTS (SELECT 1 FROM emp1 g WHERE g.mgr_id = c.emp_id AND t.path LIKE '%/' + CAST(g.emp_id AS VARCHAR(10)) + '/%') THEN 1 ELSE 0 END
 FROM emp1 c JOIN t ON c.mgr_id = t.emp_id WHERE t.path NOT LIKE '%/' + CAST(c.emp_id AS VARCHAR(10)) + '/%')
SELECT emp_id, lvl, is_cycle FROM t;
GO
CREATE OR ALTER VIEW exp12_02_g1 (emp_id, lvl, is_cycle) AS
SELECT * FROM (VALUES (1000, 2, 1),
       (2000, 1, 0)) v(emp_id, lvl, is_cycle);
GO
EXEC lab_check N'12-ex02-G1', N'ans12_02_g1', N'exp12_02_g1';
SELECT * FROM ans12_02_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 서로가 관리자인 쌍의 수';
-- a.emp_id < b.emp_id 를 빼면 (1000,2000)·(2000,1000) 이 둘 다 세어져 2.
GO
CREATE OR ALTER VIEW ans12_02_g2 (pair_cnt) AS
SELECT COUNT(*) FROM emp1 a JOIN emp1 b ON a.mgr_id = b.emp_id AND b.mgr_id = a.emp_id WHERE a.emp_id < b.emp_id;
GO
CREATE OR ALTER VIEW exp12_02_g2 (pair_cnt) AS
SELECT * FROM (VALUES (1)) v(pair_cnt);
GO
EXEC lab_check N'12-ex02-G2', N'ans12_02_g2', N'exp12_02_g2';
SELECT * FROM ans12_02_g2 ORDER BY 1;
GO
