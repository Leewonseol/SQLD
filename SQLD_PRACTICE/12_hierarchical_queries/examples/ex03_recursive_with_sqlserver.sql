-- ex03 재귀 CTE  | SQL Server (RECURSIVE 키워드 없이 WITH, SEARCH·CYCLE 절 없음)
PRINT N'== [Q1] 재귀 CTE';
WITH t (emp_name, mgr_name, lvl, path) AS (
  SELECT emp_name, mgr_name, 1, CAST('/' + emp_name AS VARCHAR(100)) FROM h_emp WHERE mgr_name IS NULL
  UNION ALL
  SELECT c.emp_name, c.mgr_name, t.lvl + 1, CAST(t.path + '/' + c.emp_name AS VARCHAR(100)) FROM h_emp c JOIN t ON c.mgr_name = t.emp_name
)
SELECT emp_name, mgr_name, lvl, path FROM t ORDER BY path;
PRINT N'== [Q2] 깊이 우선 순서: 이름 경로로 정렬';
WITH t (ename, empno, lvl, sortpath) AS (
  SELECT ename, empno, 1, CAST(ename AS VARCHAR(400)) FROM emp WHERE mgr IS NULL
  UNION ALL
  SELECT e.ename, e.empno, t.lvl + 1, CAST(t.sortpath + '/' + e.ename AS VARCHAR(400)) FROM emp e JOIN t ON e.mgr = t.empno
)
SELECT REPLICATE('.', 2 * (lvl - 1)) + ename AS org, lvl FROM t ORDER BY sortpath;
GO
PRINT N'== [Q3] 재귀 부분의 형이 기준 부분과 다르면 오류 (CAST 를 빼면)';
GO
-- @expect-error: MSG-240
WITH t (emp_name, path) AS (
  SELECT emp_name, '/' + emp_name FROM h_emp WHERE mgr_name IS NULL
  UNION ALL
  SELECT c.emp_name, t.path + '/' + c.emp_name FROM h_emp c JOIN t ON c.mgr_name = t.emp_name
)
SELECT * FROM t;
GO
