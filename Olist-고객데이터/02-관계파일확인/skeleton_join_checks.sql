-- [골격 코드 - 현재 실행 불가]
-- orders 테이블이 추가되고 skeleton_load_other_tables.py로 olist_full.db에 적재된 뒤 실행할 것.
-- 지금은 orders 테이블이 없으므로 이 파일을 그대로 실행하면 "no such table: orders" 오류가 난다.
-- 이는 의도된 동작이며, 이 파일은 파일 추가 후 그대로 쓸 수 있도록 미리 작성해 둔 골격이다.

-- 0) 각 테이블 관측단위/행수 (JOIN 전 반드시 기록)
SELECT 'customers' AS table_name, COUNT(*) AS n_rows, COUNT(DISTINCT customer_id) AS n_pk FROM customers;
SELECT 'orders' AS table_name, COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_pk FROM orders;

-- 1) customers <-> orders FK 검증: orders.customer_id가 customers.customer_id에 다 존재하는가
SELECT COUNT(*) AS n_orders_without_customer
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- 2) 관계 종류 확인: 고객(customer_id) 하나당 주문이 몇 건인지 분포 (1:N 관계 확인)
SELECT n_orders_per_customer, COUNT(*) AS n_customers
FROM (
    SELECT customer_id, COUNT(*) AS n_orders_per_customer
    FROM orders
    GROUP BY customer_id
) t
GROUP BY n_orders_per_customer
ORDER BY n_orders_per_customer;

-- 3) JOIN 전/후 행수 비교 (customers 1건이 orders 여러 건과 만나면 fan-out 발생 -> 증식 확인)
SELECT
    (SELECT COUNT(*) FROM customers) AS customers_rows,
    (SELECT COUNT(*) FROM orders) AS orders_rows,
    (SELECT COUNT(*) FROM customers c JOIN orders o ON o.customer_id = c.customer_id) AS joined_rows;

-- 4) order_items까지 결합 시 중복 증식 확인 (order 1건에 상품 여러 개 -> 행수가 orders보다 커야 정상)
-- SELECT
--     (SELECT COUNT(*) FROM orders) AS orders_rows,
--     (SELECT COUNT(*) FROM order_items) AS order_items_rows,
--     (SELECT COUNT(*) FROM orders o JOIN order_items oi ON oi.order_id = o.order_id) AS joined_rows;

-- 5) 결제(payments) 결합 시 order_id 기준 1:N 여부(분할결제) 확인
-- SELECT n_payments_per_order, COUNT(*) AS n_orders
-- FROM (SELECT order_id, COUNT(*) AS n_payments_per_order FROM order_payments GROUP BY order_id) t
-- GROUP BY n_payments_per_order
-- ORDER BY n_payments_per_order;

-- 6) 리뷰(reviews) 결합 시 미매칭(리뷰 없는 주문) 비율
-- SELECT
--     COUNT(*) AS n_orders,
--     SUM(CASE WHEN r.order_id IS NULL THEN 1 ELSE 0 END) AS n_orders_without_review
-- FROM orders o
-- LEFT JOIN order_reviews r ON r.order_id = o.order_id;
