-- 기본 탐색 (3): 범주형 변수 인코딩 / 희소 범주 통합

-- [10-a] 레이블 인코딩: state를 고객수 내림차순 순위로 정수 코드화 (DENSE_RANK)
DROP TABLE IF EXISTS state_label_encoding;
CREATE TABLE state_label_encoding AS
SELECT
    customer_state,
    COUNT(*) AS n_customers,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS state_label_code
FROM customers_raw
GROUP BY customer_state;

SELECT * FROM state_label_encoding ORDER BY state_label_code LIMIT 10;

-- [10-b] 원-핫 인코딩: 상위 5개 주만 개별 컬럼, 나머지는 자동으로 전부 0(=암묵적 '기타')
DROP TABLE IF EXISTS customer_state_onehot;
CREATE TABLE customer_state_onehot AS
SELECT
    customer_id,
    customer_state,
    CASE WHEN customer_state = 'SP' THEN 1 ELSE 0 END AS state_SP,
    CASE WHEN customer_state = 'RJ' THEN 1 ELSE 0 END AS state_RJ,
    CASE WHEN customer_state = 'MG' THEN 1 ELSE 0 END AS state_MG,
    CASE WHEN customer_state = 'RS' THEN 1 ELSE 0 END AS state_RS,
    CASE WHEN customer_state = 'PR' THEN 1 ELSE 0 END AS state_PR
FROM customers_raw;

SELECT COUNT(*) AS n, SUM(state_SP) AS n_SP, SUM(state_RJ) AS n_RJ FROM customer_state_onehot;

-- [11] 희소 범주 통합: 고객 수 500명 미만인 주는 '기타'로 묶기
DROP TABLE IF EXISTS state_consolidated;
CREATE TABLE state_consolidated AS
SELECT
    c.customer_id,
    c.customer_state,
    CASE
        WHEN s.n_customers >= 500 THEN c.customer_state
        ELSE '기타'
    END AS state_grouped
FROM customers_raw c
JOIN (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state) s
    ON s.customer_state = c.customer_state;

SELECT state_grouped, COUNT(*) AS n_customers
FROM state_consolidated
GROUP BY state_grouped
ORDER BY n_customers DESC;

-- 통합 전 범주 수 vs 통합 후 범주 수
SELECT
    (SELECT COUNT(DISTINCT customer_state) FROM customers_raw) AS n_categories_before,
    (SELECT COUNT(DISTINCT state_grouped) FROM state_consolidated) AS n_categories_after;
