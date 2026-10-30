-- ex04 연관(상관) 서브쿼리와 비연관 서브쿼리 (요구목록 §7)  | Oracle
PROMPT == [Q1] 비연관: 서브쿼리가 바깥 쿼리 컬럼을 참조하지 않는다 -> 한 번 계산해 모든 행에 같은 값
SELECT ename, deptno, sal FROM emp WHERE sal > (SELECT AVG(sal) FROM emp) ORDER BY deptno, sal DESC;

PROMPT == [Q2] 연관: 서브쿼리가 바깥 행의 deptno 를 참조 -> 행마다 '자기 부서 평균'과 비교
SELECT e.ename, e.deptno, e.sal FROM emp e
WHERE e.sal > (SELECT AVG(x.sal) FROM emp x WHERE x.deptno = e.deptno) ORDER BY e.deptno, e.sal DESC;

PROMPT == [Q3] 같은 결과를 인라인 뷰 + 조인으로
SELECT e.ename, e.deptno, e.sal FROM emp e
JOIN (SELECT deptno, AVG(sal) avg_sal FROM emp GROUP BY deptno) a ON e.deptno = a.deptno
WHERE e.sal > a.avg_sal ORDER BY e.deptno, e.sal DESC;

PROMPT == [Q4] 연관 조건의 별칭을 빠뜨리면: x.deptno = deptno 는 서브쿼리 자기 컬럼끼리 비교(항상 참) -> 비연관과 같아짐
SELECT e.ename, e.deptno, e.sal FROM emp e
WHERE e.sal > (SELECT AVG(x.sal) FROM emp x WHERE x.deptno = deptno) ORDER BY e.deptno, e.sal DESC;
