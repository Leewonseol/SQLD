-- ex06 CASE 표현식, IIF, CHOOSE  | SQL Server (DECODE 없음)
PRINT N'== [Q1] 단순 CASE 와 검색 CASE';
SELECT ename, deptno,
       CASE deptno WHEN 10 THEN 'ACC' WHEN 20 THEN 'RES' ELSE 'ETC' END simple_case,
       CASE WHEN sal >= 3000 THEN 'HIGH' WHEN sal >= 1500 THEN 'MID' ELSE 'LOW' END searched_case
FROM emp WHERE empno IN (7369, 7499, 7839, 7902) ORDER BY empno;
PRINT N'== [Q2] 첫 번째 참인 WHEN';
SELECT ename, sal, CASE WHEN sal >= 1000 THEN '1000+' WHEN sal >= 3000 THEN '3000+' END wrong_order
FROM emp WHERE empno IN (7369, 7839) ORDER BY empno;
PRINT N'== [Q3] ELSE 생략';
SELECT ename, CASE WHEN comm > 0 THEN 'Y' END has_comm FROM emp WHERE deptno = 30 ORDER BY empno;
PRINT N'== [Q4] 단순 CASE 와 NULL';
SELECT ename, comm, CASE comm WHEN NULL THEN 'NULL!' ELSE 'not matched' END simple_null,
       CASE WHEN comm IS NULL THEN 'NULL!' ELSE 'value' END searched_null
FROM emp WHERE empno IN (7499, 7698) ORDER BY empno;
PRINT N'== [Q6] IIF(조건, 참, 거짓) / CHOOSE(인덱스, 값1, 값2, ...)';
SELECT ename, IIF(job = 'CLERK', 'C', IIF(job = 'SALESMAN', 'S', 'X')) job_code, CHOOSE(deptno / 10, 'ACC', 'RES', 'SAL') dname_choose
FROM emp WHERE deptno = 30 ORDER BY empno;
GO
PRINT N'== [Q7] CASE 결과 자료형 불일치 -> 문자를 INT 로 바꾸다 실패';
GO
-- @expect-error: MSG-245
SELECT CASE WHEN sal > 1000 THEN 'big' ELSE 0 END FROM emp;
GO
PRINT N'== [Q5] DECODE 는 없는 함수';
GO
-- @expect-error: MSG-195
SELECT DECODE(comm, NULL, 'NULL!', 'value') FROM emp;
GO
