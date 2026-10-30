-- ex08 HAVING 절 서브쿼리와 UPDATE SET 절 서브쿼리 (PDF E-24, E-25)  | Oracle
PROMPT == [Q1] HAVING 서브쿼리: 평균 급여가 전체 평균보다 높은 부서
SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal FROM emp GROUP BY deptno HAVING AVG(sal) > (SELECT AVG(sal) FROM emp) ORDER BY deptno;

PROMPT == [Q1b] (검증 환경 주의) 21c XE 21.3 에서는 위 Q1 결과가 ORDER BY deptno 와 다른 순서로 나왔다.
PROMPT          실행 계획에 집계 서브쿼리 제거 변환(VW_WIF_1)이 보인다. 이 변환을 끄면 정렬이 맞다. 23ai 계열에서는 정상(ex08_..._oracle23ai.sql).
SELECT /*+ OPT_PARAM('_remove_aggr_subquery' 'false') */ deptno, ROUND(AVG(sal), 2) AS avg_sal
FROM emp GROUP BY deptno HAVING AVG(sal) > (SELECT AVG(sal) FROM emp) ORDER BY deptno;
EXPLAIN PLAN FOR SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal FROM emp GROUP BY deptno HAVING AVG(sal) > (SELECT AVG(sal) FROM emp) ORDER BY deptno;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC'));

PROMPT == [Q2] UPDATE SET 서브쿼리 실험용 복사본 (emp 의 원본은 건드리지 않는다)
EXEC lab_drop('EMP_U')
CREATE TABLE emp_u AS SELECT empno, ename, comm FROM emp WHERE deptno = 30;

PROMPT == [Q3] PDF 의 주의: WHERE 없이 SET comm = (서브쿼리) -> 짝이 없는 행의 comm 이 NULL 로 덮인다
UPDATE emp_u u SET comm = (SELECT b.amt FROM bonus b WHERE b.empno = u.empno);
SELECT empno, ename, comm FROM emp_u ORDER BY empno;
ROLLBACK;

PROMPT == [Q4] 해결: 짝이 있는 행만 갱신 (WHERE EXISTS)
UPDATE emp_u u SET comm = (SELECT b.amt FROM bonus b WHERE b.empno = u.empno)
WHERE EXISTS (SELECT 1 FROM bonus b WHERE b.empno = u.empno);
SELECT empno, ename, comm FROM emp_u ORDER BY empno;
ROLLBACK;

PROMPT == [Q5] 다른 해결: NVL 로 원래 값 유지
UPDATE emp_u u SET comm = NVL((SELECT b.amt FROM bonus b WHERE b.empno = u.empno), u.comm);
SELECT empno, ename, comm FROM emp_u ORDER BY empno;
ROLLBACK;
EXEC lab_drop('EMP_U')
