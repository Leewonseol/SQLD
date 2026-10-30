-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex09_cross_join | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex09_cross_join.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] DEPT x SALGRADE 행 수';
GO
CREATE OR ALTER VIEW ans04_09_g1 (cnt) AS
SELECT COUNT(*) FROM dept CROSS JOIN salgrade;
GO
CREATE OR ALTER VIEW exp04_09_g1 (cnt) AS
SELECT * FROM (VALUES (20)) v(cnt);
GO
EXEC lab_check N'04-ex09-G1', N'ans04_09_g1', N'exp04_09_g1';
SELECT * FROM ans04_09_g1 ORDER BY 1;
GO

PRINT N'== [G2] 부서 x 직무 중 사원이 없는 조합';
-- 4 x 5 = 20 조합 - 실제 존재 조합 9 = 11행. CROSS JOIN 으로 '가능한 모든 경우'를 만든 뒤 NOT EXISTS 로 '실제 있는 것'을 뺀다.
GO
CREATE OR ALTER VIEW ans04_09_g2 (deptno, job) AS
SELECT d.deptno, j.job
FROM dept d CROSS JOIN (SELECT DISTINCT job FROM emp) j
WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno AND e.job = j.job);
GO
CREATE OR ALTER VIEW exp04_09_g2 (deptno, job) AS
SELECT * FROM (VALUES (10, N'ANALYST'),
       (10, N'SALESMAN'),
       (20, N'PRESIDENT'),
       (20, N'SALESMAN'),
       (30, N'ANALYST'),
       (30, N'PRESIDENT'),
       (40, N'ANALYST'),
       (40, N'CLERK'),
       (40, N'MANAGER'),
       (40, N'PRESIDENT'),
       (40, N'SALESMAN')) v(deptno, job);
GO
EXEC lab_check N'04-ex09-G2', N'ans04_09_g2', N'exp04_09_g2';
SELECT * FROM ans04_09_g2 ORDER BY 1, 2;
GO
