-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex01_char_functions | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_char_functions.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 10번 부서 이름 첫 글자 대문자·길이';
-- Oracle 의 INITCAP 은 공백·기호 뒤 글자도 대문자로 만든다('sql developer' → 'Sql Developer'). SQL Server 식은 첫 글자만 처리한다.
GO
CREATE OR ALTER VIEW ans07_01_g1 (name_cap, name_len) AS
SELECT UPPER(LEFT(ename, 1)) + LOWER(SUBSTRING(ename, 2, LEN(ename))), LEN(ename) FROM emp WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp07_01_g1 (name_cap, name_len) AS
SELECT * FROM (VALUES (N'Clark', 5),
       (N'King', 4),
       (N'Miller', 6)) v(name_cap, name_len);
GO
EXEC lab_check N'07-ex01-G1', N'ans07_01_g1', N'exp07_01_g1';
SELECT * FROM ans07_01_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 20번 부서 이름의 A 위치';
-- CHARINDEX(찾을값, 대상) — INSTR(대상, 찾을값) 과 인수 순서가 반대다. 순서를 바꾸면 모두 0.
GO
CREATE OR ALTER VIEW ans07_01_g2 (ename, pos_a) AS
SELECT ename, CHARINDEX('A', ename) FROM emp WHERE deptno = 20;
GO
CREATE OR ALTER VIEW exp07_01_g2 (ename, pos_a) AS
SELECT * FROM (VALUES (N'ADAMS', 1),
       (N'FORD', 0),
       (N'JONES', 0),
       (N'SCOTT', 0),
       (N'SMITH', 0)) v(ename, pos_a);
GO
EXEC lab_check N'07-ex01-G2', N'ans07_01_g2', N'exp07_01_g2';
SELECT * FROM ans07_01_g2 ORDER BY 1, 2;
GO
