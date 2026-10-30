-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex03_rank_functions | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_rank_functions.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 부서별 DENSE_RANK 2위';
-- RANK 로 쓰면 20번 부서는 SCOTT·FORD 공동 1위 다음이 3위라 2위가 없다 → 20번 행이 빠져 CHECK_FAIL.
GO
CREATE OR ALTER VIEW ans11_03_g1 (deptno, ename, sal) AS
SELECT deptno, ename, sal FROM (SELECT deptno, ename, sal, DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) dr FROM emp) t WHERE dr = 2;
GO
CREATE OR ALTER VIEW exp11_03_g1 (deptno, ename, sal) AS
SELECT * FROM (VALUES (10, N'CLARK', 2450),
       (20, N'JONES', 2975),
       (30, N'ALLEN', 1600)) v(deptno, ename, sal);
GO
EXEC lab_check N'11-ex03-G1', N'ans11_03_g1', N'exp11_03_g1';
SELECT * FROM ans11_03_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] 전체 4~6위(ROW_NUMBER)';
GO
CREATE OR ALTER VIEW ans11_03_g2 (rn, ename) AS
SELECT rn, ename FROM (SELECT ename, ROW_NUMBER() OVER (ORDER BY sal DESC, empno) rn FROM emp) t WHERE rn BETWEEN 4 AND 6;
GO
CREATE OR ALTER VIEW exp11_03_g2 (rn, ename) AS
SELECT * FROM (VALUES (4, N'JONES'),
       (5, N'BLAKE'),
       (6, N'CLARK')) v(rn, ename);
GO
EXEC lab_check N'11-ex03-G2', N'ans11_03_g2', N'exp11_03_g2';
SELECT * FROM ans11_03_g2 ORDER BY 1, 2;
GO
