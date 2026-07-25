-- K-means 입력 준비 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

IF OBJECT_ID('kmeans_input', 'U') IS NOT NULL DROP TABLE kmeans_input;
SELECT
    customer_id,
    (age                   - AVG(age) OVER())                   / STDEVP(age) OVER()                   AS age_z,
    (annual_income_10k     - AVG(annual_income_10k) OVER())      / STDEVP(annual_income_10k) OVER()      AS income_z,
    (membership_years      - AVG(membership_years) OVER())       / STDEVP(membership_years) OVER()       AS membership_z,
    (order_count           - AVG(order_count) OVER())            / STDEVP(order_count) OVER()            AS orders_z,
    (avg_order_value       - AVG(avg_order_value) OVER())        / STDEVP(avg_order_value) OVER()        AS aov_z,
    (days_since_last_order - AVG(days_since_last_order) OVER())  / STDEVP(days_since_last_order) OVER()  AS recency_z,
    (satisfaction_score    - AVG(satisfaction_score) OVER())     / STDEVP(satisfaction_score) OVER()     AS satisfaction_z
INTO kmeans_input
FROM customer_features;

SELECT COUNT(*) AS n FROM kmeans_input;
