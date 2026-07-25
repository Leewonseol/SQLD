-- PCA 입력 데이터 준비
-- customer_features의 7개 수치형 변수를 표준화(평균 0, 표준편차 1)한다.
-- SQLite에는 STDDEV 내장함수가 없으므로 Var(x) = E[x^2] - E[x]^2 공식을 직접 사용한다.
-- (Oracle: STDDEV(x) OVER(), SQL Server: STDEV(x) 로 대체 가능)

DROP TABLE IF EXISTS pca_input;

CREATE TABLE pca_input AS
SELECT
    f.customer_id,
    (f.age                   - s.m_age)          / s.sd_age           AS age_z,
    (f.annual_income_10k     - s.m_income)        / s.sd_income        AS income_z,
    (f.membership_years      - s.m_member)        / s.sd_member        AS membership_z,
    (f.order_count           - s.m_orders)        / s.sd_orders        AS orders_z,
    (f.avg_order_value       - s.m_aov)           / s.sd_aov           AS aov_z,
    (f.days_since_last_order - s.m_recency)       / s.sd_recency       AS recency_z,
    (f.satisfaction_score    - s.m_satis)         / s.sd_satis         AS satisfaction_z
FROM customer_features f
CROSS JOIN (
    SELECT
        AVG(age)                    AS m_age,
        SQRT(AVG(age*age) - AVG(age)*AVG(age))                                   AS sd_age,
        AVG(annual_income_10k)      AS m_income,
        SQRT(AVG(annual_income_10k*annual_income_10k) - AVG(annual_income_10k)*AVG(annual_income_10k)) AS sd_income,
        AVG(membership_years)       AS m_member,
        SQRT(AVG(membership_years*membership_years) - AVG(membership_years)*AVG(membership_years))     AS sd_member,
        AVG(order_count)            AS m_orders,
        SQRT(AVG(order_count*order_count) - AVG(order_count)*AVG(order_count))                         AS sd_orders,
        AVG(avg_order_value)        AS m_aov,
        SQRT(AVG(avg_order_value*avg_order_value) - AVG(avg_order_value)*AVG(avg_order_value))         AS sd_aov,
        AVG(days_since_last_order)  AS m_recency,
        SQRT(AVG(days_since_last_order*days_since_last_order) - AVG(days_since_last_order)*AVG(days_since_last_order)) AS sd_recency,
        AVG(satisfaction_score)     AS m_satis,
        SQRT(AVG(satisfaction_score*satisfaction_score) - AVG(satisfaction_score)*AVG(satisfaction_score))             AS sd_satis
    FROM customer_features
) s;

-- 표준화 검산: 각 컬럼의 평균은 0에 가깝고, 분산은 1에 가까워야 한다.
SELECT
    ROUND(AVG(age_z), 4)         AS mean_age_z,
    ROUND(AVG(age_z*age_z), 4)   AS var_age_z,
    COUNT(*)                     AS n
FROM pca_input;
