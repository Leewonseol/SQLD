-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex02_grouping_function | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_grouping_function.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부서 소계 행만';
-- GROUPING(deptno) = 0 을 빼면 총계 행(NULL, 14)도 남는다.
GO
CREATE OR ALTER VIEW ans10_02_g1 (deptno, cnt) AS
SELECT deptno, COUNT(*) FROM emp GROUP BY ROLLUP (deptno, job) HAVING GROUPING(job) = 1 AND GROUPING(deptno) = 0;
GO
CREATE OR ALTER VIEW exp10_02_g1 (deptno, cnt) AS
SELECT * FROM (VALUES (10, 3),
       (20, 5),
       (30, 6)) v(deptno, cnt);
GO
EXEC lab_check N'10-ex02-G1', N'ans10_02_g1', N'exp10_02_g1';
SELECT * FROM ans10_02_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 소계·총계·실제 NULL 라벨';
-- SQL Server 에서 ISNULL(breed, N'NULL값') 으로 쓰면 VARCHAR(5) 로 바뀌어 '??' 가 된다 → CHECK_FAIL. CAST 로 형을 먼저 넓힌다.
GO
CREATE OR ALTER VIEW ans10_02_g2 (species, label, s) AS
SELECT species, CASE WHEN GROUPING(species) = 1 THEN N'총계' WHEN GROUPING(breed) = 1 THEN N'소계' ELSE ISNULL(CAST(breed AS NVARCHAR(10)), N'NULL값') END, SUM(cnt)
FROM ah_null GROUP BY ROLLUP (species, breed);
GO
CREATE OR ALTER VIEW exp10_02_g2 (species, label, s) AS
SELECT * FROM (VALUES (N'A', N'x', 1),
       (N'A', N'NULL값', 3),
       (N'A', N'소계', 4),
       (N'B', N'y', 5),
       (N'B', N'소계', 5),
       (NULL, N'총계', 9)) v(species, label, s);
GO
EXEC lab_check N'10-ex02-G2', N'ans10_02_g2', N'exp10_02_g2';
SELECT * FROM ans10_02_g2 ORDER BY 1, 2, 3;
GO
