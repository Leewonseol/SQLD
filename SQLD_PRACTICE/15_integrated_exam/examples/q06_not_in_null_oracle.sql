-- 15 Q6 결제 기록이 없는 고객 — NOT IN과 NULL | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q6_c1 (cust_id) AS
SELECT cust_id FROM x15_customer WHERE cust_id NOT IN (SELECT cust_id FROM x15_payment);
SELECT * FROM x15v_q6_c1 ORDER BY 1;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q6_c2 (cust_id) AS
SELECT c.cust_id FROM x15_customer c WHERE NOT EXISTS (SELECT 1 FROM x15_payment p WHERE p.cust_id = c.cust_id);
SELECT * FROM x15v_q6_c2 ORDER BY 1;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q6_c3 (cust_id) AS
SELECT c.cust_id FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id WHERE p.amount IS NULL;
SELECT * FROM x15v_q6_c3 ORDER BY 1;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q6_c4 (cust_id) AS
SELECT cust_id FROM x15_customer WHERE cust_id NOT IN (SELECT cust_id FROM x15_payment WHERE amount IS NOT NULL);
SELECT * FROM x15v_q6_c4 ORDER BY 1;

CREATE OR REPLACE VIEW x15v_q6_exp (cust_id) AS
-- (cust_id)
SELECT 'C4' FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q6_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_c1 MINUS SELECT * FROM x15v_q6_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_exp MINUS SELECT * FROM x15v_q6_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q6_c1) = (SELECT COUNT(*) FROM x15v_q6_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q6_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_c2 MINUS SELECT * FROM x15v_q6_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_exp MINUS SELECT * FROM x15v_q6_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q6_c2) = (SELECT COUNT(*) FROM x15v_q6_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q6_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_c3 MINUS SELECT * FROM x15v_q6_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_exp MINUS SELECT * FROM x15v_q6_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q6_c3) = (SELECT COUNT(*) FROM x15v_q6_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q6_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_c4 MINUS SELECT * FROM x15v_q6_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q6_exp MINUS SELECT * FROM x15v_q6_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q6_c4) = (SELECT COUNT(*) FROM x15v_q6_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q6-answer-2', 'X15V_Q6_C2', 'X15V_Q6_EXP')
DROP VIEW x15v_q6_c1;
DROP VIEW x15v_q6_c2;
DROP VIEW x15v_q6_c3;
DROP VIEW x15v_q6_c4;
DROP VIEW x15v_q6_exp;
