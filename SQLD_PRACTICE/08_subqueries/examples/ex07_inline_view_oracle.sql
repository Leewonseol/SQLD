-- ex07 인라인 뷰 (PDF E-21 "FROM 절에 작성하여 일시적인 테이블처럼", "동적 뷰", "일회성")  | Oracle  데이터: [PDF] PAINTINGS
PROMPT == [Q1] 인라인 뷰가 만드는 중간 결과: 작가별 평균 가격 (PDF 실행 원리 (1))
SELECT artist_id, AVG(price) AS avg_price FROM paintings GROUP BY artist_id ORDER BY artist_id;

PROMPT == [Q2] PDF 예: 작가별 평균 가격보다 비싼 그림 (인라인 뷰 p2 와 조인)
SELECT p.artist_id, p.name, p.price, p2.avg_price
FROM paintings p, (SELECT artist_id, AVG(price) AS avg_price FROM paintings GROUP BY artist_id) p2
WHERE p.artist_id = p2.artist_id AND p.price > p2.avg_price
ORDER BY p.artist_id;

PROMPT == [Q3] 인라인 뷰의 컬럼은 바깥 쿼리 어느 절에서나 쓸 수 있다 (중첩 서브쿼리와 다른 점): SELECT·ORDER BY 에서 avg_price 사용
SELECT a.name, v.cnt, v.avg_price FROM artists a JOIN (SELECT artist_id, COUNT(*) cnt, AVG(price) avg_price FROM paintings GROUP BY artist_id) v
  ON a.id = v.artist_id ORDER BY v.avg_price DESC;

PROMPT == [Q4] Oracle 은 단독 인라인 뷰에 별칭이 없어도 된다
SELECT COUNT(*) AS cnt FROM (SELECT * FROM paintings WHERE price > 500000);
