SPEC = {"unit": "12_hierarchical_queries", "code": "12", "labs": [
 {"slug": "ex01_connect_by", "problems": [
  {"title": "LEVEL 3 사원", "cols": [("ename","s"),("mgr","n"),("lvl","n")],
   "rows": [("ALLEN",7698,3),("FORD",7566,3),("JAMES",7698,3),("MARTIN",7698,3),("MILLER",7782,3),("SCOTT",7566,3),("TURNER",7698,3),("WARD",7698,3)],
   "oracle": "SELECT ename, mgr, LEVEL FROM emp WHERE LEVEL = 3 START WITH mgr IS NULL CONNECT BY PRIOR empno = mgr",
   "sqlserver": "WITH t (empno, ename, mgr, lvl) AS (SELECT empno, ename, mgr, 1 FROM emp WHERE mgr IS NULL\n UNION ALL SELECT e.empno, e.ename, e.mgr, t.lvl + 1 FROM emp e JOIN t ON e.mgr = t.empno)\nSELECT ename, mgr, lvl FROM t WHERE lvl = 3",
   "note": "LEVEL 조건을 CONNECT BY 쪽(… AND LEVEL <= 3)에 두면 전개 자체를 3단계에서 멈춰 더 효율적이다. 결과 필터는 WHERE."},
  {"title": "JONES 의 모든 부하", "cols": [("ename","s")], "rows": [("ADAMS",),("FORD",),("SCOTT",),("SMITH",)],
   "oracle": "SELECT ename FROM emp WHERE ename <> 'JONES' START WITH ename = 'JONES' CONNECT BY PRIOR empno = mgr",
   "sqlserver": "WITH t (empno, ename) AS (SELECT empno, ename FROM emp WHERE ename = 'JONES'\n UNION ALL SELECT e.empno, e.ename FROM emp e JOIN t ON e.mgr = t.empno)\nSELECT ename FROM t WHERE ename <> 'JONES'",
   "note": "START WITH mgr = (SELECT empno … 'JONES') 로 시작하면 JONES 자신이 빠진 상태로 바로 부하부터 전개할 수도 있다."}]},
 {"slug": "ex02_nocycle", "problems": [
  {"title": "2000 부터 전개, 순환 표시", "cols": [("emp_id","n"),("lvl","n"),("is_cycle","n")],
   "rows": [(1000,2,1),(2000,1,0)],
   "oracle": "SELECT emp_id, LEVEL, CONNECT_BY_ISCYCLE FROM emp1 START WITH emp_id = 2000 CONNECT BY NOCYCLE PRIOR emp_id = mgr_id",
   "sqlserver": "WITH t (emp_id, lvl, path, is_cycle) AS (\n SELECT emp_id, 1, CAST('/' + CAST(emp_id AS VARCHAR(10)) + '/' AS VARCHAR(200)), 0 FROM emp1 WHERE emp_id = 2000\n UNION ALL\n SELECT c.emp_id, t.lvl + 1, CAST(t.path + CAST(c.emp_id AS VARCHAR(10)) + '/' AS VARCHAR(200)),\n        CASE WHEN EXISTS (SELECT 1 FROM emp1 g WHERE g.mgr_id = c.emp_id AND t.path LIKE '%/' + CAST(g.emp_id AS VARCHAR(10)) + '/%') THEN 1 ELSE 0 END\n FROM emp1 c JOIN t ON c.mgr_id = t.emp_id WHERE t.path NOT LIKE '%/' + CAST(c.emp_id AS VARCHAR(10)) + '/%')\nSELECT emp_id, lvl, is_cycle FROM t"},
  {"title": "서로가 관리자인 쌍의 수", "cols": [("pair_cnt","n")], "rows": [(1,)],
   "oracle": "SELECT COUNT(*) FROM emp1 a JOIN emp1 b ON a.mgr_id = b.emp_id AND b.mgr_id = a.emp_id WHERE a.emp_id < b.emp_id",
   "note": "a.emp_id < b.emp_id 를 빼면 (1000,2000)·(2000,1000) 이 둘 다 세어져 2."}]},
 {"slug": "ex03_recursive_with", "problems": [
  {"title": "상위 관리자 수", "cols": [("ename","s"),("mgr_cnt","n")],
   "rows": [("ADAMS",3),("ALLEN",2),("BLAKE",1),("CLARK",1),("FORD",2),("JAMES",2),("JONES",1),("KING",0),("MARTIN",2),("MILLER",2),("SCOTT",2),("SMITH",3),("TURNER",2),("WARD",2)],
   "oracle": "WITH t (empno, ename, d) AS (SELECT empno, ename, 0 FROM emp WHERE mgr IS NULL\n UNION ALL SELECT e.empno, e.ename, t.d + 1 FROM emp e JOIN t ON e.mgr = t.empno)\nSELECT ename, d FROM t"},
  {"title": "BLAKE 조직 급여 합계", "cols": [("total","n")], "rows": [(9400,)],
   "oracle": "WITH t (empno, sal) AS (SELECT empno, sal FROM emp WHERE ename = 'BLAKE'\n UNION ALL SELECT e.empno, e.sal FROM emp e JOIN t ON e.mgr = t.empno)\nSELECT SUM(sal) FROM t",
   "note": "BLAKE 2850 + 부하 5명(ALLEN 1600, WARD 1250, MARTIN 1250, TURNER 1500, JAMES 950) = 9400 = 30번 부서 합계와 같다(이 데이터에서만 우연히 같다)."}]},
]}
