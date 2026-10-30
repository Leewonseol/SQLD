-- ex06 스칼라 서브쿼리 (PDF E-20)  | Oracle  데이터: [PDF] PAINTINGS·ARTISTS
PROMPT == [Q1] PDF 예: 각 그림의 작가 이름을 스칼라 서브쿼리로 (108 여행은 작가 10번이 없어 NULL)
SELECT p.id, p.name, p.price, (SELECT a.name FROM artists a WHERE a.id = p.artist_id) AS artist_name
FROM paintings p ORDER BY p.id;

PROMPT == [Q2] PDF: "스칼라 서브쿼리는 OUTER JOIN 결과와 같다" -> LEFT JOIN
SELECT p.id, p.name, p.price, a.name AS artist_name FROM paintings p LEFT JOIN artists a ON p.artist_id = a.id ORDER BY p.id;

PROMPT == [Q3] 두 결과가 같은지 집합 연산으로 검증 (차집합 0행이면 같음)
SELECT COUNT(*) AS diff_rows FROM (
  (SELECT p.id, (SELECT a.name FROM artists a WHERE a.id = p.artist_id) n FROM paintings p
   MINUS SELECT p.id, a.name FROM paintings p LEFT JOIN artists a ON p.artist_id = a.id)
  UNION ALL
  (SELECT p.id, a.name FROM paintings p LEFT JOIN artists a ON p.artist_id = a.id
   MINUS SELECT p.id, (SELECT a.name FROM artists a WHERE a.id = p.artist_id) FROM paintings p));

PROMPT == [Q4] PDF 예: 사원 정보와 전체 급여 합계를 한 행에 (집계를 스칼라 값으로)
SELECT empno, ename, deptno, sal, (SELECT SUM(sal) FROM emp) AS total_sal FROM emp WHERE deptno = 10 ORDER BY empno;

PROMPT == [Q5] 스칼라 서브쿼리가 2행 이상을 돌려주면 오류
-- @expect-error: ORA-01427
SELECT d.dname, (SELECT e.ename FROM emp e WHERE e.deptno = d.deptno) AS ename FROM dept d;

PROMPT == [Q6] 스칼라 서브쿼리가 2개 컬럼을 돌려주면 오류
-- @expect-error: ORA-00913
SELECT d.dname, (SELECT MIN(e.sal), MAX(e.sal) FROM emp e WHERE e.deptno = d.deptno) AS x FROM dept d;
