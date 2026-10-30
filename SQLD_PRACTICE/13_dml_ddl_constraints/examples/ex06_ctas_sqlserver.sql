-- ex06 SELECT INTO (SQL Server 의 CTAS)  | SQL Server (CREATE TABLE ... AS SELECT 는 지원하지 않는다)
DROP TABLE IF EXISTS d13_emp_copy;
GO
PRINT N'== [Q0] CREATE TABLE AS SELECT -> 오류';
GO
-- @expect-error: MSG-156
CREATE TABLE d13_emp_copy AS SELECT * FROM emp;
GO
PRINT N'== [Q1] 원본 EMP 의 키 제약';
SELECT type_desc, COUNT(*) cnt FROM sys.objects WHERE parent_object_id = OBJECT_ID('emp') AND type IN ('PK', 'F', 'UQ', 'C', 'D') GROUP BY type_desc ORDER BY type_desc;
PRINT N'== [Q2] SELECT INTO: 데이터·컬럼·NULL 허용 여부만 복사, PK/FK 는 복사하지 않는다';
SELECT * INTO d13_emp_copy FROM emp;
SELECT COUNT(*) AS key_constraints FROM sys.objects WHERE parent_object_id = OBJECT_ID('d13_emp_copy') AND type IN ('PK', 'F', 'UQ', 'C', 'D');
SELECT COLUMNPROPERTY(OBJECT_ID('d13_emp_copy'), 'ename', 'AllowsNull') AS ename_allows_null, (SELECT COUNT(*) FROM d13_emp_copy) AS copied_rows;
PRINT N'== [Q3] PK 가 없으니 중복 입력';
INSERT INTO d13_emp_copy SELECT * FROM emp WHERE empno = 7369;
SELECT COUNT(*) AS dup_7369 FROM d13_emp_copy WHERE empno = 7369;
PRINT N'== [Q4] 구조만 복사';
DROP TABLE d13_emp_copy;
SELECT * INTO d13_emp_copy FROM emp WHERE 1 = 0;
SELECT COUNT(*) AS rows_struct_only FROM d13_emp_copy;
DROP TABLE d13_emp_copy;
GO
