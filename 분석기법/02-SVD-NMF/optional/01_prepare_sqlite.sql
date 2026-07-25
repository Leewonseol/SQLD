-- 고객 x 카테고리 구매금액 롱포맷을 wide 행렬로 PIVOT
-- SQLite는 PIVOT 구문이 없으므로 SUM(CASE WHEN ...) 조건부 집계로 수동 PIVOT한다.
-- (Oracle: PIVOT(SUM(amount) FOR category IN (...)), SQL Server도 동일한 PIVOT 문법)

DROP TABLE IF EXISTS svd_input_matrix;

CREATE TABLE svd_input_matrix AS
SELECT
    customer_id,
    SUM(CASE WHEN category = '전자제품' THEN amount ELSE 0 END) AS 전자제품,
    SUM(CASE WHEN category = '의류'     THEN amount ELSE 0 END) AS 의류,
    SUM(CASE WHEN category = '도서'     THEN amount ELSE 0 END) AS 도서,
    SUM(CASE WHEN category = '식품'     THEN amount ELSE 0 END) AS 식품,
    SUM(CASE WHEN category = '가구'     THEN amount ELSE 0 END) AS 가구,
    SUM(CASE WHEN category = '뷰티'     THEN amount ELSE 0 END) AS 뷰티,
    SUM(CASE WHEN category = '스포츠'   THEN amount ELSE 0 END) AS 스포츠,
    SUM(CASE WHEN category = '완구'     THEN amount ELSE 0 END) AS 완구
FROM customer_category_spend
GROUP BY customer_id;

-- 검산: 행 수 = 고객 수, 음수 금액이 없어야 NMF 비음수 제약 충족
SELECT COUNT(*) AS n_rows,
       MIN(전자제품) AS min_electronics,
       MIN(도서) AS min_books
FROM svd_input_matrix;
