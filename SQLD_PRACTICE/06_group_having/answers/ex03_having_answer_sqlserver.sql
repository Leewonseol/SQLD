-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex03_having | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_having.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 평균 2000 이상·3명 이상 부서';
GO
CREATE OR ALTER VIEW ans06_03_g1 (deptno, avg_sal) AS
SELECT deptno, ROUND(AVG(sal), 1) FROM emp GROUP BY deptno HAVING AVG(sal) >= 2000 AND COUNT(*) >= 3;
GO
CREATE OR ALTER VIEW exp06_03_g1 (deptno, avg_sal) AS
SELECT * FROM (VALUES (10, 2916.7),
       (20, 2175)) v(deptno, avg_sal);
GO
EXEC lab_check N'06-ex03-G1', N'ans06_03_g1', N'exp06_03_g1';
SELECT * FROM ans06_03_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 커미션이 모두 NULL 인 부서';
-- COUNT(comm) 은 NULL 을 세지 않으므로 0 이면 모두 NULL. MAX(comm) IS NULL 도 같은 뜻.
GO
CREATE OR ALTER VIEW ans06_03_g2 (deptno) AS
SELECT deptno FROM emp GROUP BY deptno HAVING COUNT(comm) = 0;
GO
CREATE OR ALTER VIEW exp06_03_g2 (deptno) AS
SELECT * FROM (VALUES (10),
       (20)) v(deptno);
GO
EXEC lab_check N'06-ex03-G2', N'ans06_03_g2', N'exp06_03_g2';
SELECT * FROM ans06_03_g2 ORDER BY 1;
GO
