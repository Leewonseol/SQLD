-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex04_logical_order_trace | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_logical_order_trace.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 근무지별 집계 최상위 1곳';
-- 단계별 행 수: FROM·JOIN 14 → WHERE 12(SMITH·JAMES 제외) → GROUP BY 3(NEW YORK 3/8750, DALLAS 4/10075, CHICAGO 5/8450) → HAVING 3 → ORDER BY → 1.
GO
CREATE OR ALTER VIEW ans06_04_g1 (loc, cnt, total) AS
SELECT TOP 1 d.loc, COUNT(*), SUM(e.sal) FROM emp e JOIN dept d ON e.deptno = d.deptno
WHERE e.sal >= 1000 GROUP BY d.loc HAVING COUNT(*) >= 3
ORDER BY SUM(e.sal) DESC;
GO
CREATE OR ALTER VIEW exp06_04_g1 (loc, cnt, total) AS
SELECT * FROM (VALUES (N'DALLAS', 4, 10075)) v(loc, cnt, total);
GO
EXEC lab_check N'06-ex04-G1', N'ans06_04_g1', N'exp06_04_g1';
SELECT * FROM ans06_04_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 직무 내림차순 2~3번째';
-- DISTINCT → ORDER BY → OFFSET/FETCH 순서. 뷰 안의 ORDER BY 는 SQL Server 에서 OFFSET/TOP 이 있을 때만 허용된다.
GO
CREATE OR ALTER VIEW ans06_04_g2 (job) AS
SELECT DISTINCT job FROM emp ORDER BY job DESC OFFSET 1 ROWS FETCH NEXT 2 ROWS ONLY;
GO
CREATE OR ALTER VIEW exp06_04_g2 (job) AS
SELECT * FROM (VALUES (N'MANAGER'),
       (N'PRESIDENT')) v(job);
GO
EXEC lab_check N'06-ex04-G2', N'ans06_04_g2', N'exp06_04_g2';
SELECT * FROM ans06_04_g2 ORDER BY 1;
GO
