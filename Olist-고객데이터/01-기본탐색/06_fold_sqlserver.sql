-- Olist 고객 데이터 학습/검증 fold 식별자 생성 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요
-- SQL Server는 Oracle의 "CREATE TABLE ... AS SELECT"에 대응하는 문법이
-- "SELECT ... INTO 새테이블 FROM ..."이다 - 키워드 위치 자체가 다르다.

IF OBJECT_ID('customer_fold', 'U') IS NOT NULL DROP TABLE customer_fold;

WITH ranked AS (
    SELECT DISTINCT customer_unique_id,
           ROW_NUMBER() OVER (ORDER BY customer_unique_id) AS rn
    FROM customers_raw
)
SELECT customer_unique_id, (rn % 5) + 1 AS fold
INTO customer_fold
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
) t;
