-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex02_in_not_in | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_in_not_in.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 관리자 7566·7788·NULL';
-- IN (7566, 7788, NULL) 로 쓰면 KING 이 빠진다.
GO
CREATE OR ALTER VIEW ans05_02_g1 (ename, mgr) AS
SELECT ename, mgr FROM emp WHERE mgr IN (7566, 7788) OR mgr IS NULL;
GO
CREATE OR ALTER VIEW exp05_02_g1 (ename, mgr) AS
SELECT * FROM (VALUES (N'ADAMS', 7788),
       (N'FORD', 7566),
       (N'KING', NULL),
       (N'SCOTT', 7566)) v(ename, mgr);
GO
EXEC lab_check N'05-ex02-G1', N'ans05_02_g1', N'exp05_02_g1';
SELECT * FROM ans05_02_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 관리자가 7698 이 아닌 사원(NULL 포함)';
-- Oracle 은 NVL(mgr, 0) <> 7698, SQL Server 는 ISNULL(mgr, 0) <> 7698 도 가능(0 이 실제 사번이 아니라는 가정).
GO
CREATE OR ALTER VIEW ans05_02_g2 (ename) AS
SELECT ename FROM emp WHERE mgr NOT IN (7698) OR mgr IS NULL;
GO
CREATE OR ALTER VIEW exp05_02_g2 (ename) AS
SELECT * FROM (VALUES (N'ADAMS'),
       (N'BLAKE'),
       (N'CLARK'),
       (N'FORD'),
       (N'JONES'),
       (N'KING'),
       (N'MILLER'),
       (N'SCOTT'),
       (N'SMITH')) v(ename);
GO
EXEC lab_check N'05-ex02-G2', N'ans05_02_g2', N'exp05_02_g2';
SELECT * FROM ans05_02_g2 ORDER BY 1;
GO
