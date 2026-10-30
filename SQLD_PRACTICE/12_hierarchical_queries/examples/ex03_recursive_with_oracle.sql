-- ex03 재귀 WITH (Oracle 11gR2+) — SQL Server 와 공통인 표준 방식, SEARCH·CYCLE 절  | Oracle
PROMPT == [Q1] 재귀 WITH 로 CONNECT BY 와 같은 결과 (열 이름 목록 필수)
WITH t (emp_name, mgr_name, lvl, path) AS (
  SELECT emp_name, mgr_name, 1, '/' || emp_name FROM h_emp WHERE mgr_name IS NULL
  UNION ALL
  SELECT c.emp_name, c.mgr_name, t.lvl + 1, t.path || '/' || c.emp_name FROM h_emp c JOIN t ON c.mgr_name = t.emp_name
)
SELECT emp_name, mgr_name, lvl, path FROM t ORDER BY path;

PROMPT == [Q2] SEARCH DEPTH FIRST BY (ORDER SIBLINGS BY 와 같은 깊이 우선 순서)
WITH t (ename, empno, lvl) AS (
  SELECT ename, empno, 1 FROM emp WHERE mgr IS NULL
  UNION ALL
  SELECT e.ename, e.empno, t.lvl + 1 FROM emp e JOIN t ON e.mgr = t.empno
) SEARCH DEPTH FIRST BY ename SET ord
SELECT LPAD(' ', 2 * (lvl - 1), '.') || ename AS org, lvl FROM t ORDER BY ord;

PROMPT == [Q3] CYCLE 절로 순환 감지 (EMP1)
WITH t (emp_id, name, lvl) AS (
  SELECT emp_id, name, 1 FROM emp1 WHERE emp_id = 1000
  UNION ALL
  SELECT c.emp_id, c.name, t.lvl + 1 FROM emp1 c JOIN t ON c.mgr_id = t.emp_id
) CYCLE emp_id SET is_cycle TO 'Y' DEFAULT 'N'
SELECT emp_id, name, lvl, is_cycle FROM t ORDER BY lvl;
