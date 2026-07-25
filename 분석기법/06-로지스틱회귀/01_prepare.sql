-- 로지스틱회귀 입력 준비

DROP TABLE IF EXISTS logistic_input;
CREATE TABLE logistic_input AS
SELECT
    f.customer_id,
    l.churned,
    f.days_since_last_order,
    f.satisfaction_score,
    f.order_count,
    f.membership_years
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

-- 기저 이탈률(base rate) 확인 - 로지스틱회귀 절편 해석의 출발점
SELECT
    SUM(churned) AS n_churned,
    COUNT(*) AS n_total,
    ROUND(1.0 * SUM(churned) / COUNT(*), 4) AS churn_rate
FROM logistic_input;
