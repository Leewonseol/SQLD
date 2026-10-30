-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex01_rollup | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_rollup.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부서·직무 인원 ROLLUP';
GO
CREATE OR ALTER VIEW ans10_01_g1 (deptno, job, cnt) AS
SELECT deptno, job, COUNT(*) FROM emp GROUP BY ROLLUP (deptno, job);
GO
CREATE OR ALTER VIEW exp10_01_g1 (deptno, job, cnt) AS
SELECT * FROM (VALUES (10, N'CLERK', 1),
       (10, N'MANAGER', 1),
       (10, N'PRESIDENT', 1),
       (10, NULL, 3),
       (20, N'ANALYST', 2),
       (20, N'CLERK', 2),
       (20, N'MANAGER', 1),
       (20, NULL, 5),
       (30, N'CLERK', 1),
       (30, N'MANAGER', 1),
       (30, N'SALESMAN', 4),
       (30, NULL, 6),
       (NULL, NULL, 14)) v(deptno, job, cnt);
GO
EXEC lab_check N'10-ex01-G1', N'ans10_01_g1', N'exp10_01_g1';
SELECT * FROM ans10_01_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 입사 연도별 급여 합계 + 총계';
GO
CREATE OR ALTER VIEW ans10_01_g2 (hire_year, total) AS
SELECT YEAR(hiredate), SUM(sal) FROM emp GROUP BY ROLLUP (YEAR(hiredate));
GO
CREATE OR ALTER VIEW exp10_01_g2 (hire_year, total) AS
SELECT * FROM (VALUES (1980, 800),
       (1981, 22825),
       (1982, 1300),
       (1987, 4100),
       (NULL, 29025)) v(hire_year, total);
GO
EXEC lab_check N'10-ex01-G2', N'ans10_01_g2', N'exp10_01_g2';
SELECT * FROM ans10_01_g2 ORDER BY 1, 2;
GO
