-- ex09 CROSS JOIN (PDF E-18)  | SQL Server
PRINT N'== [Q1] CROSS JOIN 9행';
SELECT * FROM cj_t1 CROSS JOIN cj_t2 ORDER BY cj_t1.x2 DESC, cj_t2.y2 DESC;
PRINT N'== [Q2] FROM a, b';
SELECT COUNT(*) AS cartesian_rows FROM cj_t1, cj_t2;
PRINT N'== [Q3] EQUI JOIN 비교';
SELECT a.x1, a.x2, b.y2 FROM cj_t1 a JOIN cj_t2 b ON a.x1 = b.x1 ORDER BY a.x1;
GO
PRINT N'== [Q4] CROSS JOIN 에 ON -> 오류';
GO
-- @expect-error: MSG-156
SELECT * FROM cj_t1 a CROSS JOIN cj_t2 b ON a.x1 = b.x1;
GO
PRINT N'== [Q5] 문자 정렬 비교: x1 오름차순 (기본 데이터 정렬, NULL 은 처음)';
SELECT x1 FROM cj_t1 UNION ALL SELECT x1 FROM cj_t2 ORDER BY 1;
GO
