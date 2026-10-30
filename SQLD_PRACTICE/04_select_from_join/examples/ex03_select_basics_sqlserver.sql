-- ex03 SELECT·DISTINCT·ALIAS·산술·결합·DUAL  | SQL Server
PRINT N'== [Q1] DISTINCT 한 컬럼';
SELECT DISTINCT job FROM emp ORDER BY job;
PRINT N'== [Q2] DISTINCT 두 컬럼';
SELECT DISTINCT deptno, job FROM emp ORDER BY deptno, job;
PRINT N'== [Q3] 별칭: 대소문자를 바꾸지 않는다, 공백 포함 시 "" 또는 []';
SELECT ename AS 이름, sal monthly, sal * 12 AS "Annual Sal", sal * 12 AS [Annual Sal2] FROM emp WHERE deptno = 10 ORDER BY empno;
PRINT N'== [Q4] NULL 이 섞인 산술 연산 결과는 NULL';
SELECT ename, sal, comm, sal + comm AS sal_plus_comm, sal + ISNULL(comm, 0) AS sal_plus_isnull
FROM emp WHERE deptno = 30 ORDER BY empno;
PRINT N'== [Q5] 문자열 결합: + 는 NULL 이 하나라도 있으면 NULL, CONCAT 은 NULL 을 빈 문자열로';
SELECT ename + '(' + job + ')' AS who, 'X' + NULL AS x_null, CONCAT('X', NULL) AS concat_null,
       CONCAT('A', 'B', 'C') AS concat3
FROM emp WHERE empno = 7369;
GO
PRINT N'== [Q6] FROM 없는 SELECT 가능';
SELECT 1 + 1 AS two;
GO
PRINT N'== [Q7] DUAL 테이블은 없다 -> 오류';
GO
-- @expect-error: MSG-208
SELECT * FROM dual;
GO
