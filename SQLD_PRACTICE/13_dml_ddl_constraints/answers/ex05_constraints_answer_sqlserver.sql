-- H. 정답 및 검증 | 13 ex05 | SQL Server : UNIQUE 컬럼의 두 번째 NULL 이 거부되어 id 1, 2 만 성공 (Oracle 과 다름)
DROP TABLE IF EXISTS d13_g_stu;
-- [학습자 작성 구간 시작]
CREATE TABLE d13_g_stu (id INT PRIMARY KEY, name VARCHAR(10) NOT NULL, email VARCHAR(20) UNIQUE, age INT CHECK (age BETWEEN 0 AND 150));
-- [학습자 작성 구간 끝]
GO
-- @expect-error: MSG-2627, MSG-515, MSG-547
INSERT INTO d13_g_stu VALUES (1, 'a', 'a@x', 20);
GO
INSERT INTO d13_g_stu VALUES (2, 'b', NULL, 30);
GO
INSERT INTO d13_g_stu VALUES (3, 'c', NULL, 40);
GO
INSERT INTO d13_g_stu VALUES (4, NULL, 'd@x', 50);
GO
INSERT INTO d13_g_stu VALUES (5, 'e', 'e@x', 200);
GO
CREATE OR ALTER VIEW ans13_05_g1 AS SELECT id FROM d13_g_stu;
GO
CREATE OR ALTER VIEW exp13_05_g1 (id) AS SELECT * FROM (VALUES (1), (2)) v(a);
GO
EXEC lab_check N'13-ex05-G1', N'ans13_05_g1', N'exp13_05_g1';
SELECT * FROM ans13_05_g1 ORDER BY id;
GO
