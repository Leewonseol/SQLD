-- K-means 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE kmeans_elbow (k NUMBER, inertia NUMBER);
CREATE TABLE kmeans_assignments (customer_id VARCHAR2(32), cluster NUMBER);
CREATE TABLE kmeans_centers_z (cluster NUMBER, age_z NUMBER, income_z NUMBER, membership_z NUMBER,
                                orders_z NUMBER, aov_z NUMBER, recency_z NUMBER, satisfaction_z NUMBER);

SELECT k, ROUND(inertia, 1) AS inertia FROM kmeans_elbow ORDER BY k;

SELECT
    a.cluster, COUNT(*) AS n_customers,
    ROUND(AVG(f.annual_income_10k), 1)     AS avg_income,
    ROUND(AVG(f.avg_order_value), 1)       AS avg_aov,
    ROUND(AVG(f.membership_years), 2)      AS avg_membership,
    ROUND(AVG(f.satisfaction_score), 2)    AS avg_satisfaction,
    ROUND(AVG(f.days_since_last_order), 1) AS avg_recency
FROM kmeans_assignments a
JOIN customer_features f ON f.customer_id = a.customer_id
GROUP BY a.cluster
ORDER BY a.cluster;

SELECT * FROM kmeans_centers_z ORDER BY cluster;

SELECT a.cluster, ROUND(AVG(l.churned), 4) AS churn_rate
FROM kmeans_assignments a
JOIN customer_labels l ON l.customer_id = a.customer_id
GROUP BY a.cluster
ORDER BY a.cluster;
