-- 15 Q5 EXISTS·NOT EXISTS — 고객ID만 비교 vs 고객ID+컨텐츠ID 비교 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q5_c1 (cust_id) AS
SELECT c.cust_id FROM x15_customer c WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.cust_id = c.cust_id)
 AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.cust_id = c.cust_id);
GO
SELECT * FROM x15v_q5_c1 ORDER BY 1;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q5_c2 (cust_id) AS
SELECT c.cust_id FROM x15_customer c WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.cust_id = c.cust_id
 AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.cust_id = s.cust_id AND w.content_id = s.content_id));
GO
SELECT * FROM x15v_q5_c2 ORDER BY 1;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q5_c3 (cust_id) AS
SELECT c.cust_id FROM x15_customer c WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.cust_id = c.cust_id
 AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.content_id = s.content_id));
GO
SELECT * FROM x15v_q5_c3 ORDER BY 1;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q5_c4 (cust_id) AS
SELECT DISTINCT s.cust_id FROM x15_wish s JOIN x15_watch w ON w.cust_id = s.cust_id AND w.content_id = s.content_id;
GO
SELECT * FROM x15v_q5_c4 ORDER BY 1;
GO
CREATE OR ALTER VIEW x15v_q5_exp (cust_id) AS
SELECT * FROM (VALUES (N'C1'),
       (N'C2'),
       (N'C4')) v(cust_id);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q5_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q5_c1 EXCEPT SELECT * FROM x15v_q5_exp) AND NOT EXISTS (SELECT * FROM x15v_q5_exp EXCEPT SELECT * FROM x15v_q5_c1) AND (SELECT COUNT(*) FROM x15v_q5_c1) = (SELECT COUNT(*) FROM x15v_q5_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q5_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q5_c2 EXCEPT SELECT * FROM x15v_q5_exp) AND NOT EXISTS (SELECT * FROM x15v_q5_exp EXCEPT SELECT * FROM x15v_q5_c2) AND (SELECT COUNT(*) FROM x15v_q5_c2) = (SELECT COUNT(*) FROM x15v_q5_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q5_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q5_c3 EXCEPT SELECT * FROM x15v_q5_exp) AND NOT EXISTS (SELECT * FROM x15v_q5_exp EXCEPT SELECT * FROM x15v_q5_c3) AND (SELECT COUNT(*) FROM x15v_q5_c3) = (SELECT COUNT(*) FROM x15v_q5_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q5_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q5_c4 EXCEPT SELECT * FROM x15v_q5_exp) AND NOT EXISTS (SELECT * FROM x15v_q5_exp EXCEPT SELECT * FROM x15v_q5_c4) AND (SELECT COUNT(*) FROM x15v_q5_c4) = (SELECT COUNT(*) FROM x15v_q5_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q5-answer-2', N'x15v_q5_c2', N'x15v_q5_exp';
DROP VIEW x15v_q5_c1, x15v_q5_c2, x15v_q5_c3, x15v_q5_c4, x15v_q5_exp;
GO
