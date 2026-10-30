-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex03_cube | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_cube.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] CUBE 의 직무 소계만';
GO
CREATE OR ALTER VIEW ans10_03_g1 (job, cnt) AS
SELECT job, COUNT(*) FROM emp GROUP BY CUBE (deptno, job) HAVING GROUPING(deptno) = 1 AND GROUPING(job) = 0;
GO
CREATE OR ALTER VIEW exp10_03_g1 (job, cnt) AS
SELECT * FROM (VALUES (N'ANALYST', 2),
       (N'CLERK', 4),
       (N'MANAGER', 3),
       (N'PRESIDENT', 1),
       (N'SALESMAN', 4)) v(job, cnt);
GO
EXEC lab_check N'10-ex03-G1', N'ans10_03_g1', N'exp10_03_g1';
SELECT * FROM ans10_03_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] CUBE(deptno, job) 행 수';
GO
CREATE OR ALTER VIEW ans10_03_g2 (cnt) AS
SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY CUBE (deptno, job)) t;
GO
CREATE OR ALTER VIEW exp10_03_g2 (cnt) AS
SELECT * FROM (VALUES (18)) v(cnt);
GO
EXEC lab_check N'10-ex03-G2', N'ans10_03_g2', N'exp10_03_g2';
SELECT * FROM ans10_03_g2 ORDER BY 1;
GO
