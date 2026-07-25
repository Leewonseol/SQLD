-- KNN 입력 준비 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

IF OBJECT_ID('knn_input', 'U') IS NOT NULL DROP TABLE knn_input;
SELECT
    customer_id, churned,
    (satisfaction_score    - AVG(satisfaction_score) OVER())    / STDEVP(satisfaction_score) OVER()    AS satisfaction_z,
    (days_since_last_order - AVG(days_since_last_order) OVER()) / STDEVP(days_since_last_order) OVER() AS recency_z,
    (order_count           - AVG(order_count) OVER())           / STDEVP(order_count) OVER()           AS orders_z,
    (membership_years      - AVG(membership_years) OVER())      / STDEVP(membership_years) OVER()      AS membership_z,
    (annual_income_10k     - AVG(annual_income_10k) OVER())     / STDEVP(annual_income_10k) OVER()     AS income_z,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY customer_id) % 5 = 0 THEN 'test' ELSE 'train' END AS split
INTO knn_input
FROM (
    SELECT f.*, l.churned
    FROM customer_features f
    JOIN customer_labels l ON l.customer_id = f.customer_id
) t;

SELECT split, COUNT(*) AS n FROM knn_input GROUP BY split;
