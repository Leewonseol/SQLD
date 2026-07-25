-- KNN 결과 검산

-- 1) k별 정확도 비교 (편향-분산 트레이드오프 곡선)
SELECT k, ROUND(accuracy, 4) AS accuracy
FROM knn_k_comparison
ORDER BY k;

-- 2) 최적 k에서의 혼동행렬
SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN,
    MAX(best_k) AS best_k
FROM knn_predictions;

-- 3) 최고/최저 정확도 k의 차이 (k 선택이 성능에 미치는 영향 크기)
SELECT
    (SELECT MAX(accuracy) FROM knn_k_comparison) - (SELECT MIN(accuracy) FROM knn_k_comparison) AS accuracy_range;
