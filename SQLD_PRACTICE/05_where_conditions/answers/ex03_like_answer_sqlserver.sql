-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex03_like | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_like.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] A 포함 5글자 이름';
-- ename LIKE '_____' 은 정확히 5글자. LENGTH(ename) = 5 (SQL Server LEN) 로도 가능하지만 문제 조건은 LIKE 만.
GO
CREATE OR ALTER VIEW ans05_03_g1 (ename) AS
SELECT ename FROM emp WHERE ename LIKE '%A%' AND ename LIKE '_____';
GO
CREATE OR ALTER VIEW exp05_03_g1 (ename) AS
SELECT * FROM (VALUES (N'ADAMS'),
       (N'ALLEN'),
       (N'BLAKE'),
       (N'CLARK'),
       (N'JAMES')) v(ename);
GO
EXEC lab_check N'05-ex03-G1', N'ans05_03_g1', N'exp05_03_g1';
SELECT * FROM ans05_03_g1 ORDER BY 1;
GO

PRINT N'== [G2] 대소문자 무시 a 시작, _ 미포함';
-- SQL Server 는 기본 CI 정렬이라 UPPER 없이도 같지만, 데이터 정렬이 CS 인 DB 에서도 같은 결과가 나오도록 UPPER 를 쓴다.
GO
CREATE OR ALTER VIEW ans05_03_g2 (id, txt) AS
SELECT id, txt FROM w_like WHERE UPPER(txt) LIKE 'A%' AND txt NOT LIKE '%[_]%';
GO
CREATE OR ALTER VIEW exp05_03_g2 (id, txt) AS
SELECT * FROM (VALUES (2, N'AXB'),
       (3, N'AB'),
       (6, N'ab')) v(id, txt);
GO
EXEC lab_check N'05-ex03-G2', N'ans05_03_g2', N'exp05_03_g2';
SELECT * FROM ans05_03_g2 ORDER BY 1, 2;
GO
