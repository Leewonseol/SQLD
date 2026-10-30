-- ex03 다중컬럼 서브쿼리 (PDF E-22 ③ "SQL Server 지원 X", "대소 비교 전달 불가")  | Oracle
PROMPT == [Q1] PDF 예: 부서별 최대 급여자
SELECT empno, ename, sal, deptno FROM emp
WHERE (deptno, sal) IN (SELECT deptno, MAX(sal) FROM emp GROUP BY deptno) ORDER BY deptno, empno;

PROMPT == [Q2] 쌍 비교 vs 컬럼별 비교: (10,CLERK)·(20,ANALYST) 쌍과 같은 사원 / 부서 IN AND 직무 IN
SELECT ename, deptno, job FROM emp WHERE (deptno, job) IN (SELECT deptno, job FROM emp WHERE empno IN (7934, 7788)) ORDER BY empno;
SELECT ename, deptno, job FROM emp WHERE deptno IN (SELECT deptno FROM emp WHERE empno IN (7934, 7788))
  AND job IN (SELECT job FROM emp WHERE empno IN (7934, 7788)) ORDER BY empno;

PROMPT == [Q3] 다중 컬럼 대소 비교 -> 오류 (PDF "두 값을 동시에 묶어서 대소비교할 수 없으니")
-- @expect-error: ORA-01796
SELECT ename FROM emp WHERE (deptno, sal) > (SELECT 10, 1000 FROM dual);
