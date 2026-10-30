-- 15 Q7 GROUP BY와 윈도우 함수의 차이 | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q7_c1 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT cust_id, MAX(content_id), TO_CHAR(MAX(watch_dt), 'YYYY-MM-DD'), COUNT(*) FROM x15_watch GROUP BY cust_id;
SELECT * FROM x15v_q7_c1 ORDER BY 1, 2, 3, 4;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q7_c2 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT cust_id, content_id, TO_CHAR(watch_dt, 'YYYY-MM-DD'), COUNT(*) FROM x15_watch GROUP BY cust_id, content_id, watch_dt;
SELECT * FROM x15v_q7_c2 ORDER BY 1, 2, 3, 4;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q7_c3 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT cust_id, content_id, TO_CHAR(watch_dt, 'YYYY-MM-DD'), COUNT(*) OVER (PARTITION BY cust_id) FROM x15_watch;
SELECT * FROM x15v_q7_c3 ORDER BY 1, 2, 3, 4;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q7_c4 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT w.cust_id, w.content_id, TO_CHAR(w.watch_dt, 'YYYY-MM-DD'), (SELECT COUNT(*) FROM x15_watch x WHERE x.content_id = w.content_id) FROM x15_watch w;
SELECT * FROM x15v_q7_c4 ORDER BY 1, 2, 3, 4;

CREATE OR REPLACE VIEW x15v_q7_exp (cust_id, content_id, watch_ymd, cust_cnt) AS
-- (cust_id, content_id, watch_ymd, cust_cnt)
SELECT 'C1', 'T1', '2024-03-01', 3 FROM dual
UNION ALL SELECT 'C1', 'T1', '2024-03-05', 3 FROM dual
UNION ALL SELECT 'C1', 'T2', '2024-03-02', 3 FROM dual
UNION ALL SELECT 'C2', 'T2', '2024-03-03', 1 FROM dual
UNION ALL SELECT 'C3', 'T3', '2024-03-04', 1 FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q7_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_c1 MINUS SELECT * FROM x15v_q7_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_exp MINUS SELECT * FROM x15v_q7_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q7_c1) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q7_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_c2 MINUS SELECT * FROM x15v_q7_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_exp MINUS SELECT * FROM x15v_q7_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q7_c2) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q7_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_c3 MINUS SELECT * FROM x15v_q7_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_exp MINUS SELECT * FROM x15v_q7_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q7_c3) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q7_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_c4 MINUS SELECT * FROM x15v_q7_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q7_exp MINUS SELECT * FROM x15v_q7_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q7_c4) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q7-answer-3', 'X15V_Q7_C3', 'X15V_Q7_EXP')
DROP VIEW x15v_q7_c1;
DROP VIEW x15v_q7_c2;
DROP VIEW x15v_q7_c3;
DROP VIEW x15v_q7_c4;
DROP VIEW x15v_q7_exp;
