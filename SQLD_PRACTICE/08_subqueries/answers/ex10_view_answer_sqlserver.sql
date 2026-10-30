-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex10_view | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex10_view.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 20번 부서 사원·부서명 뷰';
GO
CREATE OR ALTER VIEW ans08_10_g1 (ename, dname) AS
SELECT e.ename, d.dname FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.deptno = 20;
GO
CREATE OR ALTER VIEW exp08_10_g1 (ename, dname) AS
SELECT * FROM (VALUES (N'ADAMS', N'RESEARCH'),
       (N'FORD', N'RESEARCH'),
       (N'JONES', N'RESEARCH'),
       (N'SCOTT', N'RESEARCH'),
       (N'SMITH', N'RESEARCH')) v(ename, dname);
GO
EXEC lab_check N'08-ex10-G1', N'ans08_10_g1', N'exp08_10_g1';
SELECT * FROM ans08_10_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 3명 이상 부서 요약 뷰';
-- SQL Server ROUND 는 자릿수 인수가 필수다. 뷰 정의에 ORDER BY 를 넣으면 SQL Server 는 Msg 1033.
GO
CREATE OR ALTER VIEW ans08_10_g2 (deptno, cnt, avg_sal) AS
SELECT deptno, COUNT(*), ROUND(AVG(sal), 0) FROM emp GROUP BY deptno HAVING COUNT(*) >= 3;
GO
CREATE OR ALTER VIEW exp08_10_g2 (deptno, cnt, avg_sal) AS
SELECT * FROM (VALUES (10, 3, 2917),
       (20, 5, 2175),
       (30, 6, 1567)) v(deptno, cnt, avg_sal);
GO
EXEC lab_check N'08-ex10-G2', N'ans08_10_g2', N'exp08_10_g2';
SELECT * FROM ans08_10_g2 ORDER BY 1, 2, 3;
GO
