-- K-means 결과 검산

-- 1) 엘보우 곡선 (k가 커질수록 inertia는 항상 감소 - 감소 폭이 완만해지는 지점을 찾는다)
SELECT k, ROUND(inertia, 1) AS inertia
FROM kmeans_elbow
ORDER BY k;

-- 2) 군집별 고객 수·중심(원 척도) 및 주요 특성 분포
SELECT
    a.cluster,
    COUNT(*) AS n_customers,
    ROUND(AVG(f.annual_income_10k), 1)     AS avg_income,
    ROUND(AVG(f.avg_order_value), 1)       AS avg_aov,
    ROUND(AVG(f.membership_years), 2)      AS avg_membership,
    ROUND(AVG(f.satisfaction_score), 2)    AS avg_satisfaction,
    ROUND(AVG(f.days_since_last_order), 1) AS avg_recency
FROM kmeans_assignments a
JOIN customer_features f ON f.customer_id = a.customer_id
GROUP BY a.cluster
ORDER BY a.cluster;

-- 3) 표준화 공간에서의 군집 중심 (어떤 축이 군집을 가르는지 확인)
SELECT * FROM kmeans_centers_z ORDER BY cluster;

-- 4) 군집별 이탈률(churned) - K-means는 비지도학습이지만, 지도학습 타깃과 비교해 군집의 의미를 해석
SELECT a.cluster, ROUND(AVG(l.churned), 4) AS churn_rate
FROM kmeans_assignments a
JOIN customer_labels l ON l.customer_id = a.customer_id
GROUP BY a.cluster
ORDER BY a.cluster;
