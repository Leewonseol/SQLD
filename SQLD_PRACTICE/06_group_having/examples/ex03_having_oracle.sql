-- ex03 HAVING (PDF E-06 "GROUP BY department HAVING AVG(salary) > 3000", E-24)  | Oracle
PROMPT == [Q1] HAVING: 그룹 조건. SELECT 에 없는 집계로도 거를 수 있다
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno HAVING MAX(sal) >= 3000 ORDER BY deptno;

PROMPT == [Q2] 그룹 컬럼 조건은 WHERE 와 HAVING 어느 쪽이든 결과가 같다 (WHERE 가 먼저 줄여서 보통 더 효율적)
SELECT deptno, COUNT(*) AS cnt FROM emp WHERE deptno <> 30 GROUP BY deptno ORDER BY deptno;
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno HAVING deptno <> 30 ORDER BY deptno;

PROMPT == [Q3] WHERE 와 HAVING 의 결과가 다른 경우: 급여 조건을 어디에 두는가
SELECT deptno, COUNT(*) AS cnt FROM emp WHERE sal > 1500 GROUP BY deptno ORDER BY deptno;
SELECT deptno, COUNT(*) AS cnt FROM emp GROUP BY deptno HAVING MIN(sal) > 1500 ORDER BY deptno;

PROMPT == [Q4] GROUP BY 없는 HAVING: 테이블 전체가 한 그룹. 조건이 거짓이면 0행
SELECT COUNT(*) AS cnt FROM emp HAVING COUNT(*) > 100;
SELECT COUNT(*) AS cnt FROM emp HAVING COUNT(*) > 10;

PROMPT == [Q5] HAVING 에 그룹 컬럼도 집계도 아닌 컬럼 -> 오류
-- @expect-error: ORA-00979
SELECT deptno, COUNT(*) FROM emp GROUP BY deptno HAVING sal > 1000;
