-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex04_grouping_sets | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_grouping_sets.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부서·입사연도 소계 + 총계';
GO
CREATE OR ALTER VIEW ans10_04_g1 (deptno, hire_year, cnt) AS
SELECT deptno, YEAR(hiredate), COUNT(*) FROM emp GROUP BY GROUPING SETS (deptno, YEAR(hiredate), ());
GO
CREATE OR ALTER VIEW exp10_04_g1 (deptno, hire_year, cnt) AS
SELECT * FROM (VALUES (10, NULL, 3),
       (20, NULL, 5),
       (30, NULL, 6),
       (NULL, 1980, 1),
       (NULL, 1981, 10),
       (NULL, 1982, 1),
       (NULL, 1987, 2),
       (NULL, NULL, 14)) v(deptno, hire_year, cnt);
GO
EXEC lab_check N'10-ex04-G1', N'ans10_04_g1', N'exp10_04_g1';
SELECT * FROM ans10_04_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] GROUPING SETS((deptno, job), deptno) 행 수';
-- 9 + 3 = 12. ROLLUP(deptno, job) 은 총계까지 13.
GO
CREATE OR ALTER VIEW ans10_04_g2 (cnt) AS
SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY GROUPING SETS ((deptno, job), deptno)) t;
GO
CREATE OR ALTER VIEW exp10_04_g2 (cnt) AS
SELECT * FROM (VALUES (12)) v(cnt);
GO
EXEC lab_check N'10-ex04-G2', N'ans10_04_g2', N'exp10_04_g2';
SELECT * FROM ans10_04_g2 ORDER BY 1;
GO
