-- ex02 SELECT 문의 작성 순서와 논리적 처리 순서 (PDF E-05)  | Oracle
PROMPT == [Q1] 작성 순서대로 쓴 쿼리: 급여 1000 이상 사원만 남긴 뒤 부서별로 묶고 3명 이상인 부서만
SELECT deptno, COUNT(*) AS cnt
FROM emp
WHERE sal >= 1000
GROUP BY deptno
HAVING COUNT(*) >= 3
ORDER BY cnt DESC, deptno;

PROMPT == [Q2] SELECT 절 별칭을 WHERE 에서 사용 -> 오류 (WHERE 가 SELECT 보다 먼저 처리된다)
-- @expect-error: ORA-00904
SELECT ename, sal * 12 AS annual FROM emp WHERE annual > 30000;

PROMPT == [Q3] SELECT 절 별칭을 ORDER BY 에서 사용 -> 가능 (ORDER BY 는 SELECT 다음)
SELECT ename, sal * 12 AS annual FROM emp WHERE sal * 12 > 30000 ORDER BY annual DESC, ename;

PROMPT == [Q4] HAVING 을 GROUP BY 앞에 작성 (PDF E-05 "서로 바꿀 수 있으나")
SELECT deptno, COUNT(*) AS cnt FROM emp HAVING COUNT(*) >= 5 GROUP BY deptno ORDER BY deptno;

PROMPT == [Q5] GROUP BY 에 SELECT 별칭 사용 -> 19c/21c 에서는 오류 (23ai 는 허용: ex03_select_basics_oracle23ai.sql)
-- @expect-error: ORA-00904
SELECT deptno AS d, COUNT(*) AS cnt FROM emp GROUP BY d;
