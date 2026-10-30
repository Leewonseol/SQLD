-- H. 정답 및 검증 | 14 ex01 | Oracle
EXEC lab_drop('D14_G_ACC')
CREATE TABLE d14_g_acc (id NUMBER PRIMARY KEY, bal NUMBER);
INSERT INTO d14_g_acc VALUES (1, 100);
INSERT INTO d14_g_acc VALUES (2, 100);
COMMIT;
-- [학습자 작성 구간 시작]
INSERT INTO d14_g_acc VALUES (3, 300);
SAVEPOINT a;
UPDATE d14_g_acc SET bal = 0 WHERE id = 1;
SAVEPOINT b;
DELETE FROM d14_g_acc WHERE id = 2;
ROLLBACK TO SAVEPOINT a;
COMMIT;
-- [학습자 작성 구간 끝]
-- 해설: 저장점 a 이후의 UPDATE·DELETE 가 모두 취소되고, a 이전의 INSERT 는 남는다. 저장점 b 는 a 로 롤백하면서 사라진다.
CREATE OR REPLACE VIEW ans14_01_g1 AS SELECT id, bal FROM d14_g_acc;
CREATE OR REPLACE VIEW exp14_01_g1 (id, bal) AS SELECT 1, 100 FROM dual UNION ALL SELECT 2, 100 FROM dual UNION ALL SELECT 3, 300 FROM dual;
EXEC lab_check('14-ex01-G1', 'ANS14_01_G1', 'EXP14_01_G1')
SELECT * FROM ans14_01_g1 ORDER BY id;
