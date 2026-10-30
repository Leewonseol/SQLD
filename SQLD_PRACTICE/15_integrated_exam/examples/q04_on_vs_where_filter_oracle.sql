-- 15 Q4 기준 테이블 조건을 ON에 둘 것인가 WHERE에 둘 것인가 | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q4_c1 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id AND c.grade = 'GOLD' GROUP BY c.cust_id;
SELECT * FROM x15v_q4_c1 ORDER BY 1, 2;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q4_c2 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
SELECT * FROM x15v_q4_c2 ORDER BY 1, 2;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q4_c3 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
SELECT * FROM x15v_q4_c3 ORDER BY 1, 2;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q4_c4 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(*) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
SELECT * FROM x15v_q4_c4 ORDER BY 1, 2;

CREATE OR REPLACE VIEW x15v_q4_exp (cust_id, wish_cnt) AS
-- (cust_id, wish_cnt)
SELECT 'C2', 2 FROM dual
UNION ALL SELECT 'C3', 0 FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q4_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_c1 MINUS SELECT * FROM x15v_q4_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_exp MINUS SELECT * FROM x15v_q4_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q4_c1) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q4_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_c2 MINUS SELECT * FROM x15v_q4_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_exp MINUS SELECT * FROM x15v_q4_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q4_c2) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q4_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_c3 MINUS SELECT * FROM x15v_q4_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_exp MINUS SELECT * FROM x15v_q4_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q4_c3) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q4_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_c4 MINUS SELECT * FROM x15v_q4_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q4_exp MINUS SELECT * FROM x15v_q4_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q4_c4) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q4-answer-2', 'X15V_Q4_C2', 'X15V_Q4_EXP')
DROP VIEW x15v_q4_c1;
DROP VIEW x15v_q4_c2;
DROP VIEW x15v_q4_c3;
DROP VIEW x15v_q4_c4;
DROP VIEW x15v_q4_exp;
