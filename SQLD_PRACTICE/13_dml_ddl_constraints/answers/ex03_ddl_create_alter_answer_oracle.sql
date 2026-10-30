-- H. 정답 및 검증 | 13 ex03 | Oracle
EXEC lab_drop('D13_G_BOOK')
-- [학습자 작성 구간 시작]
CREATE TABLE d13_g_book (id NUMBER PRIMARY KEY, title VARCHAR2(30) NOT NULL);
ALTER TABLE d13_g_book ADD (price NUMBER DEFAULT 0);
ALTER TABLE d13_g_book RENAME COLUMN title TO book_title;
-- [학습자 작성 구간 끝]
CREATE OR REPLACE VIEW ans13_03_g1 AS SELECT LOWER(column_name) column_name, nullable FROM user_tab_columns WHERE table_name = 'D13_G_BOOK';
CREATE OR REPLACE VIEW exp13_03_g1 (column_name, nullable) AS
SELECT 'id', 'N' FROM dual UNION ALL SELECT 'book_title', 'N' FROM dual UNION ALL SELECT 'price', 'Y' FROM dual;
EXEC lab_check('13-ex03-G1', 'ANS13_03_G1', 'EXP13_03_G1')
SELECT * FROM ans13_03_g1 ORDER BY 1;
EXEC lab_drop('D13_G_BOOK')
