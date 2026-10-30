-- =====================================================================
-- H. 정답 및 검증 | 12_hierarchical_queries ex03_recursive_with | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_recursive_with.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 상위 관리자 수';
GO
CREATE OR ALTER VIEW ans12_03_g1 (ename, mgr_cnt) AS
WITH t (empno, ename, d) AS (SELECT empno, ename, 0 FROM emp WHERE mgr IS NULL
 UNION ALL SELECT e.empno, e.ename, t.d + 1 FROM emp e JOIN t ON e.mgr = t.empno)
SELECT ename, d FROM t;
GO
CREATE OR ALTER VIEW exp12_03_g1 (ename, mgr_cnt) AS
SELECT * FROM (VALUES (N'ADAMS', 3),
       (N'ALLEN', 2),
       (N'BLAKE', 1),
       (N'CLARK', 1),
       (N'FORD', 2),
       (N'JAMES', 2),
       (N'JONES', 1),
       (N'KING', 0),
       (N'MARTIN', 2),
       (N'MILLER', 2),
       (N'SCOTT', 2),
       (N'SMITH', 3),
       (N'TURNER', 2),
       (N'WARD', 2)) v(ename, mgr_cnt);
GO
EXEC lab_check N'12-ex03-G1', N'ans12_03_g1', N'exp12_03_g1';
SELECT * FROM ans12_03_g1 ORDER BY 1, 2;
GO

PRINT N'== [G2] BLAKE 조직 급여 합계';
-- BLAKE 2850 + 부하 5명(ALLEN 1600, WARD 1250, MARTIN 1250, TURNER 1500, JAMES 950) = 9400 = 30번 부서 합계와 같다(이 데이터에서만 우연히 같다).
GO
CREATE OR ALTER VIEW ans12_03_g2 (total) AS
WITH t (empno, sal) AS (SELECT empno, sal FROM emp WHERE ename = 'BLAKE'
 UNION ALL SELECT e.empno, e.sal FROM emp e JOIN t ON e.mgr = t.empno)
SELECT SUM(sal) FROM t;
GO
CREATE OR ALTER VIEW exp12_03_g2 (total) AS
SELECT * FROM (VALUES (9400)) v(total);
GO
EXEC lab_check N'12-ex03-G2', N'ans12_03_g2', N'exp12_03_g2';
SELECT * FROM ans12_03_g2 ORDER BY 1;
GO
