-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex03_select_basics | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_select_basics.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 30번 부서 총수령액';
-- sal + comm 만 쓰면 BLAKE·JAMES 가 NULL 이 되어 CHECK_FAIL.
GO
CREATE OR ALTER VIEW ans04_03_g1 (ename, total_pay) AS
SELECT ename, sal + ISNULL(comm, 0) FROM emp WHERE deptno = 30;
GO
CREATE OR ALTER VIEW exp04_03_g1 (ename, total_pay) AS
SELECT * FROM (VALUES (N'ALLEN', 1900),
       (N'BLAKE', 2850),
       (N'JAMES', 950),
       (N'MARTIN', 2650),
       (N'TURNER', 1500),
       (N'WARD', 1750)) v(ename, total_pay);
GO
EXEC lab_check N'04-ex03-G1', N'ans04_03_g1', N'exp04_03_g1';
SELECT * FROM ans04_03_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] (부서, 직무) 조합 수';
-- COUNT(DISTINCT deptno, job) 은 두 DBMS 모두 오류(인수 1개만). Oracle 은 COUNT(DISTINCT deptno || job) 로도 가능하지만 값이 이어 붙어 우연히 같아질 위험이 있다.
GO
CREATE OR ALTER VIEW ans04_03_g2 (combo_cnt) AS
SELECT COUNT(*) FROM (SELECT DISTINCT deptno, job FROM emp) t;
GO
CREATE OR ALTER VIEW exp04_03_g2 (combo_cnt) AS
SELECT * FROM (VALUES (9)) v(combo_cnt);
GO
EXEC lab_check N'04-ex03-G2', N'ans04_03_g2', N'exp04_03_g2';
SELECT * FROM ans04_03_g2 ORDER BY 1;
GO
