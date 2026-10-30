-- 15 Q1 PK 누락으로 생긴 JOIN 결과 오류 | Oracle | 생성: tools/gen_exam.py (명세 tools/answer_specs/exam15.py)

PROMPT == [보기 ①]
CREATE OR REPLACE VIEW x15v_q1_c1 (genre, cnt) AS
SELECT c.genre, COUNT(*) FROM x15_watch w JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
SELECT * FROM x15v_q1_c1 ORDER BY 1, 2;

PROMPT == [보기 ②]
CREATE OR REPLACE VIEW x15v_q1_c2 (genre, cnt) AS
SELECT c.genre, COUNT(*) FROM x15_watch w JOIN (SELECT DISTINCT content_id, genre FROM x15_content_nopk) c ON w.content_id = c.content_id GROUP BY c.genre;
SELECT * FROM x15v_q1_c2 ORDER BY 1, 2;

PROMPT == [보기 ③]
CREATE OR REPLACE VIEW x15v_q1_c3 (genre, cnt) AS
SELECT c.genre, COUNT(DISTINCT w.content_id) FROM x15_watch w JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
SELECT * FROM x15v_q1_c3 ORDER BY 1, 2;

PROMPT == [보기 ④]
CREATE OR REPLACE VIEW x15v_q1_c4 (genre, cnt) AS
SELECT c.genre, COUNT(c.content_id) FROM x15_watch w LEFT JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
SELECT * FROM x15v_q1_c4 ORDER BY 1, 2;

CREATE OR REPLACE VIEW x15v_q1_exp (genre, cnt) AS
-- (genre, cnt)
SELECT 'DOCU', 1 FROM dual
UNION ALL SELECT 'EDU', 2 FROM dual
UNION ALL SELECT 'MOVIE', 2 FROM dual;
PROMPT == [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
SELECT '①' AS choice, (SELECT COUNT(*) FROM x15v_q1_c1) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_c1 MINUS SELECT * FROM x15v_q1_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_exp MINUS SELECT * FROM x15v_q1_c1)) = 0 AND (SELECT COUNT(*) FROM x15v_q1_c1) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '②' AS choice, (SELECT COUNT(*) FROM x15v_q1_c2) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_c2 MINUS SELECT * FROM x15v_q1_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_exp MINUS SELECT * FROM x15v_q1_c2)) = 0 AND (SELECT COUNT(*) FROM x15v_q1_c2) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '③' AS choice, (SELECT COUNT(*) FROM x15v_q1_c3) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_c3 MINUS SELECT * FROM x15v_q1_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_exp MINUS SELECT * FROM x15v_q1_c3)) = 0 AND (SELECT COUNT(*) FROM x15v_q1_c3) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual
UNION ALL SELECT '④' AS choice, (SELECT COUNT(*) FROM x15v_q1_c4) AS rows_cnt, CASE WHEN (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_c4 MINUS SELECT * FROM x15v_q1_exp)) = 0 AND (SELECT COUNT(*) FROM (SELECT * FROM x15v_q1_exp MINUS SELECT * FROM x15v_q1_c4)) = 0 AND (SELECT COUNT(*) FROM x15v_q1_c4) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict FROM dual;
EXEC lab_check('15-Q1-answer-2', 'X15V_Q1_C2', 'X15V_Q1_EXP')
DROP VIEW x15v_q1_c1;
DROP VIEW x15v_q1_c2;
DROP VIEW x15v_q1_c3;
DROP VIEW x15v_q1_c4;
DROP VIEW x15v_q1_exp;
