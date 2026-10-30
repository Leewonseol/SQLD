-- H. 정답 및 검증 | 13 ex06 | Oracle
EXEC lab_drop('D13_G_EMP20')
-- [학습자 작성 구간 시작]
CREATE TABLE d13_g_emp20 AS SELECT * FROM emp WHERE deptno = 20;
ALTER TABLE d13_g_emp20 ADD CONSTRAINT pk_d13_g_emp20 PRIMARY KEY (empno);
-- [학습자 작성 구간 끝]
CREATE OR REPLACE VIEW ans13_06_g1 AS
SELECT (SELECT COUNT(*) FROM d13_g_emp20) row_cnt, (SELECT COUNT(*) FROM user_constraints WHERE table_name = 'D13_G_EMP20' AND constraint_type = 'P') pk_cnt FROM dual;
CREATE OR REPLACE VIEW exp13_06_g1 (row_cnt, pk_cnt) AS SELECT 5, 1 FROM dual;
EXEC lab_check('13-ex06-G1', 'ANS13_06_G1', 'EXP13_06_G1')
SELECT * FROM ans13_06_g1;
