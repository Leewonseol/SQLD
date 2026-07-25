-- 기본 탐색 (1): 행수/유일성/분포/반복/결측 — 전부 customers_raw 원본 열만 사용

-- [1] 전체 행 수와 고유 고객 수
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_id,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_id
FROM customers_raw;

-- [2] customer_id와 customer_unique_id의 중복 구조
--     customer_id는 행마다 유일(이 파일의 PK), customer_unique_id는 사람 단위라 반복될 수 있다.
SELECT
    n_customer_id_per_unique AS repeat_count,
    COUNT(*) AS n_unique_customers
FROM (
    SELECT customer_unique_id, COUNT(*) AS n_customer_id_per_unique
    FROM customers_raw
    GROUP BY customer_unique_id
) t
GROUP BY n_customer_id_per_unique
ORDER BY n_customer_id_per_unique;

-- [3] 도시·주별 고객 수 (상위 10개 주)
SELECT customer_state, COUNT(*) AS n_customers
FROM customers_raw
GROUP BY customer_state
ORDER BY n_customers DESC
LIMIT 10;

SELECT customer_city, customer_state, COUNT(*) AS n_customers
FROM customers_raw
GROUP BY customer_city, customer_state
ORDER BY n_customers DESC
LIMIT 10;

-- [4] 도시·주별 고객 비율
SELECT
    customer_state,
    COUNT(*) AS n_customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customers_raw), 2) AS pct_of_total
FROM customers_raw
GROUP BY customer_state
ORDER BY n_customers DESC
LIMIT 10;

-- [5] 동일 고객(customer_unique_id)의 반복 등장 여부 -> is_repeat_customer 플래그 확인
SELECT
    CASE WHEN n_orders > 1 THEN 'repeat' ELSE 'single' END AS customer_type,
    COUNT(*) AS n_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM (
    SELECT customer_unique_id, COUNT(*) AS n_orders
    FROM customers_raw
    GROUP BY customer_unique_id
) t
GROUP BY customer_type;

-- [6] 빈 문자열과 NULL 탐색 (5개 열 전체)
SELECT
    SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END) AS bad_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL OR TRIM(customer_unique_id) = '' THEN 1 ELSE 0 END) AS bad_customer_unique_id,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL OR TRIM(customer_zip_code_prefix) = '' THEN 1 ELSE 0 END) AS bad_zip,
    SUM(CASE WHEN customer_city IS NULL OR TRIM(customer_city) = '' THEN 1 ELSE 0 END) AS bad_city,
    SUM(CASE WHEN customer_state IS NULL OR TRIM(customer_state) = '' THEN 1 ELSE 0 END) AS bad_state
FROM customers_raw;
