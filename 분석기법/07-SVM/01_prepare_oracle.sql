-- SVM 입력 준비 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- 표준화는 파티션 없는 윈도우 함수로(01-PCA와 동일 패턴), 분할은 ROW_NUMBER 기반.

DROP TABLE svm_input;
CREATE TABLE svm_input AS
SELECT
    customer_id, churned,
    (satisfaction_score    - AVG(satisfaction_score) OVER())    / STDDEV_POP(satisfaction_score) OVER()    AS satisfaction_z,
    (days_since_last_order - AVG(days_since_last_order) OVER()) / STDDEV_POP(days_since_last_order) OVER() AS recency_z,
    (order_count           - AVG(order_count) OVER())           / STDDEV_POP(order_count) OVER()           AS orders_z,
    (membership_years      - AVG(membership_years) OVER())      / STDDEV_POP(membership_years) OVER()      AS membership_z,
    (annual_income_10k     - AVG(annual_income_10k) OVER())     / STDDEV_POP(annual_income_10k) OVER()     AS income_z,
    CASE WHEN MOD(ROW_NUMBER() OVER (ORDER BY customer_id), 5) = 0 THEN 'test' ELSE 'train' END AS split
FROM (
    SELECT f.*, l.churned
    FROM customer_features f
    JOIN customer_labels l ON l.customer_id = f.customer_id
);

SELECT split, COUNT(*) AS n, SUM(churned) AS n_churned
FROM svm_input
GROUP BY split;
