-- ex01 단일행 서브쿼리  | SQL Server
PRINT N'== [Q1] 평균보다 많이 받는 사원';
SELECT empno, ename, sal FROM emp WHERE sal > (SELECT AVG(sal) FROM emp) ORDER BY sal DESC, empno;
PRINT N'== [Q2] 강감찬과 같은 팀';
SELECT player_name, position, back_no FROM player
WHERE team_id = (SELECT team_id FROM player WHERE player_name = N'강감찬') ORDER BY back_no;
GO
PRINT N'== [Q3] 서브쿼리 2행 이상 -> 오류';
GO
-- @expect-error: MSG-512
SELECT ename FROM emp WHERE sal = (SELECT sal FROM emp WHERE deptno = 10);
GO
PRINT N'== [Q4] 서브쿼리 0행';
SELECT COUNT(*) AS cnt FROM emp WHERE sal > (SELECT sal FROM emp WHERE ename = 'NOBODY');
GO
