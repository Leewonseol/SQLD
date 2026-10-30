-- H. 정답 및 검증 | 13 ex06 | SQL Server
DROP TABLE IF EXISTS d13_g_emp20;
-- [학습자 작성 구간 시작]
SELECT * INTO d13_g_emp20 FROM emp WHERE deptno = 20;
ALTER TABLE d13_g_emp20 ADD CONSTRAINT pk_d13_g_emp20 PRIMARY KEY (empno);
-- [학습자 작성 구간 끝]
GO
CREATE OR ALTER VIEW ans13_06_g1 AS
SELECT (SELECT COUNT(*) FROM d13_g_emp20) row_cnt, (SELECT COUNT(*) FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('d13_g_emp20') AND type = 'PK') pk_cnt;
GO
CREATE OR ALTER VIEW exp13_06_g1 (row_cnt, pk_cnt) AS SELECT 5, 1;
GO
EXEC lab_check N'13-ex06-G1', N'ans13_06_g1', N'exp13_06_g1';
SELECT * FROM ans13_06_g1;
GO
