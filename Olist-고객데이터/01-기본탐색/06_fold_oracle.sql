-- Olist 고객 데이터 학습/검증 fold 식별자 생성 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요
-- customer_unique_id 기준으로 fold를 매겨야 동일인의 여러 customer_id가 서로 다른
-- fold로 흩어지는 leakage를 막을 수 있다(Olist 스키마 설계: customer_unique_id=사람).

CREATE TABLE customer_fold AS
WITH ranked AS (
    SELECT DISTINCT customer_unique_id,
           ROW_NUMBER() OVER (ORDER BY customer_unique_id) AS rn
    FROM customers_raw
)
SELECT customer_unique_id, MOD(rn, 5) + 1 AS fold
FROM ranked;

-- fold별 고유고객 수(균등해야 함)
SELECT fold, COUNT(*) AS n_unique_customers
FROM customer_fold
GROUP BY fold
ORDER BY fold;

-- leakage 검증: 동일 customer_unique_id의 모든 customer_id가 같은 fold에 속하는지
SELECT COUNT(*) AS n_customers_with_split_fold
FROM (
    SELECT c.customer_unique_id
    FROM customers_raw c
    JOIN customer_fold f ON f.customer_unique_id = c.customer_unique_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT f.fold) > 1
);
