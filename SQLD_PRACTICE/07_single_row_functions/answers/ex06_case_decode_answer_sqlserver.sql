-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex06_case_decode | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_case_decode.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 급여 등급별 인원';
-- GROUP BY 에 CASE 식 전체를 다시 써도 된다. WHEN 순서를 1000 → 2000 → 3000 으로 쓰면 D 를 뺀 모두가 'C' 가 된다.
GO
CREATE OR ALTER VIEW ans07_06_g1 (grade, cnt) AS
SELECT grade, COUNT(*) FROM (SELECT CASE WHEN sal >= 3000 THEN 'A' WHEN sal >= 2000 THEN 'B' WHEN sal >= 1000 THEN 'C' ELSE 'D' END AS grade FROM emp) t GROUP BY grade;
GO
CREATE OR ALTER VIEW exp07_06_g1 (grade, cnt) AS
SELECT * FROM (VALUES (N'A', 3),
       (N'B', 3),
       (N'C', 6),
       (N'D', 2)) v(grade, cnt);
GO
EXEC lab_check N'07-ex06-G1', N'ans07_06_g1', N'exp07_06_g1';
SELECT * FROM ans07_06_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 부서별 CLERK·SALESMAN 수';
-- COUNT(CASE WHEN job = 'CLERK' THEN 1 END) 도 같다(ELSE 없으면 NULL → COUNT 제외). SUM(CASE … END) 에서 ELSE 0 을 빼면 0 대신 NULL 이 나와 CHECK_FAIL.
GO
CREATE OR ALTER VIEW ans07_06_g2 (deptno, clerk_cnt, salesman_cnt) AS
SELECT deptno, SUM(CASE WHEN job = 'CLERK' THEN 1 ELSE 0 END), SUM(CASE WHEN job = 'SALESMAN' THEN 1 ELSE 0 END) FROM emp GROUP BY deptno;
GO
CREATE OR ALTER VIEW exp07_06_g2 (deptno, clerk_cnt, salesman_cnt) AS
SELECT * FROM (VALUES (10, 1, 0),
       (20, 2, 0),
       (30, 1, 4)) v(deptno, clerk_cnt, salesman_cnt);
GO
EXEC lab_check N'07-ex06-G2', N'ans07_06_g2', N'exp07_06_g2';
SELECT * FROM ans07_06_g2 ORDER BY 1, 2, 3;
GO
