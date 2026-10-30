-- ex10 뷰(VIEW)  | SQL Server (CREATE VIEW 는 배치의 첫 문장이어야 한다, WITH READ ONLY 없음)
PRINT N'== [Q1] 뷰 생성';
GO
CREATE OR ALTER VIEW v_emp20 AS SELECT empno, ename, sal, deptno FROM emp WHERE deptno = 20;
GO
SELECT * FROM v_emp20 ORDER BY empno;
PRINT N'== [Q2] 기본 테이블 변경이 뷰에 바로 반영';
BEGIN TRAN;
UPDATE emp SET sal = sal + 1 WHERE empno = 7369;
SELECT ename, sal FROM v_emp20 WHERE empno = 7369;
ROLLBACK;
GO
PRINT N'== [Q3] WITH CHECK OPTION';
GO
CREATE OR ALTER VIEW v_emp20_chk AS SELECT empno, ename, sal, deptno FROM emp WHERE deptno = 20 WITH CHECK OPTION;
GO
-- @expect-error: MSG-550
UPDATE v_emp20_chk SET deptno = 30 WHERE empno = 7369;
GO
PRINT N'== [Q5] 정리';
DROP VIEW IF EXISTS v_emp20, v_emp20_chk;
GO
