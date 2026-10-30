-- 15 Q8 NULL이 집계 결과를 바꾸는 경우 | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q8_c1 (avg_amt) AS
SELECT SUM(amount) / COUNT(*) FROM x15_payment;
SELECT * FROM x15v_q8_c1 ORDER BY 1;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q8_c2 (avg_amt) AS
SELECT AVG(NVL(amount, 0)) FROM x15_payment;
SELECT * FROM x15v_q8_c2 ORDER BY 1;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q8_c3 (avg_amt) AS
SELECT AVG(amount) FROM x15_payment;
SELECT * FROM x15v_q8_c3 ORDER BY 1;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q8_c4 (avg_amt) AS
SELECT AVG(amount) FROM x15_payment p JOIN x15_customer c ON p.cust_id = c.cust_id;
SELECT * FROM x15v_q8_c4 ORDER BY 1;

CREATE OR REPLACE VIEW x15v_q8_exp (avg_amt) AS
-- (avg_amt)
SELECT 7000 FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q8_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_c1 MINUS SELECT * FROM x15v_q8_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_exp MINUS SELECT * FROM x15v_q8_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q8_c1) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q8_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_c2 MINUS SELECT * FROM x15v_q8_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_exp MINUS SELECT * FROM x15v_q8_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q8_c2) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q8_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_c3 MINUS SELECT * FROM x15v_q8_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_exp MINUS SELECT * FROM x15v_q8_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q8_c3) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q8_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_c4 MINUS SELECT * FROM x15v_q8_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q8_exp MINUS SELECT * FROM x15v_q8_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q8_c4) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q8-answer-3', 'X15V_Q8_C3', 'X15V_Q8_EXP')
DROP VIEW x15v_q8_c1;
DROP VIEW x15v_q8_c2;
DROP VIEW x15v_q8_c3;
DROP VIEW x15v_q8_c4;
DROP VIEW x15v_q8_exp;
