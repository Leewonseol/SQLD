-- 로지스틱회귀 입력 준비 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요

IF OBJECT_ID('logistic_input', 'U') IS NOT NULL DROP TABLE logistic_input;
SELECT
    f.customer_id,
    l.churned,
    f.days_since_last_order,
    f.satisfaction_score,
    f.order_count,
    f.membership_years
INTO logistic_input
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

-- 기저 이탈률: churned/COUNT(*)가 모두 INT이면 정수 나눗셈으로 0이 나온다 -> 1.0* 필수
SELECT
    SUM(churned) AS n_churned,
    COUNT(*) AS n_total,
    ROUND(1.0 * SUM(churned) / COUNT(*), 4) AS churn_rate
FROM logistic_input;
