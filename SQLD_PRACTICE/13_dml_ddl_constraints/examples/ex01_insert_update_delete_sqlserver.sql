-- ex01 INSERT · UPDATE · DELETE  | SQL Server
DROP TABLE IF EXISTS d13_member;
CREATE TABLE d13_member (id INT CONSTRAINT pk_d13_member PRIMARY KEY, name VARCHAR(20) NOT NULL, grade VARCHAR(10) DEFAULT 'BASIC', point INT DEFAULT 0);
PRINT N'== [Q1] INSERT';
INSERT INTO d13_member VALUES (1, 'kim', 'VIP', 100);
INSERT INTO d13_member (id, name) VALUES (2, 'lee');
INSERT INTO d13_member (id, name, grade, point) VALUES (3, 'park', NULL, DEFAULT);
SELECT * FROM d13_member ORDER BY id;
PRINT N'== [Q2] 여러 행 INSERT: VALUES (..), (..) / INSERT ... SELECT';
INSERT INTO d13_member (id, name) VALUES (4, 'choi'), (5, 'jung');
INSERT INTO d13_member (id, name, point) SELECT empno, ename, sal FROM emp WHERE deptno = 10;
SELECT COUNT(*) AS cnt FROM d13_member;
PRINT N'== [Q3] UPDATE';
UPDATE d13_member SET grade = 'GOLD', point = point + 50 WHERE id IN (2, 3);
SELECT id, grade, point FROM d13_member WHERE id IN (2, 3) ORDER BY id;
PRINT N'== [Q4] DELETE (FROM 생략 가능)';
DELETE d13_member WHERE id > 100;
SELECT COUNT(*) AS cnt_after_delete FROM d13_member;
GO
PRINT N'== [Q5] 제약 위반 INSERT';
GO
-- @expect-error: MSG-2627, MSG-515
INSERT INTO d13_member (id, name) VALUES (1, 'dup');
GO
INSERT INTO d13_member (id, name) VALUES (9, NULL);
GO
PRINT N'== [Q6] 값 개수 불일치';
GO
-- @expect-error: MSG-213
INSERT INTO d13_member VALUES (10, 'short');
GO
DROP TABLE IF EXISTS d13_member;
GO
