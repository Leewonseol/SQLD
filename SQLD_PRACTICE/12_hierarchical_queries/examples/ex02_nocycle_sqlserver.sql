-- ex02 순환 구조  | SQL Server : 재귀 CTE 는 순환을 스스로 막지 않는다 -> 최대 재귀 횟수(기본 100) 초과 오류
PRINT N'== [Q1] 순환 데이터를 재귀 CTE 로 전개 -> 기본 MAXRECURSION 100 초과 오류';
GO
-- @expect-error: MSG-530
WITH t (emp_id, name, lvl) AS (
  SELECT emp_id, name, 1 FROM emp1 WHERE emp_id = 1000
  UNION ALL
  SELECT c.emp_id, c.name, t.lvl + 1 FROM emp1 c JOIN t ON c.mgr_id = t.emp_id
)
SELECT emp_id, name, lvl FROM t;
GO
PRINT N'== [Q2] 경로 문자열로 순환 감지 (NOCYCLE·CONNECT_BY_ISCYCLE 흉내)';
WITH t (emp_id, name, lvl, path, is_cycle) AS (
  SELECT emp_id, name, 1, CAST('/' + CAST(emp_id AS VARCHAR(10)) + '/' AS VARCHAR(200)), 0 FROM emp1 WHERE emp_id = 1000
  UNION ALL
  SELECT c.emp_id, c.name, t.lvl + 1, CAST(t.path + CAST(c.emp_id AS VARCHAR(10)) + '/' AS VARCHAR(200)),
         CASE WHEN EXISTS (SELECT 1 FROM emp1 g WHERE g.mgr_id = c.emp_id AND t.path LIKE '%/' + CAST(g.emp_id AS VARCHAR(10)) + '/%') THEN 1 ELSE 0 END
  FROM emp1 c JOIN t ON c.mgr_id = t.emp_id
  WHERE t.path NOT LIKE '%/' + CAST(c.emp_id AS VARCHAR(10)) + '/%'
)
SELECT emp_id, name, lvl, is_cycle FROM t ORDER BY lvl;
GO
