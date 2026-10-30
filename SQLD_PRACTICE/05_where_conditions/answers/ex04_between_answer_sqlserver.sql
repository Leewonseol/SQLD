-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex04_between | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_between.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 1981-01-01 ~ 1981-06-30 입사';
-- hiredate 에 시각이 없으므로 BETWEEN 으로 충분하다. 시각이 있다면 hiredate < DATE '1981-07-01'.
GO
CREATE OR ALTER VIEW ans05_04_g1 (ename, hire_ymd) AS
SELECT ename, CONVERT(CHAR(10), hiredate, 23) FROM emp WHERE hiredate BETWEEN '1981-01-01' AND '1981-06-30';
GO
CREATE OR ALTER VIEW exp05_04_g1 (ename, hire_ymd) AS
SELECT * FROM (VALUES (N'ALLEN', N'1981-02-20'),
       (N'BLAKE', N'1981-05-01'),
       (N'CLARK', N'1981-06-09'),
       (N'JONES', N'1981-04-02'),
       (N'WARD', N'1981-02-22')) v(ename, hire_ymd);
GO
EXEC lab_check N'05-ex04-G1', N'ans05_04_g1', N'exp05_04_g1';
SELECT * FROM ans05_04_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 2024-03-31 하루 전체';
-- ts = DATE '2024-03-31' 로 쓰면 00:00 인 id 3 만 나온다.
GO
CREATE OR ALTER VIEW ans05_04_g2 (id) AS
SELECT id FROM w_ts WHERE ts >= '2024-03-31' AND ts < '2024-04-01';
GO
CREATE OR ALTER VIEW exp05_04_g2 (id) AS
SELECT * FROM (VALUES (3),
       (4)) v(id);
GO
EXEC lab_check N'05-ex04-G2', N'ans05_04_g2', N'exp05_04_g2';
SELECT * FROM ans05_04_g2 ORDER BY 1;
GO
