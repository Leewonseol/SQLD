-- 로지스틱회귀 입력 준비 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요

DROP TABLE logistic_input;
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

-- 기저 이탈률: Oracle NUMBER는 캐스팅 없이 나눠도 소수부가 보존된다
SELECT
    SUM(churned) AS n_churned,
    COUNT(*) AS n_total,
    ROUND(SUM(churned) / COUNT(*), 4) AS churn_rate
FROM logistic_input;
