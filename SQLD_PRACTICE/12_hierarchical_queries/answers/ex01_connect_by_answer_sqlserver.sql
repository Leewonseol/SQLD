-- =====================================================================
-- H. 정답 및 검증 | 12_hierarchical_queries ex01_connect_by | SQL Server
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_connect_by.md
-- =====================================================================
USE SQLD_LAB;
GO

PRINT N'== [G1] LEVEL 3 사원';
-- LEVEL 조건을 CONNECT BY 쪽(… AND LEVEL <= 3)에 두면 전개 자체를 3단계에서 멈춰 더 효율적이다. 결과 필터는 WHERE.
GO
CREATE OR ALTER VIEW ans12_01_g1 (ename, mgr, lvl) AS
WITH t (empno, ename, mgr, lvl) AS (SELECT empno, ename, mgr, 1 FROM emp WHERE mgr IS NULL
 UNION ALL SELECT e.empno, e.ename, e.mgr, t.lvl + 1 FROM emp e JOIN t ON e.mgr = t.empno)
SELECT ename, mgr, lvl FROM t WHERE lvl = 3;
GO
CREATE OR ALTER VIEW exp12_01_g1 (ename, mgr, lvl) AS
SELECT * FROM (VALUES (N'ALLEN', 7698, 3),
       (N'FORD', 7566, 3),
       (N'JAMES', 7698, 3),
       (N'MARTIN', 7698, 3),
       (N'MILLER', 7782, 3),
       (N'SCOTT', 7566, 3),
       (N'TURNER', 7698, 3),
       (N'WARD', 7698, 3)) v(ename, mgr, lvl);
GO
EXEC lab_check N'12-ex01-G1', N'ans12_01_g1', N'exp12_01_g1';
SELECT * FROM ans12_01_g1 ORDER BY 1, 2, 3;
GO

PRINT N'== [G2] JONES 의 모든 부하';
-- START WITH mgr = (SELECT empno … 'JONES') 로 시작하면 JONES 자신이 빠진 상태로 바로 부하부터 전개할 수도 있다.
GO
CREATE OR ALTER VIEW ans12_01_g2 (ename) AS
WITH t (empno, ename) AS (SELECT empno, ename FROM emp WHERE ename = 'JONES'
 UNION ALL SELECT e.empno, e.ename FROM emp e JOIN t ON e.mgr = t.empno)
SELECT ename FROM t WHERE ename <> 'JONES';
GO
CREATE OR ALTER VIEW exp12_01_g2 (ename) AS
SELECT * FROM (VALUES (N'ADAMS'),
       (N'FORD'),
       (N'SCOTT'),
       (N'SMITH')) v(ename);
GO
EXEC lab_check N'12-ex01-G2', N'ans12_01_g2', N'exp12_01_g2';
SELECT * FROM ans12_01_g2 ORDER BY 1;
GO
