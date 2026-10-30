-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex08_using_natural | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex08_using_natural.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] DALLAS 근무 사원';
-- NATURAL JOIN 의 공통 컬럼은 DEPTNO 하나뿐이다(EMP 와 DEPT 의 다른 컬럼 이름은 겹치지 않는다).
-- 두 테이블에 이름만 같고 의미가 다른 컬럼(예: 둘 다 NAME)이 있으면 NATURAL JOIN 은 그 컬럼까지 비교해 행이 사라진다.
GO
CREATE OR ALTER VIEW ans04_08_g1 (ename) AS
SELECT e.ename FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE d.loc = 'DALLAS';
GO
CREATE OR ALTER VIEW exp04_08_g1 (ename) AS
SELECT * FROM (VALUES (N'ADAMS'),
       (N'FORD'),
       (N'JONES'),
       (N'SCOTT'),
       (N'SMITH')) v(ename);
GO
EXEC lab_check N'04-ex08-G1', N'ans04_08_g1', N'exp04_08_g1';
SELECT * FROM ans04_08_g1 ORDER BY 1;
GO

PRINT N'== [G2] NJ_T1-NJ_T3 USING(no)';
-- Oracle 에서 a.no 로 쓰면 ORA-25154.
GO
CREATE OR ALTER VIEW ans04_08_g2 (no, name, pos) AS
SELECT a.no, a.name, b.pos FROM nj_t1 a JOIN nj_t3 b ON a.no = b.no;
GO
CREATE OR ALTER VIEW exp04_08_g2 (no, name, pos) AS
SELECT * FROM (VALUES (1, N'A', N'정글'),
       (1, N'A', N'탑'),
       (2, N'B', N'미드')) v(no, name, pos);
GO
EXEC lab_check N'04-ex08-G2', N'ans04_08_g2', N'exp04_08_g2';
SELECT * FROM ans04_08_g2 ORDER BY 1, 2, 3;
GO
