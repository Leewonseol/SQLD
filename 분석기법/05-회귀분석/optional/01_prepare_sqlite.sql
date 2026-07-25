-- 회귀분석 입력 준비: 분석 테이블 + 더미변수 + 요약통계

DROP TABLE IF EXISTS regression_input;
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
    CASE WHEN f.membership_years >= 5 THEN 1 ELSE 0 END AS tier_premium,   -- 기준범주: 신규(<2년)
    CASE WHEN f.membership_years >= 2 AND f.membership_years < 5 THEN 1 ELSE 0 END AS tier_general
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

-- 더미변수 분포 확인 (기준범주 = 신규: tier_premium=0, tier_general=0)
SELECT
    SUM(CASE WHEN tier_premium = 0 AND tier_general = 0 THEN 1 ELSE 0 END) AS n_신규,
    SUM(tier_general) AS n_일반,
    SUM(tier_premium) AS n_우수
FROM regression_input;

-- 변수별 요약통계 (평균/표준편차/최소/최대) - UNION ALL로 세로로 쌓아 한 번에 조회
DROP TABLE IF EXISTS regression_summary_stats;
CREATE TABLE regression_summary_stats AS
SELECT 'next_month_spend' AS variable, AVG(next_month_spend) AS mean,
       SQRT(AVG(next_month_spend*next_month_spend)-AVG(next_month_spend)*AVG(next_month_spend)) AS stddev,
       MIN(next_month_spend) AS min_value, MAX(next_month_spend) AS max_value
FROM regression_input
UNION ALL
SELECT 'avg_order_value', AVG(avg_order_value),
       SQRT(AVG(avg_order_value*avg_order_value)-AVG(avg_order_value)*AVG(avg_order_value)),
       MIN(avg_order_value), MAX(avg_order_value)
FROM regression_input
UNION ALL
SELECT 'order_count', AVG(order_count),
       SQRT(AVG(order_count*order_count)-AVG(order_count)*AVG(order_count)),
       MIN(order_count), MAX(order_count)
FROM regression_input
UNION ALL
SELECT 'membership_years', AVG(membership_years),
       SQRT(AVG(membership_years*membership_years)-AVG(membership_years)*AVG(membership_years)),
       MIN(membership_years), MAX(membership_years)
FROM regression_input
UNION ALL
SELECT 'annual_income_10k', AVG(annual_income_10k),
       SQRT(AVG(annual_income_10k*annual_income_10k)-AVG(annual_income_10k)*AVG(annual_income_10k)),
       MIN(annual_income_10k), MAX(annual_income_10k)
FROM regression_input;

SELECT * FROM regression_summary_stats;
