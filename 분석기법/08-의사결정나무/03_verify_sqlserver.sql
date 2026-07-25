-- 의사결정나무 결과 검산 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE tree_feature_importance (feature VARCHAR(30), importance FLOAT);
CREATE TABLE tree_metrics (max_depth INT, n_leaves INT, accuracy FLOAT);
CREATE TABLE tree_predictions (customer_id VARCHAR(32), actual INT, predicted INT);

SELECT feature, ROUND(importance, 4) AS importance FROM tree_feature_importance ORDER BY importance DESC;

SELECT * FROM tree_metrics;

SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM tree_predictions;

SELECT recency_bucket, COUNT(*) AS n, ROUND(AVG(1.0 * churned), 4) AS churn_rate
FROM tree_input
GROUP BY recency_bucket
ORDER BY MIN(days_since_last_order);
