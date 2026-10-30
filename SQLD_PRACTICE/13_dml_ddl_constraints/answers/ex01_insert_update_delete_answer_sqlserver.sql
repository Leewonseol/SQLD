-- H. 정답 및 검증 | 13 ex01 | SQL Server
DROP TABLE IF EXISTS d13_g_dept;
SELECT * INTO d13_g_dept FROM dept;
-- [학습자 작성 구간 시작]
INSERT INTO d13_g_dept VALUES (50, 'IT', 'SEOUL');
UPDATE d13_g_dept SET loc = 'BUSAN' WHERE deptno = 40;
DELETE FROM d13_g_dept WHERE deptno = 20;
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans13_01_g1 AS SELECT deptno, dname, loc FROM d13_g_dept;
GO
CREATE OR ALTER VIEW exp13_01_g1 (deptno, dname, loc) AS
SELECT * FROM (VALUES (10, 'ACCOUNTING', 'NEW YORK'), (30, 'SALES', 'CHICAGO'), (40, 'OPERATIONS', 'BUSAN'), (50, 'IT', 'SEOUL')) v(a, b, c);
GO
EXEC lab_check N'13-ex01-G1', N'ans13_01_g1', N'exp13_01_g1';
SELECT * FROM ans13_01_g1 ORDER BY deptno;
GO
