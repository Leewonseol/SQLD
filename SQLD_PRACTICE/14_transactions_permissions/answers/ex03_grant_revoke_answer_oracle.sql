-- H. 정답 및 검증 | 14 ex03 | Oracle
EXEC lab_drop('D14_G_TAB')
CREATE TABLE d14_g_tab (id NUMBER);
-- [학습자 작성 구간 시작]
GRANT SELECT, UPDATE ON d14_g_tab TO sqld_lab_u2;
REVOKE UPDATE ON d14_g_tab FROM sqld_lab_u2;
-- [학습자 작성 구간 끝]
CREATE OR REPLACE VIEW ans14_03_g1 AS SELECT grantee, privilege FROM user_tab_privs_made WHERE table_name = 'D14_G_TAB';
CREATE OR REPLACE VIEW exp14_03_g1 (grantee, privilege) AS SELECT 'SQLD_LAB_U2', 'SELECT' FROM dual;
EXEC lab_check('14-ex03-G1', 'ANS14_03_G1', 'EXP14_03_G1')
SELECT * FROM ans14_03_g1;
EXEC lab_drop('D14_G_TAB')
