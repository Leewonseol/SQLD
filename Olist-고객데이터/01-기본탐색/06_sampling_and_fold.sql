-- 기본 탐색 (5): 지역별 표본 추출 / 학습·검증 fold 생성

-- [15] 지역별(state) 층화표본: 각 주에서 최대 3명씩 결정적으로 추출 (ROWID 기준 정렬 후 상위 n개)
DROP TABLE IF EXISTS state_stratified_sample;
CREATE TABLE state_stratified_sample AS
SELECT customer_id, customer_unique_id, customer_state, rn
FROM (
    SELECT
        customer_id, customer_unique_id, customer_state,
        ROW_NUMBER() OVER (PARTITION BY customer_state ORDER BY customer_id) AS rn
    FROM customers_raw
) t
WHERE rn <= 3;

SELECT customer_state, COUNT(*) AS n_sampled
FROM state_stratified_sample
GROUP BY customer_state
ORDER BY customer_state
LIMIT 10;

-- [16] 학습/검증 fold 생성: customer_unique_id 기준으로 5-fold 배정
--     주의: customer_id가 아니라 customer_unique_id 기준으로 fold를 나눠야 한다.
--     동일인의 여러 customer_id가 서로 다른 fold에 흩어지면 향후 예측 실습에서
--     같은 사람의 정보가 학습/검증 양쪽에 leakage 될 수 있기 때문이다.
DROP TABLE IF EXISTS customer_fold;
CREATE TABLE customer_fold AS
WITH unique_customers AS (
    SELECT DISTINCT customer_unique_id
    FROM customers_raw
),
ranked AS (
    SELECT
        customer_unique_id,
        ROW_NUMBER() OVER (ORDER BY customer_unique_id) AS rn
    FROM unique_customers
)
SELECT
    customer_unique_id,
    (rn % 5) + 1 AS fold
FROM ranked;

-- fold별 고유고객 수 (거의 균등해야 함)
SELECT fold, COUNT(*) AS n_unique_customers
FROM customer_fold
GROUP BY fold
ORDER BY fold;

-- 동일 customer_unique_id의 모든 customer_id 행이 같은 fold로 들어가는지 검증
-- (customers_raw와 fold를 조인했을 때 customer_unique_id별 fold가 항상 1개여야 함)
SELECT COUNT(*) AS n_customers_with_split_fold
FROM (
    SELECT c.customer_unique_id
    FROM customers_raw c
    JOIN customer_fold f ON f.customer_unique_id = c.customer_unique_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT f.fold) > 1
);
