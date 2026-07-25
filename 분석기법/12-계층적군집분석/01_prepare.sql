-- 계층적 군집분석 입력 준비: 40명 결정적 표본 + 특성 표준화(전체 1,000명 기준)

DROP TABLE IF EXISTS hier_input;
CREATE TABLE hier_input AS
SELECT
    f.customer_id,
    (f.age                   - s.m_age)     / s.sd_age     AS age_z,
    (f.annual_income_10k     - s.m_income)  / s.sd_income  AS income_z,
    (f.membership_years      - s.m_member)  / s.sd_member  AS membership_z,
    (f.order_count           - s.m_orders)  / s.sd_orders  AS orders_z,
    (f.avg_order_value       - s.m_aov)     / s.sd_aov     AS aov_z,
    (f.days_since_last_order - s.m_recency) / s.sd_recency AS recency_z,
    (f.satisfaction_score    - s.m_satis)   / s.sd_satis   AS satisfaction_z
FROM customer_features f
CROSS JOIN (
    SELECT
        AVG(age) m_age, SQRT(AVG(age*age)-AVG(age)*AVG(age)) sd_age,
        AVG(annual_income_10k) m_income, SQRT(AVG(annual_income_10k*annual_income_10k)-AVG(annual_income_10k)*AVG(annual_income_10k)) sd_income,
        AVG(membership_years) m_member, SQRT(AVG(membership_years*membership_years)-AVG(membership_years)*AVG(membership_years)) sd_member,
        AVG(order_count) m_orders, SQRT(AVG(order_count*order_count)-AVG(order_count)*AVG(order_count)) sd_orders,
        AVG(avg_order_value) m_aov, SQRT(AVG(avg_order_value*avg_order_value)-AVG(avg_order_value)*AVG(avg_order_value)) sd_aov,
        AVG(days_since_last_order) m_recency, SQRT(AVG(days_since_last_order*days_since_last_order)-AVG(days_since_last_order)*AVG(days_since_last_order)) sd_recency,
        AVG(satisfaction_score) m_satis, SQRT(AVG(satisfaction_score*satisfaction_score)-AVG(satisfaction_score)*AVG(satisfaction_score)) sd_satis
    FROM customer_features
) s
WHERE f.ROWID % 25 = 0;

SELECT COUNT(*) AS n_sampled FROM hier_input;
