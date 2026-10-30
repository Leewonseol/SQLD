-- 15 Q1 PK 누락으로 생긴 JOIN 결과 오류 | SQL Server | 생성: tools/gen_exam.py
PRINT N'== [보기 ①]';
GO
CREATE OR ALTER VIEW x15v_q1_c1 (genre, cnt) AS
SELECT c.genre, COUNT(*) FROM x15_watch w JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
GO
SELECT * FROM x15v_q1_c1 ORDER BY 1, 2;
GO
PRINT N'== [보기 ②]';
GO
CREATE OR ALTER VIEW x15v_q1_c2 (genre, cnt) AS
SELECT c.genre, COUNT(*) FROM x15_watch w JOIN (SELECT DISTINCT content_id, genre FROM x15_content_nopk) c ON w.content_id = c.content_id GROUP BY c.genre;
GO
SELECT * FROM x15v_q1_c2 ORDER BY 1, 2;
GO
PRINT N'== [보기 ③]';
GO
CREATE OR ALTER VIEW x15v_q1_c3 (genre, cnt) AS
SELECT c.genre, COUNT(DISTINCT w.content_id) FROM x15_watch w JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
GO
SELECT * FROM x15v_q1_c3 ORDER BY 1, 2;
GO
PRINT N'== [보기 ④]';
GO
CREATE OR ALTER VIEW x15v_q1_c4 (genre, cnt) AS
SELECT c.genre, COUNT(c.content_id) FROM x15_watch w LEFT JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
GO
SELECT * FROM x15v_q1_c4 ORDER BY 1, 2;
GO
CREATE OR ALTER VIEW x15v_q1_exp (genre, cnt) AS
SELECT * FROM (VALUES (N'DOCU', 1),
       (N'EDU', 2),
       (N'MOVIE', 2)) v(genre, cnt);
GO
PRINT N'== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)';
SELECT N'①' AS choice, (SELECT COUNT(*) FROM x15v_q1_c1) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q1_c1 EXCEPT SELECT * FROM x15v_q1_exp) AND NOT EXISTS (SELECT * FROM x15v_q1_exp EXCEPT SELECT * FROM x15v_q1_c1) AND (SELECT COUNT(*) FROM x15v_q1_c1) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'②' AS choice, (SELECT COUNT(*) FROM x15v_q1_c2) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q1_c2 EXCEPT SELECT * FROM x15v_q1_exp) AND NOT EXISTS (SELECT * FROM x15v_q1_exp EXCEPT SELECT * FROM x15v_q1_c2) AND (SELECT COUNT(*) FROM x15v_q1_c2) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'③' AS choice, (SELECT COUNT(*) FROM x15v_q1_c3) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q1_c3 EXCEPT SELECT * FROM x15v_q1_exp) AND NOT EXISTS (SELECT * FROM x15v_q1_exp EXCEPT SELECT * FROM x15v_q1_c3) AND (SELECT COUNT(*) FROM x15v_q1_c3) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict
UNION ALL SELECT N'④' AS choice, (SELECT COUNT(*) FROM x15v_q1_c4) AS rows_cnt, CASE WHEN NOT EXISTS (SELECT * FROM x15v_q1_c4 EXCEPT SELECT * FROM x15v_q1_exp) AND NOT EXISTS (SELECT * FROM x15v_q1_exp EXCEPT SELECT * FROM x15v_q1_c4) AND (SELECT COUNT(*) FROM x15v_q1_c4) = (SELECT COUNT(*) FROM x15v_q1_exp) THEN 'MATCH' ELSE 'DIFF' END AS verdict;
EXEC lab_check N'15-Q1-answer-2', N'x15v_q1_c2', N'x15v_q1_exp';
DROP VIEW x15v_q1_c1, x15v_q1_c2, x15v_q1_c3, x15v_q1_c4, x15v_q1_exp;
GO
