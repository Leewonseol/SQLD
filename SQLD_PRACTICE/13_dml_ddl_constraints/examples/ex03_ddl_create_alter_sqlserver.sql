-- ex03 CREATE · ALTER · RENAME · DROP  | SQL Server (ALTER COLUMN, sp_rename, 괄호 없는 ADD)
DROP TABLE IF EXISTS d13_prod, d13_product;
GO
PRINT N'== [Q1] CREATE TABLE';
CREATE TABLE d13_prod (pid INT CONSTRAINT pk_d13_prod PRIMARY KEY, pname VARCHAR(10) NOT NULL, price INT CONSTRAINT df_d13_prod_price DEFAULT 0);
INSERT INTO d13_prod (pid, pname) VALUES (1, 'pencil');
INSERT INTO d13_prod (pid, pname, price) VALUES (2, 'eraser', 500);
PRINT N'== [Q2] ALTER TABLE ADD (DEFAULT 가 있는 NULL 허용 컬럼은 기존 행에 NULL. WITH VALUES 를 쓰면 기본값)';
ALTER TABLE d13_prod ADD stock INT DEFAULT 10 WITH VALUES, memo VARCHAR(20);
SELECT * FROM d13_prod;
PRINT N'== [Q3] ALTER COLUMN (MODIFY 아님). 줄이면 잘림 오류';
ALTER TABLE d13_prod ALTER COLUMN pname VARCHAR(20) NOT NULL;
GO
-- @expect-error: MSG-2628
ALTER TABLE d13_prod ALTER COLUMN pname VARCHAR(3) NOT NULL;
GO
PRINT N'== [Q4] NULL 이 있는 컬럼을 NOT NULL 로 -> 오류';
GO
-- @expect-error: MSG-515
ALTER TABLE d13_prod ALTER COLUMN memo VARCHAR(20) NOT NULL;
GO
PRINT N'== [Q5] sp_rename (컬럼·테이블) / DROP COLUMN';
EXEC sp_rename 'd13_prod.memo', 'note', 'COLUMN';
ALTER TABLE d13_prod DROP COLUMN note;
EXEC sp_rename 'd13_prod', 'd13_product';
SELECT column_name, data_type, character_maximum_length, is_nullable FROM information_schema.columns WHERE table_name = 'd13_product' ORDER BY ordinal_position;
PRINT N'== [Q6] DROP TABLE';
DROP TABLE d13_product;
SELECT COUNT(*) AS remaining FROM sys.tables WHERE name = 'd13_product';
GO
PRINT N'== [Q7] Oracle 의 MODIFY 문법 -> 오류';
GO
-- @expect-error: MSG-102
ALTER TABLE emp MODIFY (ename VARCHAR(20));
GO
