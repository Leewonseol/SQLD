-- 09_set_operations/setup_oracle.sql (재실행 가능) 데이터: [가상] NULL 이 든 작은 집합
EXEC lab_drop('S_A')
EXEC lab_drop('S_B')
EXEC lab_drop('S_C')
CREATE TABLE s_a (v NUMBER);
CREATE TABLE s_b (v NUMBER);
CREATE TABLE s_c (v NUMBER);
INSERT INTO s_a VALUES (1);
INSERT INTO s_a VALUES (2);
INSERT INTO s_a VALUES (2);
INSERT INTO s_a VALUES (NULL);
INSERT INTO s_b VALUES (2);
INSERT INTO s_b VALUES (3);
INSERT INTO s_b VALUES (NULL);
INSERT INTO s_c VALUES (2);
COMMIT;
