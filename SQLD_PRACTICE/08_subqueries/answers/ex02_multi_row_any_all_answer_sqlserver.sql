-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex02_multi_row_any_all | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_multi_row_any_all.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 30번 부서 모두보다 적은 급여';
-- 30번 부서 최저 950 미만. < ANY 로 쓰면 '최고 2850 미만' 이라 11명.
GO
CREATE OR ALTER VIEW ans08_02_g1 (ename, sal) AS
SELECT ename, sal FROM emp WHERE sal < ALL (SELECT sal FROM emp WHERE deptno = 30);
GO
CREATE OR ALTER VIEW exp08_02_g1 (ename, sal) AS
SELECT * FROM (VALUES (N'SMITH', 800)) v(ename, sal);
GO
EXEC lab_check N'08-ex02-G1', N'ans08_02_g1', N'exp08_02_g1';
SELECT * FROM ans08_02_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 최고 급여자(>= ALL)';
-- sal 에 NULL 이 있으면 >= ALL 은 0행이 된다(UNKNOWN). 그 경우 WHERE sal IS NOT NULL 을 서브쿼리에 추가.
GO
CREATE OR ALTER VIEW ans08_02_g2 (ename) AS
SELECT ename FROM emp WHERE sal >= ALL (SELECT sal FROM emp);
GO
CREATE OR ALTER VIEW exp08_02_g2 (ename) AS
SELECT * FROM (VALUES (N'KING')) v(ename);
GO
EXEC lab_check N'08-ex02-G2', N'ans08_02_g2', N'exp08_02_g2';
SELECT * FROM ans08_02_g2 ORDER BY 1;
GO
