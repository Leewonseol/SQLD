-- 회귀분석 입력 준비: 분석 테이블 + 더미변수 + 요약통계 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
-- customer_features, customer_labels 적재는 01-PCA/01_prepare_oracle.sql과 동일하게
-- SQL*Loader 적재를 가정한다(문법 예시, 이 세션에서 실행하지 않음).

DROP TABLE regression_input;
CREATE TABLE regression_input AS
SELECT
    f.customer_id,
    l.next_month_spend,
    f.avg_order_value,
    f.order_count,
    f.membership_years,
    f.annual_income_10k,
    f.age,
    f.satisfaction_score,
    f.days_since_last_order,
    CASE WHEN f.membership_years >= 5 THEN 1 ELSE 0 END AS tier_premium,
    CASE WHEN f.membership_years >= 2 AND f.membership_years < 5 THEN 1 ELSE 0 END AS tier_general
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

SELECT
    SUM(CASE WHEN tier_premium = 0 AND tier_general = 0 THEN 1 ELSE 0 END) AS n_신규,
    SUM(tier_general) AS n_일반,
    SUM(tier_premium) AS n_우수
FROM regression_input;

-- 변수별 요약통계: Oracle은 STDDEV_POP을 그대로 쓸 수 있어 SQLite처럼 E[x^2]-E[x]^2
-- 공식을 풀어 쓸 필요가 없다.
DROP TABLE regression_summary_stats;
CREATE TABLE regression_summary_stats AS
SELECT 'next_month_spend' AS variable, AVG(next_month_spend) AS mean,
       STDDEV_POP(next_month_spend) AS stddev, MIN(next_month_spend) AS min_value, MAX(next_month_spend) AS max_value
FROM regression_input
UNION ALL
SELECT 'avg_order_value', AVG(avg_order_value), STDDEV_POP(avg_order_value), MIN(avg_order_value), MAX(avg_order_value)
FROM regression_input
UNION ALL
SELECT 'order_count', AVG(order_count), STDDEV_POP(order_count), MIN(order_count), MAX(order_count)
FROM regression_input
UNION ALL
SELECT 'membership_years', AVG(membership_years), STDDEV_POP(membership_years), MIN(membership_years), MAX(membership_years)
FROM regression_input
UNION ALL
SELECT 'annual_income_10k', AVG(annual_income_10k), STDDEV_POP(annual_income_10k), MIN(annual_income_10k), MAX(annual_income_10k)
FROM regression_input;

SELECT * FROM regression_summary_stats;
