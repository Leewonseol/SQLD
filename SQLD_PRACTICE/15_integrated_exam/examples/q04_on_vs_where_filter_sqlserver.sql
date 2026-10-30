-- 15 Q4 기준 테이블 조건을 ON에 둘 것인가 WHERE에 둘 것인가 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q4_c1 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id AND c.grade = 'GOLD' GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q4_c1 ORDER BY 1, 2;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q4_c2 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q4_c2 ORDER BY 1, 2;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q4_c3 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q4_c3 ORDER BY 1, 2;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q4_c4 (cust_id, wish_cnt) AS
SELECT c.cust_id, COUNT(*) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
GO
SELECT * FROM x15v_q4_c4 ORDER BY 1, 2;
GO
CREATE OR ALTER VIEW x15v_q4_exp (cust_id, wish_cnt) AS
SELECT * FROM (VALUES (N'C2', 2),
       (N'C3', 0)) v(cust_id, wish_cnt);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q4_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q4_c1 EXCEPT SELECT * FROM x15v_q4_exp) AND NOT EXISTS (SELECT * FROM x15v_q4_exp EXCEPT SELECT * FROM x15v_q4_c1) AND (SELECT COUNT(*) FROM x15v_q4_c1) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q4_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q4_c2 EXCEPT SELECT * FROM x15v_q4_exp) AND NOT EXISTS (SELECT * FROM x15v_q4_exp EXCEPT SELECT * FROM x15v_q4_c2) AND (SELECT COUNT(*) FROM x15v_q4_c2) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q4_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q4_c3 EXCEPT SELECT * FROM x15v_q4_exp) AND NOT EXISTS (SELECT * FROM x15v_q4_exp EXCEPT SELECT * FROM x15v_q4_c3) AND (SELECT COUNT(*) FROM x15v_q4_c3) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q4_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q4_c4 EXCEPT SELECT * FROM x15v_q4_exp) AND NOT EXISTS (SELECT * FROM x15v_q4_exp EXCEPT SELECT * FROM x15v_q4_c4) AND (SELECT COUNT(*) FROM x15v_q4_c4) = (SELECT COUNT(*) FROM x15v_q4_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q4-answer-2', N'x15v_q4_c2', N'x15v_q4_exp';
DROP VIEW x15v_q4_c1, x15v_q4_c2, x15v_q4_c3, x15v_q4_c4, x15v_q4_exp;
GO
