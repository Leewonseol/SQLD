-- 15 Q2 1:N 관계 두 개를 함께 조인할 때의 행 수 증가 | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q2_c1 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, NVL(SUM(p.amount), 0), COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
SELECT * FROM x15v_q2_c1 ORDER BY 1, 2, 3;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q2_c2 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, NVL(SUM(DISTINCT p.amount), 0), COUNT(DISTINCT w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
SELECT * FROM x15v_q2_c2 ORDER BY 1, 2, 3;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q2_c3 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, NVL(p.s, 0), NVL(w.n, 0) FROM x15_customer c
 LEFT JOIN (SELECT cust_id, SUM(amount) s FROM x15_payment GROUP BY cust_id) p ON p.cust_id = c.cust_id
 LEFT JOIN (SELECT cust_id, COUNT(*) n FROM x15_watch GROUP BY cust_id) w ON w.cust_id = c.cust_id;
SELECT * FROM x15v_q2_c3 ORDER BY 1, 2, 3;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q2_c4 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, NVL(SUM(p.amount), 0), COUNT(*) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
SELECT * FROM x15v_q2_c4 ORDER BY 1, 2, 3;

CREATE OR REPLACE VIEW x15v_q2_exp (cust_id, pay_sum, watch_cnt) AS
-- (cust_id, pay_sum, watch_cnt)
SELECT 'C1', 20000, 3 FROM dual
UNION ALL SELECT 'C2', 0, 1 FROM dual
UNION ALL SELECT 'C3', 5000, 1 FROM dual
UNION ALL SELECT 'C4', 0, 0 FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q2_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_c1 MINUS SELECT * FROM x15v_q2_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_exp MINUS SELECT * FROM x15v_q2_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q2_c1) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q2_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_c2 MINUS SELECT * FROM x15v_q2_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_exp MINUS SELECT * FROM x15v_q2_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q2_c2) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q2_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_c3 MINUS SELECT * FROM x15v_q2_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_exp MINUS SELECT * FROM x15v_q2_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q2_c3) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q2_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_c4 MINUS SELECT * FROM x15v_q2_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q2_exp MINUS SELECT * FROM x15v_q2_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q2_c4) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q2-answer-3', 'X15V_Q2_C3', 'X15V_Q2_EXP')
DROP VIEW x15v_q2_c1;
DROP VIEW x15v_q2_c2;
DROP VIEW x15v_q2_c3;
DROP VIEW x15v_q2_c4;
DROP VIEW x15v_q2_exp;
