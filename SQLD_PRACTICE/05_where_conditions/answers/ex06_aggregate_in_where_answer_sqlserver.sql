-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex06_aggregate_in_where | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_aggregate_in_where.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 4명 이상 직무';
GO
CREATE OR ALTER VIEW ans05_06_g1 (job, cnt) AS
SELECT job, COUNT(*) FROM emp GROUP BY job HAVING COUNT(*) >= 4;
GO
CREATE OR ALTER VIEW exp05_06_g1 (job, cnt) AS
SELECT * FROM (VALUES (N'CLERK', 4),
       (N'SALESMAN', 4)) v(job, cnt);
GO
EXEC lab_check N'05-ex06-G1', N'ans05_06_g1', N'exp05_06_g1';
SELECT * FROM ans05_06_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 최고 급여자';
-- WHERE sal = MAX(sal) → ORA-00934 / Msg 147.
GO
CREATE OR ALTER VIEW ans05_06_g2 (ename, sal) AS
SELECT ename, sal FROM emp WHERE sal = (SELECT MAX(sal) FROM emp);
GO
CREATE OR ALTER VIEW exp05_06_g2 (ename, sal) AS
SELECT * FROM (VALUES (N'KING', 5000)) v(ename, sal);
GO
EXEC lab_check N'05-ex06-G2', N'ans05_06_g2', N'exp05_06_g2';
SELECT * FROM ans05_06_g2 ORDER BY 1, 2;
GO
