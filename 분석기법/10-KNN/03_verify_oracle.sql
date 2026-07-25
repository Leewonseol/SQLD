-- KNN 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE knn_k_comparison (k NUMBER, accuracy NUMBER);
CREATE TABLE knn_predictions (customer_id VARCHAR2(32), actual NUMBER, predicted NUMBER, best_k NUMBER);

SELECT k, ROUND(accuracy, 4) AS accuracy FROM knn_k_comparison ORDER BY k;

SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN,
    MAX(best_k) AS best_k
FROM knn_predictions;

SELECT (SELECT MAX(accuracy) FROM knn_k_comparison) - (SELECT MIN(accuracy) FROM knn_k_comparison) AS accuracy_range
FROM DUAL;
