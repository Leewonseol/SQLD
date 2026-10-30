-- ex01 계층형 질의  | SQL Server : START WITH / CONNECT BY 가 없다 -> 재귀 CTE (ex03) 로 대체
PRINT N'== [Q0] CONNECT BY 구문 -> 오류';
GO
-- @expect-error: MSG-336
SELECT emp_name FROM h_emp START WITH mgr_name IS NULL CONNECT BY PRIOR emp_name = mgr_name;
GO
PRINT N'== [Q1] 재귀 CTE 로 PDF 결과표 재현: 루트·경로·LEVEL·리프 여부';
WITH t (root_name, path, emp_name, mgr_name, lvl) AS (
  SELECT emp_name, CAST('/' + emp_name AS VARCHAR(100)), emp_name, mgr_name, 1 FROM h_emp WHERE mgr_name IS NULL
  UNION ALL
  SELECT t.root_name, CAST(t.path + '/' + c.emp_name AS VARCHAR(100)), c.emp_name, c.mgr_name, t.lvl + 1
  FROM h_emp c JOIN t ON c.mgr_name = t.emp_name
)
SELECT root_name AS 루트사원, path AS 경로, emp_name AS 사원, mgr_name AS 관리자, lvl,
       CASE WHEN EXISTS (SELECT 1 FROM h_emp x WHERE x.mgr_name = t.emp_name) THEN 0 ELSE 1 END AS is_leaf
FROM t ORDER BY path;
PRINT N'== [Q2] 역방향: D 에서 루트까지';
WITH t (lvl, emp_name, mgr_name, path) AS (
  SELECT 1, emp_name, mgr_name, CAST('/' + emp_name AS VARCHAR(100)) FROM h_emp WHERE emp_name = 'D'
  UNION ALL
  SELECT t.lvl + 1, p.emp_name, p.mgr_name, CAST(t.path + '/' + p.emp_name AS VARCHAR(100)) FROM h_emp p JOIN t ON p.emp_name = t.mgr_name
)
SELECT lvl, emp_name, mgr_name, path FROM t ORDER BY lvl;
GO
