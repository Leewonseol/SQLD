-- 15 Q8 NULL이 집계 결과를 바꾸는 경우 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q8_c1 (avg_amt) AS
SELECT SUM(amount) / COUNT(*) FROM x15_payment;
GO
SELECT * FROM x15v_q8_c1 ORDER BY 1;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q8_c2 (avg_amt) AS
SELECT AVG(ISNULL(amount, 0)) FROM x15_payment;
GO
SELECT * FROM x15v_q8_c2 ORDER BY 1;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q8_c3 (avg_amt) AS
SELECT AVG(amount) FROM x15_payment;
GO
SELECT * FROM x15v_q8_c3 ORDER BY 1;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q8_c4 (avg_amt) AS
SELECT AVG(amount) FROM x15_payment p JOIN x15_customer c ON p.cust_id = c.cust_id;
GO
SELECT * FROM x15v_q8_c4 ORDER BY 1;
GO
CREATE OR ALTER VIEW x15v_q8_exp (avg_amt) AS
SELECT * FROM (VALUES (7000)) v(avg_amt);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q8_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q8_c1 EXCEPT SELECT * FROM x15v_q8_exp) AND NOT EXISTS (SELECT * FROM x15v_q8_exp EXCEPT SELECT * FROM x15v_q8_c1) AND (SELECT COUNT(*) FROM x15v_q8_c1) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q8_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q8_c2 EXCEPT SELECT * FROM x15v_q8_exp) AND NOT EXISTS (SELECT * FROM x15v_q8_exp EXCEPT SELECT * FROM x15v_q8_c2) AND (SELECT COUNT(*) FROM x15v_q8_c2) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q8_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q8_c3 EXCEPT SELECT * FROM x15v_q8_exp) AND NOT EXISTS (SELECT * FROM x15v_q8_exp EXCEPT SELECT * FROM x15v_q8_c3) AND (SELECT COUNT(*) FROM x15v_q8_c3) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q8_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q8_c4 EXCEPT SELECT * FROM x15v_q8_exp) AND NOT EXISTS (SELECT * FROM x15v_q8_exp EXCEPT SELECT * FROM x15v_q8_c4) AND (SELECT COUNT(*) FROM x15v_q8_c4) = (SELECT COUNT(*) FROM x15v_q8_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q8-answer-3', N'x15v_q8_c3', N'x15v_q8_exp';
DROP VIEW x15v_q8_c1, x15v_q8_c2, x15v_q8_c3, x15v_q8_c4, x15v_q8_exp;
GO
