-- ex01 단일행 서브쿼리 (PDF E-22 ① "서브쿼리의 결과로 1개의 행이 반환, 단일행 비교 연산자 = <> > >= < <=")  | Oracle
PROMPT == [Q1] PDF 예: 평균 급여보다 많이 받는 사원
SELECT empno, ename, sal FROM emp WHERE sal > (SELECT AVG(sal) FROM emp) ORDER BY sal DESC, empno;

PROMPT == [Q2] PDF 예 구조: 강감찬과 같은 팀 선수 (04단원 PLAYER)
SELECT player_name, position, back_no FROM player
WHERE team_id = (SELECT team_id FROM player WHERE player_name = '강감찬') ORDER BY back_no;

PROMPT == [Q3] 서브쿼리가 2행 이상을 돌려주면 단일행 연산자에서 오류
-- @expect-error: ORA-01427
SELECT ename FROM emp WHERE sal = (SELECT sal FROM emp WHERE deptno = 10);

PROMPT == [Q4] 서브쿼리가 0행이면 결과는 NULL -> 비교가 UNKNOWN -> 0행 (오류 아님)
SELECT COUNT(*) AS cnt FROM emp WHERE sal > (SELECT sal FROM emp WHERE ename = 'NOBODY');
