-- K-means 입력 준비 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

DROP TABLE kmeans_input;
CREATE TABLE kmeans_input AS
SELECT
    customer_id,
    (age                   - AVG(age) OVER())                   / STDDEV_POP(age) OVER()                   AS age_z,
    (annual_income_10k     - AVG(annual_income_10k) OVER())      / STDDEV_POP(annual_income_10k) OVER()      AS income_z,
    (membership_years      - AVG(membership_years) OVER())       / STDDEV_POP(membership_years) OVER()       AS membership_z,
    (order_count           - AVG(order_count) OVER())            / STDDEV_POP(order_count) OVER()            AS orders_z,
    (avg_order_value       - AVG(avg_order_value) OVER())        / STDDEV_POP(avg_order_value) OVER()        AS aov_z,
    (days_since_last_order - AVG(days_since_last_order) OVER())  / STDDEV_POP(days_since_last_order) OVER()  AS recency_z,
    (satisfaction_score    - AVG(satisfaction_score) OVER())     / STDDEV_POP(satisfaction_score) OVER()     AS satisfaction_z
FROM customer_features;

SELECT COUNT(*) AS n FROM kmeans_input;
