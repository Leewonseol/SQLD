-- ex02 집합 연산의 규칙  | SQL Server
PRINT N'== [Q1] 결과 컬럼명은 첫 번째 SELECT';
SELECT ename AS first_name, sal FROM emp WHERE empno = 7369
UNION ALL
SELECT dname AS second_name, deptno FROM dept WHERE deptno = 10;
PRINT N'== [Q2] ORDER BY 는 맨 끝에 한 번';
SELECT ename AS nm, sal FROM emp WHERE deptno = 10 UNION ALL SELECT dname, deptno FROM dept ORDER BY nm;
GO
PRINT N'== [Q3] 두 번째 SELECT 별칭으로 정렬 -> 오류';
GO
-- @expect-error: MSG-207, MSG-104
SELECT ename AS nm FROM emp WHERE deptno = 10 UNION ALL SELECT dname AS dn FROM dept ORDER BY dn;
GO
PRINT N'== [Q4] 컬럼 수 불일치 -> 오류';
GO
-- @expect-error: MSG-205
SELECT ename, sal FROM emp UNION SELECT dname FROM dept;
GO
PRINT N'== [Q5] 문자 vs 숫자: SQL Server 는 숫자 쪽으로 변환을 시도 -> 실패';
GO
-- @expect-error: MSG-245
SELECT ename FROM emp UNION SELECT deptno FROM dept;
GO
PRINT N'== [Q6] 연산자 우선순위: SQL Server 는 INTERSECT 가 먼저 -> A UNION (B INTERSECT C)';
SELECT v FROM s_a UNION SELECT v FROM s_b INTERSECT SELECT v FROM s_c ORDER BY 1;
PRINT N'== [Q6b] 괄호로 Oracle 과 같은 의미 만들기';
(SELECT v FROM s_a UNION SELECT v FROM s_b) INTERSECT SELECT v FROM s_c ORDER BY 1;
GO
PRINT N'== [Q7] 각 SELECT 안의 ORDER BY -> 오류';
GO
-- @expect-error: MSG-156
SELECT ename FROM emp WHERE deptno = 10 ORDER BY ename UNION SELECT dname FROM dept;
GO
