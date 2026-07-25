-- 분류모델 비교 결과 검산

-- 1) 모델별 fold 평균 성능
SELECT model, ROUND(accuracy, 4) AS accuracy, ROUND(precision, 4) AS precision,
       ROUND(recall, 4) AS recall, ROUND(f1, 4) AS f1, ROUND(roc_auc, 4) AS roc_auc
FROM clf_summary
ORDER BY model;

-- 2) fold별 상세 성능 (fold 간 편차 확인)
SELECT model, fold, n_test, ROUND(accuracy, 4) AS accuracy, ROUND(recall, 4) AS recall
FROM clf_fold_results
ORDER BY model, fold;

-- 3) fold=1 예측 결과로 SQL에서 혼동행렬과 정확도를 직접 재계산해 sklearn 결과와 대조
SELECT
    model,
    SUM(CASE WHEN actual=1 AND predicted=1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual=0 AND predicted=1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual=0 AND predicted=0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual=1 AND predicted=0 THEN 1 ELSE 0 END) AS FN,
    ROUND(1.0 * SUM(CASE WHEN actual=predicted THEN 1 ELSE 0 END) / COUNT(*), 4) AS accuracy_from_sql
FROM clf_predictions_fold1
GROUP BY model;
