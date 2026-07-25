-- [골격 코드 - 현재 실행 불가]
-- orders / order_items / order_payments / order_reviews / products 테이블이 없어
-- 이 파일을 그대로 실행하면 "no such table" 오류가 난다. 파일이 추가되면
-- ../../02-관계파일확인/skeleton_load_other_tables.py로 적재한 뒤, 실제 컬럼명에 맞춰
-- 아래 이름들을 수정하고 사용할 것.

-- 1) 기술통계: 고객별 주문 수 / 총 결제액 / 평균 결제액
-- SELECT
--     c.customer_unique_id,
--     COUNT(DISTINCT o.order_id) AS n_orders,
--     SUM(p.payment_value) AS total_payment,
--     AVG(p.payment_value) AS avg_payment
-- FROM customers c
-- JOIN orders o ON o.customer_id = c.customer_id
-- JOIN order_payments p ON p.order_id = o.order_id
-- GROUP BY c.customer_unique_id;

-- 2) 결측치: 배송 완료일이 비어있는(=아직 미배송이거나 취소) 주문 비율
-- SELECT
--     COUNT(*) AS n_orders,
--     SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS n_missing_delivery_date,
--     ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_missing
-- FROM orders;

-- 리뷰 점수 결측(주문은 있으나 리뷰가 없는 경우)
-- SELECT
--     COUNT(*) AS n_orders,
--     SUM(CASE WHEN r.review_score IS NULL THEN 1 ELSE 0 END) AS n_orders_without_review
-- FROM orders o
-- LEFT JOIN order_reviews r ON r.order_id = o.order_id;

-- 3) 이상치: 배송기간(일) 분포와 상위 1% 임계값 (SQLite에는 PERCENTILE_CONT가 없으므로
--    01-기본탐색에서 쓴 ROW_NUMBER 기반 백분위수 계산 패턴을 재사용)
-- WITH delivery_days AS (
--     SELECT
--         order_id,
--         JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp) AS days
--     FROM orders
--     WHERE order_delivered_customer_date IS NOT NULL
-- ),
-- ordered AS (
--     SELECT days, ROW_NUMBER() OVER (ORDER BY days) AS rn, COUNT(*) OVER () AS n
--     FROM delivery_days
-- )
-- SELECT MAX(CASE WHEN rn = CAST(0.99*n AS INT)+1 THEN days END) AS p99_delivery_days
-- FROM ordered;

-- 고액 결제(payment_value) 이상치: 배송비(freight_value)가 상품가(price)보다 큰 비정상 케이스
-- SELECT COUNT(*) AS n_freight_gt_price
-- FROM order_items
-- WHERE freight_value > price;

-- 이 DB에 orders/order_items/order_payments/order_reviews/products가 없다는 것을
-- sqlite_master로 확인 (없으면 빈 결과 = 위 주석 처리된 쿼리들을 실행할 수 없다는 뜻)
SELECT name AS existing_required_tables
FROM sqlite_master
WHERE type = 'table'
  AND name IN ('orders', 'order_items', 'order_payments', 'order_reviews', 'products');
