-- ex07 인라인 뷰(파생 테이블)  | SQL Server : 파생 테이블에는 별칭이 필수
PRINT N'== [Q1] 작가별 평균 가격 (INT 평균은 정수)';
SELECT artist_id, AVG(price) AS avg_price FROM paintings GROUP BY artist_id ORDER BY artist_id;
PRINT N'== [Q2] 작가별 평균보다 비싼 그림';
SELECT p.artist_id, p.name, p.price, p2.avg_price
FROM paintings p, (SELECT artist_id, AVG(price) AS avg_price FROM paintings GROUP BY artist_id) p2
WHERE p.artist_id = p2.artist_id AND p.price > p2.avg_price
ORDER BY p.artist_id;
PRINT N'== [Q3] 인라인 뷰 컬럼을 SELECT·ORDER BY 에서';
SELECT a.name, v.cnt, v.avg_price FROM artists a JOIN (SELECT artist_id, COUNT(*) cnt, AVG(price) avg_price FROM paintings GROUP BY artist_id) v
  ON a.id = v.artist_id ORDER BY v.avg_price DESC;
GO
PRINT N'== [Q4] 별칭 없는 파생 테이블 -> 오류';
GO
-- @expect-error: MSG-102
SELECT COUNT(*) AS cnt FROM (SELECT * FROM paintings WHERE price > 500000);
GO
