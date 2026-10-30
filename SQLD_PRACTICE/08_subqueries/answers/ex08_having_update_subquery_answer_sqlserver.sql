-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex08_having_update_subquery | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex08_having_update_subquery.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 30번 부서 comm 갱신 미리보기';
-- 실제 UPDATE: UPDATE emp e SET comm = NVL((SELECT ...), 0) WHERE deptno = 30. 갱신 전에 같은 식을 SELECT 로 확인하는 습관.
GO
CREATE OR ALTER VIEW ans08_08_g1 (ename, new_comm) AS
SELECT e.ename, ISNULL((SELECT b.amt FROM bonus b WHERE b.empno = e.empno), 0) FROM emp e WHERE e.deptno = 30;
GO
CREATE OR ALTER VIEW exp08_08_g1 (ename, new_comm) AS
SELECT * FROM (VALUES (N'ALLEN', 200),
       (N'BLAKE', 0),
       (N'JAMES', 0),
       (N'MARTIN', 0),
       (N'TURNER', 0),
       (N'WARD', 0)) v(ename, new_comm);
GO
EXEC lab_check N'08-ex08-G1', N'ans08_08_g1', N'exp08_08_g1';
SELECT * FROM ans08_08_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] 평균 급여가 20번 부서보다 낮은 부서';
GO
CREATE OR ALTER VIEW ans08_08_g2 (deptno) AS
SELECT deptno FROM emp GROUP BY deptno HAVING AVG(sal) < (SELECT AVG(sal) FROM emp WHERE deptno = 20);
GO
CREATE OR ALTER VIEW exp08_08_g2 (deptno) AS
SELECT * FROM (VALUES (30)) v(deptno);
GO
EXEC lab_check N'08-ex08-G2', N'ans08_08_g2', N'exp08_08_g2';
SELECT * FROM ans08_08_g2 ORDER BY 1;
GO
