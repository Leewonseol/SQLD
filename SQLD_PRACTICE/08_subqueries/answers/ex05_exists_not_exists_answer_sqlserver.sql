-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex05_exists_not_exists | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_exists_not_exists.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] 주문 없는 고객';
GO
CREATE OR ALTER VIEW ans08_05_g1 (cust_id) AS
SELECT c.cust_id FROM cust c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.cust_id = c.cust_id);
GO
CREATE OR ALTER VIEW exp08_05_g1 (cust_id) AS
SELECT * FROM (VALUES (N'C04')) v(cust_id);
GO
EXEC lab_check N'08-ex05-G1', N'ans08_05_g1', N'exp08_05_g1';
SELECT * FROM ans08_05_g1 ORDER BY 1;
GO

PRINT N'== [G2] SALESMAN 이 없는 (사원 있는) 부서';
-- EXISTS 조건을 빼면 사원이 없는 40번도 'SALESMAN 이 없는 부서'로 나온다.
GO
CREATE OR ALTER VIEW ans08_05_g2 (deptno) AS
SELECT d.deptno FROM dept d WHERE EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno)
AND NOT EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno AND e.job = 'SALESMAN');
GO
CREATE OR ALTER VIEW exp08_05_g2 (deptno) AS
SELECT * FROM (VALUES (10),
       (20)) v(deptno);
GO
EXEC lab_check N'08-ex05-G2', N'ans08_05_g2', N'exp08_05_g2';
SELECT * FROM ans08_05_g2 ORDER BY 1;
GO
