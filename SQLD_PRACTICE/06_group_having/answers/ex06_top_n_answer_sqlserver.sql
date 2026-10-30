-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex06_top_n | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_top_n.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 가장 먼저 입사한 3명';
-- SELECT ... WHERE ROWNUM <= 3 ORDER BY hiredate 는 '먼저 읽힌 3행'을 정렬할 뿐이라 우연히 맞을 수 있어도 틀린 답이다.
GO
CREATE OR ALTER VIEW ans06_06_g1 (ename, hire_ymd) AS
SELECT TOP 3 ename, CONVERT(CHAR(10), hiredate, 23) FROM emp ORDER BY hiredate;
GO
CREATE OR ALTER VIEW exp06_06_g1 (ename, hire_ymd) AS
SELECT * FROM (VALUES (N'ALLEN', N'1981-02-20'),
       (N'SMITH', N'1980-12-17'),
       (N'WARD', N'1981-02-22')) v(ename, hire_ymd);
GO
EXEC lab_check N'06-ex06-G1', N'ans06_06_g1', N'exp06_06_g1';
SELECT * FROM ans06_06_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 상위 2개 급여 값의 사원(동점 포함)';
-- FETCH FIRST 2 ROWS WITH TIES / TOP 2 WITH TIES 는 '2번째 행과 같은 값까지'라 이 데이터에서는 결과가 같다.
-- 하지만 1위가 동점 3명이면 WITH TIES 는 1위 3명만 돌려준다. 값 기준 2위까지는 DENSE_RANK() <= 2 (11단원 ex03).
GO
CREATE OR ALTER VIEW ans06_06_g2 (ename, sal) AS
SELECT ename, sal FROM emp WHERE sal IN (SELECT DISTINCT TOP 2 sal FROM emp ORDER BY sal DESC);
GO
CREATE OR ALTER VIEW exp06_06_g2 (ename, sal) AS
SELECT * FROM (VALUES (N'FORD', 3000),
       (N'KING', 5000),
       (N'SCOTT', 3000)) v(ename, sal);
GO
EXEC lab_check N'06-ex06-G2', N'ans06_06_g2', N'exp06_06_g2';
SELECT * FROM ans06_06_g2 ORDER BY 1, 2;
GO
