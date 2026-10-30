-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex03_date_functions | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_date_functions.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 10번 부서 근속 개월 수(2024-03-31 기준)';
-- DATEDIFF(MONTH) 는 '월 경계를 넘은 횟수'다. 기준일(31일)이 입사일의 일(9·17·23일)보다 크거나 같아서 보정 없이도 값이 같다.
-- 기준일이 2024-03-05 였다면 DATEDIFF 만 쓴 값이 1 크다. 그래서 CASE 로 보정했다.
GO
CREATE OR ALTER VIEW ans07_03_g1 (ename, months) AS
SELECT ename, DATEDIFF(MONTH, hiredate, '2024-03-31') - CASE WHEN DAY(hiredate) > DAY('2024-03-31') THEN 1 ELSE 0 END FROM emp WHERE deptno = 10;
GO
CREATE OR ALTER VIEW exp07_03_g1 (ename, months) AS
SELECT * FROM (VALUES (N'CLARK', 513),
       (N'KING', 508),
       (N'MILLER', 506)) v(ename, months);
GO
EXEC lab_check N'07-ex03-G1', N'ans07_03_g1', N'exp07_03_g1';
SELECT * FROM ans07_03_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 2024년 2월 말일과 다음 날';
GO
CREATE OR ALTER VIEW ans07_03_g2 (last_day, next_day) AS
SELECT CONVERT(CHAR(10), EOMONTH('2024-02-01'), 23), CONVERT(CHAR(10), DATEADD(DAY, 1, EOMONTH('2024-02-01')), 23);
GO
CREATE OR ALTER VIEW exp07_03_g2 (last_day, next_day) AS
SELECT * FROM (VALUES (N'2024-02-29', N'2024-03-01')) v(last_day, next_day);
GO
EXEC lab_check N'07-ex03-G2', N'ans07_03_g2', N'exp07_03_g2';
SELECT * FROM ans07_03_g2 ORDER BY 1, 2;
GO
