-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex02_rows_range | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_rows_range.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 20번 부서 3행 이동 합(ROWS)';
-- ROWS 2 PRECEDING 은 '앞 2행 + 현재 행'. RANGE 로 쓰면 날짜 값 기준(2일 이내)이 되어 의미가 다르다(SQL Server 는 RANGE 오프셋 불가).
GO
CREATE OR ALTER VIEW ans11_02_g1 (ename, mov_sum) AS
SELECT ename, SUM(sal) OVER (ORDER BY hiredate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) FROM emp WHERE deptno = 20;
GO
CREATE OR ALTER VIEW exp11_02_g1 (ename, mov_sum) AS
SELECT * FROM (VALUES (N'ADAMS', 7100),
       (N'FORD', 6775),
       (N'JONES', 3775),
       (N'SCOTT', 8975),
       (N'SMITH', 800)) v(ename, mov_sum);
GO
EXEC lab_check N'11-ex02-G1', N'ans11_02_g1', N'exp11_02_g1';
SELECT * FROM ans11_02_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 30번 부서 급여순 RANGE 누적';
-- MARTIN·WARD 동점(1250)은 RANGE 기본 프레임에서 함께 더해져 둘 다 3450.
GO
CREATE OR ALTER VIEW ans11_02_g2 (ename, cum_sal) AS
SELECT ename, SUM(sal) OVER (ORDER BY sal) FROM emp WHERE deptno = 30;
GO
CREATE OR ALTER VIEW exp11_02_g2 (ename, cum_sal) AS
SELECT * FROM (VALUES (N'ALLEN', 6550),
       (N'BLAKE', 9400),
       (N'JAMES', 950),
       (N'MARTIN', 3450),
       (N'TURNER', 4950),
       (N'WARD', 3450)) v(ename, cum_sal);
GO
EXEC lab_check N'11-ex02-G2', N'ans11_02_g2', N'exp11_02_g2';
SELECT * FROM ans11_02_g2 ORDER BY 1, 2;
GO
