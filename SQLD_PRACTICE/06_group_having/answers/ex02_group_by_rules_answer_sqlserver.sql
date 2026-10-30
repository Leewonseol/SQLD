-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex02_group_by_rules | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_group_by_rules.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 입사 연도별 인원·최고 급여';
GO
CREATE OR ALTER VIEW ans06_02_g1 (hire_year, cnt, max_sal) AS
SELECT YEAR(hiredate), COUNT(*), MAX(sal) FROM emp GROUP BY YEAR(hiredate);
GO
CREATE OR ALTER VIEW exp06_02_g1 (hire_year, cnt, max_sal) AS
SELECT * FROM (VALUES (1980, 1, 800),
       (1981, 10, 5000),
       (1982, 1, 1300),
       (1987, 2, 3000)) v(hire_year, cnt, max_sal);
GO
EXEC lab_check N'06-ex02-G1', N'ans06_02_g1', N'exp06_02_g1';
SELECT * FROM ans06_02_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 관리자별 부하 수(NULL 그룹 포함)';
-- COUNT(mgr) 로 세면 NULL 그룹이 0 이 된다 → CHECK_FAIL.
GO
CREATE OR ALTER VIEW ans06_02_g2 (mgr, cnt) AS
SELECT mgr, COUNT(*) FROM emp GROUP BY mgr;
GO
CREATE OR ALTER VIEW exp06_02_g2 (mgr, cnt) AS
SELECT * FROM (VALUES (7566, 2),
       (7698, 5),
       (7782, 1),
       (7788, 1),
       (7839, 3),
       (7902, 1),
       (NULL, 1)) v(mgr, cnt);
GO
EXEC lab_check N'06-ex02-G2', N'ans06_02_g2', N'exp06_02_g2';
SELECT * FROM ans06_02_g2 ORDER BY 1, 2;
GO
