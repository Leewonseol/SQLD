-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex01_operators_precedence | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_operators_precedence.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 20/30번 부서, 급여 1500 이상 3000 미만';
-- 괄호를 빼면 deptno = 20 OR (deptno = 30 AND …) 가 되어 20번 부서 전원(SMITH·ADAMS·SCOTT·FORD 포함)이 나온다.
GO
CREATE OR ALTER VIEW ans05_01_g1 (ename, deptno, sal) AS
SELECT ename, deptno, sal FROM emp WHERE (deptno = 20 OR deptno = 30) AND sal >= 1500 AND sal < 3000;
GO
CREATE OR ALTER VIEW exp05_01_g1 (ename, deptno, sal) AS
SELECT * FROM (VALUES (N'ALLEN', 30, 1600),
       (N'BLAKE', 30, 2850),
       (N'JONES', 20, 2975),
       (N'TURNER', 30, 1500)) v(ename, deptno, sal);
GO
EXEC lab_check N'05-ex01-G1', N'ans05_01_g1', N'exp05_01_g1';
SELECT * FROM ans05_01_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] CLERK 이 아니고 커미션 없음(NULL 또는 0)';
-- comm = 0 만 쓰면 1(TURNER), comm IS NULL 만 쓰면 6.
GO
CREATE OR ALTER VIEW ans05_01_g2 (cnt) AS
SELECT COUNT(*) FROM emp WHERE job <> 'CLERK' AND (comm IS NULL OR comm = 0);
GO
CREATE OR ALTER VIEW exp05_01_g2 (cnt) AS
SELECT * FROM (VALUES (7)) v(cnt);
GO
EXEC lab_check N'05-ex01-G2', N'ans05_01_g2', N'exp05_01_g2';
SELECT * FROM ans05_01_g2 ORDER BY 1;
GO
