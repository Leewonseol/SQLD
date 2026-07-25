-- 03-기법별적용 전체가 공유하는 파생 테이블 준비.
-- 이 DB(../01-기본탐색/olist.db)의 customers_raw(원본 그대로) 위에서만 파생시킨다.
-- 파생 근거: 00-데이터사전/README.md §3 (customer_unique_id 반복 = Olist 설계상 재구매 신호)

-- 사람(customer_unique_id) 단위 대표 지역: 같은 사람이라도 주문마다 city/state가
-- 다를 수 있다(96,096명 중 39명은 state가 다른 경우 존재). 대표값은 가장 이른(=사전순 최소)
-- customer_id 행의 state/city로 결정적으로 고정한다.
DROP TABLE IF EXISTS customer_repeat_features;
CREATE TABLE customer_repeat_features AS
WITH first_row AS (
    SELECT customer_unique_id, customer_state, customer_city,
           ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY customer_id) AS rn
    FROM customers_raw
),
counts AS (
    SELECT customer_unique_id, COUNT(*) AS n_orders
    FROM customers_raw
    GROUP BY customer_unique_id
)
SELECT
    c.customer_unique_id,
    c.n_orders,
    CASE WHEN c.n_orders > 1 THEN 1 ELSE 0 END AS is_repeat_customer,
    f.customer_state AS state,
    f.customer_city AS city
FROM counts c
JOIN first_row f ON f.customer_unique_id = c.customer_unique_id AND f.rn = 1;

-- 검산: 원본 고유고객 수와 일치해야 함
SELECT COUNT(*) AS n_rows FROM customer_repeat_features;
SELECT is_repeat_customer, COUNT(*) AS n, ROUND(AVG(n_orders), 3) AS avg_n_orders
FROM customer_repeat_features
GROUP BY is_repeat_customer;
