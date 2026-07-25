-- KNN 결과 검산 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE knn_k_comparison (k INT, accuracy FLOAT);
CREATE TABLE knn_predictions (customer_id VARCHAR(32), actual INT, predicted INT, best_k INT);

SELECT k, ROUND(accuracy, 4) AS accuracy FROM knn_k_comparison ORDER BY k;

SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN,
    MAX(best_k) AS best_k
FROM knn_predictions;

SELECT (SELECT MAX(accuracy) FROM knn_k_comparison) - (SELECT MIN(accuracy) FROM knn_k_comparison) AS accuracy_range;
