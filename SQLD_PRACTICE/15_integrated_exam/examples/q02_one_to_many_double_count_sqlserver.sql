-- 15 Q2 1:N 관계 두 개를 함께 조인할 때의 행 수 증가 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q2_c1 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, ISNULL(SUM(p.amount), 0), COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q2_c1 ORDER BY 1, 2, 3;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q2_c2 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, ISNULL(SUM(DISTINCT p.amount), 0), COUNT(DISTINCT w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q2_c2 ORDER BY 1, 2, 3;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q2_c3 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, ISNULL(p.s, 0), ISNULL(w.n, 0) FROM x15_customer c
 LEFT JOIN (SELECT cust_id, SUM(amount) s FROM x15_payment GROUP BY cust_id) p ON p.cust_id = c.cust_id
 LEFT JOIN (SELECT cust_id, COUNT(*) n FROM x15_watch GROUP BY cust_id) w ON w.cust_id = c.cust_id;
GO
SELECT * FROM x15v_q2_c3 ORDER BY 1, 2, 3;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q2_c4 (cust_id, pay_sum, watch_cnt) AS
SELECT c.cust_id, ISNULL(SUM(p.amount), 0), COUNT(*) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q2_c4 ORDER BY 1, 2, 3;
GO
CREATE OR ALTER VIEW x15v_q2_exp (cust_id, pay_sum, watch_cnt) AS
SELECT * FROM (VALUES (N'C1', 20000, 3),
       (N'C2', 0, 1),
       (N'C3', 5000, 1),
       (N'C4', 0, 0)) v(cust_id, pay_sum, watch_cnt);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q2_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q2_c1 EXCEPT SELECT * FROM x15v_q2_exp) AND NOT EXISTS (SELECT * FROM x15v_q2_exp EXCEPT SELECT * FROM x15v_q2_c1) AND (SELECT COUNT(*) FROM x15v_q2_c1) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q2_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q2_c2 EXCEPT SELECT * FROM x15v_q2_exp) AND NOT EXISTS (SELECT * FROM x15v_q2_exp EXCEPT SELECT * FROM x15v_q2_c2) AND (SELECT COUNT(*) FROM x15v_q2_c2) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q2_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q2_c3 EXCEPT SELECT * FROM x15v_q2_exp) AND NOT EXISTS (SELECT * FROM x15v_q2_exp EXCEPT SELECT * FROM x15v_q2_c3) AND (SELECT COUNT(*) FROM x15v_q2_c3) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q2_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q2_c4 EXCEPT SELECT * FROM x15v_q2_exp) AND NOT EXISTS (SELECT * FROM x15v_q2_exp EXCEPT SELECT * FROM x15v_q2_c4) AND (SELECT COUNT(*) FROM x15v_q2_c4) = (SELECT COUNT(*) FROM x15v_q2_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q2-answer-3', N'x15v_q2_c3', N'x15v_q2_exp';
DROP VIEW x15v_q2_c1, x15v_q2_c2, x15v_q2_c3, x15v_q2_c4, x15v_q2_exp;
GO
