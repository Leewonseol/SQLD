-- 05_where_conditions/setup_oracle.sql  (재실행 가능)  데이터: [가상] 학습용 가상 데이터 + 00_common EMP
EXEC lab_drop('W_LIKE')
EXEC lab_drop('W_TS')
EXEC lab_drop('W_CODE')
CREATE TABLE w_like (id NUMBER CONSTRAINT pk_w_like PRIMARY KEY, txt VARCHAR2(20));
INSERT INTO w_like VALUES (1, 'A_B');
INSERT INTO w_like VALUES (2, 'AXB');
INSERT INTO w_like VALUES (3, 'AB');
INSERT INTO w_like VALUES (4, '100%');
INSERT INTO w_like VALUES (5, '1000');
INSERT INTO w_like VALUES (6, 'ab');
INSERT INTO w_like VALUES (7, NULL);
-- 시각이 포함된 일시 (Oracle DATE 는 초 단위 시각을 포함한다)
CREATE TABLE w_ts (id NUMBER CONSTRAINT pk_w_ts PRIMARY KEY, ts DATE);
INSERT INTO w_ts VALUES (1, TO_DATE('2024-03-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO w_ts VALUES (2, TO_DATE('2024-03-15 09:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO w_ts VALUES (3, TO_DATE('2024-03-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO w_ts VALUES (4, TO_DATE('2024-03-31 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO w_ts VALUES (5, TO_DATE('2024-04-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
-- 문자 컬럼에 숫자처럼 보이는 값과 아닌 값이 섞인 경우
CREATE TABLE w_code (id NUMBER CONSTRAINT pk_w_code PRIMARY KEY, code VARCHAR2(5));
INSERT INTO w_code VALUES (1, '001');
INSERT INTO w_code VALUES (2, '01');
INSERT INTO w_code VALUES (3, '1');
INSERT INTO w_code VALUES (4, '10');
INSERT INTO w_code VALUES (5, 'A1');
COMMIT;
PROMPT 05 setup done
