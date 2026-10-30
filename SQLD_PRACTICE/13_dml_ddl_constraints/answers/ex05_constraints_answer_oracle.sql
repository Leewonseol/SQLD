-- H. 정답 및 검증 | 13 ex05 | Oracle : UNIQUE 컬럼의 NULL 두 개 허용 -> id 1, 2, 3 성공
EXEC lab_drop('D13_G_STU')
-- [학습자 작성 구간 시작]
CREATE TABLE d13_g_stu (id NUMBER PRIMARY KEY, name VARCHAR2(10) NOT NULL, email VARCHAR2(20) UNIQUE, age NUMBER CHECK (age BETWEEN 0 AND 150));
-- [학습자 작성 구간 끝]
-- @expect-error: ORA-01400, ORA-02290
INSERT INTO d13_g_stu VALUES (1, 'a', 'a@x', 20);
INSERT INTO d13_g_stu VALUES (2, 'b', NULL, 30);
INSERT INTO d13_g_stu VALUES (3, 'c', NULL, 40);
INSERT INTO d13_g_stu VALUES (4, NULL, 'd@x', 50);
INSERT INTO d13_g_stu VALUES (5, 'e', 'e@x', 200);
COMMIT;
CREATE OR REPLACE VIEW ans13_05_g1 AS SELECT id FROM d13_g_stu;
CREATE OR REPLACE VIEW exp13_05_g1 (id) AS SELECT 1 FROM dual UNION ALL SELECT 2 FROM dual UNION ALL SELECT 3 FROM dual;
EXEC lab_check('13-ex05-G1', 'ANS13_05_G1', 'EXP13_05_G1')
SELECT * FROM ans13_05_g1 ORDER BY id;
