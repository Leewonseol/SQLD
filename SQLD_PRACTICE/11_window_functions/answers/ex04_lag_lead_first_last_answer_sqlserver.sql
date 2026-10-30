-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex04_lag_lead_first_last | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_lag_lead_first_last.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 직전 입사자와 급여 차이';
-- LAG 의 기본값을 sal 로 주면 첫 행 차이가 0. NVL(sal - LAG(sal) OVER (...), 0) 도 같다.
GO
CREATE OR ALTER VIEW ans11_04_g1 (ename, diff) AS
SELECT ename, sal - LAG(sal, 1, sal) OVER (ORDER BY hiredate) FROM emp WHERE deptno = 30;
GO
CREATE OR ALTER VIEW exp11_04_g1 (ename, diff) AS
SELECT * FROM (VALUES (N'ALLEN', 0),
       (N'BLAKE', 1600),
       (N'JAMES', -300),
       (N'MARTIN', -250),
       (N'TURNER', -1350),
       (N'WARD', -350)) v(ename, diff);
GO
EXEC lab_check N'11-ex04-G1', N'ans11_04_g1', N'exp11_04_g1';
SELECT * FROM ans11_04_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 부서별 최저 급여자(LAST_VALUE)';
-- 프레임을 지정하지 않으면 각 행 자기 이름이 나와 DISTINCT 후 14행 → CHECK_FAIL (PDF E-34 의 함정).
GO
CREATE OR ALTER VIEW ans11_04_g2 (deptno, min_name) AS
SELECT DISTINCT deptno, LAST_VALUE(ename) OVER (PARTITION BY deptno ORDER BY sal DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FROM emp;
GO
CREATE OR ALTER VIEW exp11_04_g2 (deptno, min_name) AS
SELECT * FROM (VALUES (10, N'MILLER'),
       (20, N'SMITH'),
       (30, N'JAMES')) v(deptno, min_name);
GO
EXEC lab_check N'11-ex04-G2', N'ans11_04_g2', N'exp11_04_g2';
SELECT * FROM ans11_04_g2 ORDER BY 1, 2;
GO
