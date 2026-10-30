SPEC = {"unit": "09_set_operations", "code": "09", "labs": [
 {"slug": "ex01_union_intersect_minus", "problems": [
  {"title": "사원이 없는 부서", "cols": [("deptno","n")], "rows": [(40,)],
   "oracle": "SELECT deptno FROM dept MINUS SELECT deptno FROM emp",
   "sqlserver": "SELECT deptno FROM dept EXCEPT SELECT deptno FROM emp",
   "note": "SQL Server 에서 MINUS 로 쓰면 오류 없이 dept 전체(4행)와 emp 의 deptno(14행)가 따로 나온다 → 뷰 생성 단계에서 실패하거나 의도와 다른 결과."},
  {"title": "1981 입사 직무 + 3000 이상 직무 (UNION ALL 행 수)", "cols": [("cnt","n")], "rows": [(13,)],
   "oracle": "SELECT COUNT(*) FROM (SELECT job FROM emp WHERE hiredate BETWEEN DATE '1981-01-01' AND DATE '1981-12-31'\n UNION ALL SELECT job FROM emp WHERE sal >= 3000)",
   "sqlserver": "SELECT COUNT(*) FROM (SELECT job FROM emp WHERE hiredate BETWEEN '1981-01-01' AND '1981-12-31'\n UNION ALL SELECT job FROM emp WHERE sal >= 3000) t",
   "note": "1981년 입사 10명 + 3000 이상 3명(SCOTT·KING·FORD) = 13. UNION 이면 중복 직무가 줄어 5종 이하."}]},
 {"slug": "ex02_set_operation_rules", "problems": [
  {"title": "사원명·부서명 한 열 + 출처", "cols": [("name","s"),("src","s")],
   "rows": [("ACCOUNTING","D"),("CLARK","E"),("KING","E"),("MILLER","E")],
   "oracle": "SELECT ename, 'E' FROM emp WHERE deptno = 10 UNION ALL SELECT dname, 'D' FROM dept WHERE deptno = 10"},
  {"title": "숫자와 문자를 문자로 통일한 집합", "cols": [("v","s")], "rows": [("10",),("ACCOUNTING",)],
   "oracle": "SELECT TO_CHAR(deptno) FROM dept WHERE deptno = 10 UNION SELECT dname FROM dept WHERE deptno = 10",
   "sqlserver": "SELECT CAST(deptno AS VARCHAR(14)) FROM dept WHERE deptno = 10 UNION SELECT dname FROM dept WHERE deptno = 10",
   "note": "변환하지 않으면 Oracle ORA-01790, SQL Server Msg 245('ACCOUNTING' 을 TINYINT 로 바꾸다 실패)."}]},
 {"slug": "ex03_set_vs_join", "problems": [
  {"title": "NULL 을 같게 보는 NOT EXISTS", "cols": [("v","n")], "rows": [(1,)],
   "oracle": "SELECT DISTINCT a.v FROM s_a a WHERE NOT EXISTS (SELECT 1 FROM s_b b WHERE b.v = a.v OR (b.v IS NULL AND a.v IS NULL))"},
  {"title": "공통 값 INNER JOIN", "cols": [("v","n")], "rows": [(2,)],
   "oracle": "SELECT DISTINCT a.v FROM s_a a JOIN s_b b ON a.v = b.v",
   "note": "INTERSECT 는 {2, NULL}. JOIN 은 NULL 을 짝짓지 못해 {2}."}]},
]}
