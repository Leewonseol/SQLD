-- ex05 NULL 관련 함수 ISNULL·NULLIF·COALESCE  | SQL Server (NVL·NVL2 없음)
PRINT N'== [Q1] ISNULL(a, b) / NVL2 대체는 CASE 또는 IIF';
SELECT ename, comm, ISNULL(comm, 0) isnull_c, IIF(comm IS NOT NULL, sal + comm, sal) nvl2_pay FROM emp WHERE deptno = 30 ORDER BY empno;
PRINT N'== [Q2] NULLIF / COALESCE';
SELECT NULLIF(10, 10) n1, NULLIF(10, 20) n2, COALESCE(NULL, NULL, 'third') c1;
PRINT N'== [Q3] NULLIF 로 0 나누기 회피';
SELECT ename, sal, comm, ROUND(sal / NULLIF(comm, 0), 2) ratio FROM emp WHERE deptno = 30 ORDER BY empno;
PRINT N'== [Q4] ISNULL(SUM) 과 SUM(ISNULL)';
SELECT ISNULL(SUM(sal), 0) isnull_sum, SUM(ISNULL(sal, 0)) sum_isnull FROM emp WHERE deptno = 40;
PRINT N'== [Q7] ISNULL 은 첫 인수의 자료형으로 결과를 맞춘다 -> 잘림. COALESCE 는 우선순위가 높은 형';
SELECT ISNULL(CAST(NULL AS VARCHAR(2)), 'ABCD') isnull_trunc, COALESCE(CAST(NULL AS VARCHAR(2)), 'ABCD') coalesce_full;
GO
PRINT N'== [Q8] COALESCE 인수가 모두 형 없는 NULL -> 오류';
GO
-- @expect-error: MSG-4127
SELECT COALESCE(NULL, NULL) c2;
GO
PRINT N'== [Q5] 숫자 컬럼에 문자 기본값 -> 오류';
GO
-- @expect-error: MSG-8114
SELECT ISNULL(comm, 'none') FROM emp;
GO
PRINT N'== [Q6] 먼저 문자로 변환';
SELECT ename, ISNULL(CAST(comm AS VARCHAR(10)), 'none') comm_txt FROM emp WHERE deptno = 30 ORDER BY empno;
GO
PRINT N'== [Q9] NVL 은 없는 함수';
GO
-- @expect-error: MSG-195
SELECT NVL(comm, 0) FROM emp;
GO
