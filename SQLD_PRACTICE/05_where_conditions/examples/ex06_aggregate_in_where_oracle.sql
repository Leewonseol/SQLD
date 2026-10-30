-- ex06 WHERE 절의 집계함수 금지 (PDF E-06 "집계 함수 사용 불가")  | Oracle
PROMPT == [Q1] WHERE 에 집계함수 -> 오류
-- @expect-error: ORA-00934
SELECT deptno FROM emp WHERE AVG(sal) > 2000 GROUP BY deptno;

PROMPT == [Q2] 그룹 조건은 HAVING 으로
SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal FROM emp GROUP BY deptno HAVING AVG(sal) > 2000 ORDER BY deptno;

PROMPT == [Q3] 전체 집계값과 행을 비교하려면 서브쿼리 (WHERE 안에서 집계는 서브쿼리 안에서만)
SELECT ename, sal FROM emp WHERE sal > (SELECT AVG(sal) FROM emp) ORDER BY sal DESC, ename;
