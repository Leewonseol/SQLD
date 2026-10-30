-- 06_group_having/setup_oracle.sql (재실행 가능) 데이터: [가상] + 00_common EMP·DEPT
EXEC lab_drop('G_NUM')
EXEC lab_drop('G_EMPTY')
CREATE TABLE g_num (id NUMBER CONSTRAINT pk_g_num PRIMARY KEY, grp VARCHAR2(1), v NUMBER(5));
INSERT INTO g_num VALUES (1, 'a', 1);
INSERT INTO g_num VALUES (2, 'a', 2);
INSERT INTO g_num VALUES (3, 'b', NULL);
INSERT INTO g_num VALUES (4, 'b', 4);
INSERT INTO g_num VALUES (5, NULL, 4);
CREATE TABLE g_empty (v NUMBER);
COMMIT;
