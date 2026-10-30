-- 15 Q7 GROUP BY와 윈도우 함수의 차이 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q7_c1 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT cust_id, MAX(content_id), CONVERT(CHAR(10), MAX(watch_dt), 23), COUNT(*) FROM x15_watch GROUP BY cust_id;
GO
SELECT * FROM x15v_q7_c1 ORDER BY 1, 2, 3, 4;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q7_c2 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT cust_id, content_id, CONVERT(CHAR(10), watch_dt, 23), COUNT(*) FROM x15_watch GROUP BY cust_id, content_id, watch_dt;
GO
SELECT * FROM x15v_q7_c2 ORDER BY 1, 2, 3, 4;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q7_c3 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT cust_id, content_id, CONVERT(CHAR(10), watch_dt, 23), COUNT(*) OVER (PARTITION BY cust_id) FROM x15_watch;
GO
SELECT * FROM x15v_q7_c3 ORDER BY 1, 2, 3, 4;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q7_c4 (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT w.cust_id, w.content_id, CONVERT(CHAR(10), w.watch_dt, 23), (SELECT COUNT(*) FROM x15_watch x WHERE x.content_id = w.content_id) FROM x15_watch w;
GO
SELECT * FROM x15v_q7_c4 ORDER BY 1, 2, 3, 4;
GO
CREATE OR ALTER VIEW x15v_q7_exp (cust_id, content_id, watch_ymd, cust_cnt) AS
SELECT * FROM (VALUES (N'C1', N'T1', N'2024-03-01', 3),
       (N'C1', N'T1', N'2024-03-05', 3),
       (N'C1', N'T2', N'2024-03-02', 3),
       (N'C2', N'T2', N'2024-03-03', 1),
       (N'C3', N'T3', N'2024-03-04', 1)) v(cust_id, content_id, watch_ymd, cust_cnt);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q7_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q7_c1 EXCEPT SELECT * FROM x15v_q7_exp) AND NOT EXISTS (SELECT * FROM x15v_q7_exp EXCEPT SELECT * FROM x15v_q7_c1) AND (SELECT COUNT(*) FROM x15v_q7_c1) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q7_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q7_c2 EXCEPT SELECT * FROM x15v_q7_exp) AND NOT EXISTS (SELECT * FROM x15v_q7_exp EXCEPT SELECT * FROM x15v_q7_c2) AND (SELECT COUNT(*) FROM x15v_q7_c2) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q7_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q7_c3 EXCEPT SELECT * FROM x15v_q7_exp) AND NOT EXISTS (SELECT * FROM x15v_q7_exp EXCEPT SELECT * FROM x15v_q7_c3) AND (SELECT COUNT(*) FROM x15v_q7_c3) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q7_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q7_c4 EXCEPT SELECT * FROM x15v_q7_exp) AND NOT EXISTS (SELECT * FROM x15v_q7_exp EXCEPT SELECT * FROM x15v_q7_c4) AND (SELECT COUNT(*) FROM x15v_q7_c4) = (SELECT COUNT(*) FROM x15v_q7_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q7-answer-3', N'x15v_q7_c3', N'x15v_q7_exp';
DROP VIEW x15v_q7_c1, x15v_q7_c2, x15v_q7_c3, x15v_q7_c4, x15v_q7_exp;
GO
