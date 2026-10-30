-- ex03 순위 함수 RANK · DENSE_RANK · ROW_NUMBER (요구목록 §7)  | Oracle
PROMPT == [Q1] 동점 처리 차이: 급여 내림차순 (SCOTT·FORD 3000 동점)
SELECT ename, sal, RANK() OVER (ORDER BY sal DESC) rnk, DENSE_RANK() OVER (ORDER BY sal DESC) drnk,
       ROW_NUMBER() OVER (ORDER BY sal DESC, ename) rn
FROM emp WHERE sal >= 2450 ORDER BY sal DESC, ename;

PROMPT == [Q2] PARTITION BY: 부서 안에서 순위
SELECT deptno, ename, sal, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) dept_rnk FROM emp ORDER BY deptno, dept_rnk, ename;

PROMPT == [Q3] 윈도우 함수는 WHERE 에서 쓸 수 없다 (WHERE 가 SELECT 보다 먼저) -> 오류
-- @expect-error: ORA-30483
SELECT ename FROM emp WHERE RANK() OVER (ORDER BY sal DESC) <= 3;

PROMPT == [Q4] 부서별 TOP 2: 인라인 뷰에서 순위를 만든 뒤 바깥 WHERE 로 거른다 (RANK 는 동점 모두 포함)
SELECT deptno, ename, sal, rnk FROM (
  SELECT deptno, ename, sal, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) rnk FROM emp
) WHERE rnk <= 2 ORDER BY deptno, rnk, ename;

PROMPT == [Q5] ROW_NUMBER 로 부서별 정확히 2명: 동점 중 누가 남는지는 2차 정렬 키가 정한다
SELECT deptno, ename, sal, rn FROM (
  SELECT deptno, ename, sal, ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC, empno) rn FROM emp
) WHERE rn <= 2 ORDER BY deptno, rn;

PROMPT == [Q6] 순위 함수에 ORDER BY 가 없으면 오류
-- @expect-error: ORA-30485
SELECT ename, RANK() OVER (PARTITION BY deptno) FROM emp;
