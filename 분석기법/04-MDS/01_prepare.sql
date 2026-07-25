-- MDS 입력 준비: 주(state) 단위 고객 특성 평균 집계 -> 표준화 -> 지역 간 거리행렬

DROP TABLE IF EXISTS region_profile;
CREATE TABLE region_profile AS
SELECT
    c.state,
    COUNT(*) AS n_customers,
    AVG(f.annual_income_10k)    AS avg_income,
    AVG(f.avg_order_value)      AS avg_aov,
    AVG(f.satisfaction_score)   AS avg_satisfaction,
    AVG(f.order_count)          AS avg_orders,
    AVG(f.membership_years)     AS avg_membership
FROM customers c
JOIN customer_features f ON f.customer_id = c.customer_id
GROUP BY c.state
HAVING COUNT(*) >= 5;

-- 지역 프로파일 표준화 (지역 수 기준 평균 0, 분산 1)
DROP TABLE IF EXISTS region_profile_z;
CREATE TABLE region_profile_z AS
SELECT
    r.state,
    (r.avg_income      - t.m1) / t.sd1 AS income_z,
    (r.avg_aov         - t.m2) / t.sd2 AS aov_z,
    (r.avg_satisfaction- t.m3) / t.sd3 AS satis_z,
    (r.avg_orders      - t.m4) / t.sd4 AS orders_z,
    (r.avg_membership  - t.m5) / t.sd5 AS member_z
FROM region_profile r
CROSS JOIN (
    SELECT
        AVG(avg_income) m1, SQRT(AVG(avg_income*avg_income)-AVG(avg_income)*AVG(avg_income)) sd1,
        AVG(avg_aov) m2, SQRT(AVG(avg_aov*avg_aov)-AVG(avg_aov)*AVG(avg_aov)) sd2,
        AVG(avg_satisfaction) m3, SQRT(AVG(avg_satisfaction*avg_satisfaction)-AVG(avg_satisfaction)*AVG(avg_satisfaction)) sd3,
        AVG(avg_orders) m4, SQRT(AVG(avg_orders*avg_orders)-AVG(avg_orders)*AVG(avg_orders)) sd4,
        AVG(avg_membership) m5, SQRT(AVG(avg_membership*avg_membership)-AVG(avg_membership)*AVG(avg_membership)) sd5
    FROM region_profile
) t;

-- 지역 간 유클리드 거리행렬 (자기조인)
DROP TABLE IF EXISTS region_distance;
CREATE TABLE region_distance AS
SELECT
    a.state AS state1,
    b.state AS state2,
    SQRT(
        (a.income_z - b.income_z) * (a.income_z - b.income_z) +
        (a.aov_z    - b.aov_z)    * (a.aov_z    - b.aov_z) +
        (a.satis_z  - b.satis_z)  * (a.satis_z  - b.satis_z) +
        (a.orders_z - b.orders_z) * (a.orders_z - b.orders_z) +
        (a.member_z - b.member_z) * (a.member_z - b.member_z)
    ) AS distance
FROM region_profile_z a
JOIN region_profile_z b ON 1 = 1;

SELECT COUNT(DISTINCT state) AS n_regions FROM region_profile;
