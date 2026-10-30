-- 15 Q3 LEFT JOIN과 WHERE 조건의 상호작용 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q3_c1 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_watch w ON w.cust_id = c.cust_id LEFT JOIN x15_content t ON t.content_id = w.content_id WHERE t.genre = 'MOVIE' GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q3_c1 ORDER BY 1, 2;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q3_c2 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(m.content_id) FROM x15_customer c LEFT JOIN (SELECT w.cust_id, w.content_id FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE') m ON m.cust_id = c.cust_id GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q3_c2 ORDER BY 1, 2;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q3_c3 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_watch w ON w.cust_id = c.cust_id LEFT JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE' GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q3_c3 ORDER BY 1, 2;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q3_c4 (cust_id, movie_cnt) AS
SELECT c.cust_id, COUNT(*) FROM x15_customer c LEFT JOIN (SELECT w.cust_id, w.content_id FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE') m ON m.cust_id = c.cust_id GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q3_c4 ORDER BY 1, 2;
GO
CREATE OR ALTER VIEW x15v_q3_exp (cust_id, movie_cnt) AS
SELECT * FROM (VALUES (N'C1', 1),
       (N'C2', 1),
       (N'C3', 0),
       (N'C4', 0)) v(cust_id, movie_cnt);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q3_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q3_c1 EXCEPT SELECT * FROM x15v_q3_exp) AND NOT EXISTS (SELECT * FROM x15v_q3_exp EXCEPT SELECT * FROM x15v_q3_c1) AND (SELECT COUNT(*) FROM x15v_q3_c1) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q3_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q3_c2 EXCEPT SELECT * FROM x15v_q3_exp) AND NOT EXISTS (SELECT * FROM x15v_q3_exp EXCEPT SELECT * FROM x15v_q3_c2) AND (SELECT COUNT(*) FROM x15v_q3_c2) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q3_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q3_c3 EXCEPT SELECT * FROM x15v_q3_exp) AND NOT EXISTS (SELECT * FROM x15v_q3_exp EXCEPT SELECT * FROM x15v_q3_c3) AND (SELECT COUNT(*) FROM x15v_q3_c3) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q3_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q3_c4 EXCEPT SELECT * FROM x15v_q3_exp) AND NOT EXISTS (SELECT * FROM x15v_q3_exp EXCEPT SELECT * FROM x15v_q3_c4) AND (SELECT COUNT(*) FROM x15v_q3_c4) = (SELECT COUNT(*) FROM x15v_q3_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q3-answer-2', N'x15v_q3_c2', N'x15v_q3_exp';
DROP VIEW x15v_q3_c1, x15v_q3_c2, x15v_q3_c3, x15v_q3_c4, x15v_q3_exp;
GO
