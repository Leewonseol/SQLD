-- 의사결정나무 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE tree_feature_importance (feature VARCHAR2(30), importance NUMBER);
CREATE TABLE tree_metrics (max_depth NUMBER, n_leaves NUMBER, accuracy NUMBER);
CREATE TABLE tree_predictions (customer_id VARCHAR2(32), actual NUMBER, predicted NUMBER);

SELECT feature, ROUND(importance, 4) AS importance FROM tree_feature_importance ORDER BY importance DESC;

SELECT * FROM tree_metrics;

SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM tree_predictions;

SELECT recency_bucket, COUNT(*) AS n, ROUND(AVG(churned), 4) AS churn_rate
FROM tree_input
GROUP BY recency_bucket
ORDER BY MIN(days_since_last_order);
