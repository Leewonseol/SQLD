-- 15 Q3 LEFT JOIN과 WHERE 조건의 상호작용 | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q3_c1 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_watch w ON w.cust_id = c.cust_id LEFT JOIN x15_content t ON t.content_id = w.content_id WHERE t.genre = 'MOVIE' GROUP BY c.cust_id;
SELECT * FROM x15v_q3_c1 ORDER BY 1, 2;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q3_c2 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(m.content_id) FROM x15_customer c LEFT JOIN (SELECT w.cust_id, w.content_id FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE') m ON m.cust_id = c.cust_id GROUP BY c.cust_id;
SELECT * FROM x15v_q3_c2 ORDER BY 1, 2;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q3_c3 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_watch w ON w.cust_id = c.cust_id LEFT JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE' GROUP BY c.cust_id;
SELECT * FROM x15v_q3_c3 ORDER BY 1, 2;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q3_c4 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(*) FROM x15_customer c LEFT JOIN (SELECT w.cust_id, w.content_id FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE') m ON m.cust_id = c.cust_id GROUP BY c.cust_id;
SELECT * FROM x15v_q3_c4 ORDER BY 1, 2;

CREATE OR REPLACE VIEW x15v_q3_exp (cust_id, movie_cnt) AS
-- (cust_id, movie_cnt)
SELECT 'C1', 1 FROM dual
UNION ALL SELECT 'C2', 1 FROM dual
UNION ALL SELECT 'C3', 0 FROM dual
UNION ALL SELECT 'C4', 0 FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q3_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_c1 MINUS SELECT * FROM x15v_q3_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_exp MINUS SELECT * FROM x15v_q3_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q3_c1) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q3_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_c2 MINUS SELECT * FROM x15v_q3_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_exp MINUS SELECT * FROM x15v_q3_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q3_c2) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q3_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_c3 MINUS SELECT * FROM x15v_q3_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_exp MINUS SELECT * FROM x15v_q3_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q3_c3) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q3_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_c4 MINUS SELECT * FROM x15v_q3_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q3_exp MINUS SELECT * FROM x15v_q3_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q3_c4) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q3-answer-2', 'X15V_Q3_C2', 'X15V_Q3_EXP')
DROP VIEW x15v_q3_c1;
DROP VIEW x15v_q3_c2;
DROP VIEW x15v_q3_c3;
DROP VIEW x15v_q3_c4;
DROP VIEW x15v_q3_exp;
