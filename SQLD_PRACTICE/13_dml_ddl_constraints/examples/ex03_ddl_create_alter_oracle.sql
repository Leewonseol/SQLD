-- ex03 CREATE · ALTER · RENAME · DROP (PDF E-04 DDL)  | Oracle
EXEC lab_drop('D13_PROD')
EXEC lab_drop('D13_PRODUCT')
PROMPT == [Q1] CREATE TABLE (자료형·기본값·제약 포함)
CREATE TABLE d13_prod (pid NUMBER(5) CONSTRAINT pk_d13_prod PRIMARY KEY, pname VARCHAR2(10) NOT NULL, price NUMBER(7) DEFAULT 0);
INSERT INTO d13_prod (pid, pname) VALUES (1, 'pencil');
INSERT INTO d13_prod (pid, pname, price) VALUES (2, 'eraser', 500);

PROMPT == [Q2] ALTER TABLE ADD (컬럼 추가: 기존 행은 NULL 또는 DEFAULT)
ALTER TABLE d13_prod ADD (stock NUMBER DEFAULT 10, memo VARCHAR2(20));
SELECT * FROM d13_prod;

PROMPT == [Q3] ALTER TABLE MODIFY (자료형·길이·NOT NULL 변경). 데이터보다 짧게 줄이면 오류
ALTER TABLE d13_prod MODIFY (pname VARCHAR2(20));
-- @expect-error: ORA-01441
ALTER TABLE d13_prod MODIFY (pname VARCHAR2(3));

PROMPT == [Q4] NULL 이 있는 컬럼에 NOT NULL 추가 -> 오류 (기존 데이터 검증)
-- @expect-error: ORA-02296
ALTER TABLE d13_prod MODIFY (memo NOT NULL);

PROMPT == [Q5] RENAME COLUMN / DROP COLUMN / RENAME 테이블
ALTER TABLE d13_prod RENAME COLUMN memo TO note;
ALTER TABLE d13_prod DROP COLUMN note;
RENAME d13_prod TO d13_product;
SELECT column_name, data_type, data_length, nullable FROM user_tab_columns WHERE table_name = 'D13_PRODUCT' ORDER BY column_id;

PROMPT == [Q6] DROP TABLE (PURGE: 휴지통에 남기지 않음)
DROP TABLE d13_product PURGE;
SELECT COUNT(*) AS remaining FROM user_tables WHERE table_name = 'D13_PRODUCT';
