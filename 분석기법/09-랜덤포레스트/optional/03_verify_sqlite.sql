-- 랜덤포레스트 결과 검산

-- 1) 변수중요도 순위
SELECT feature, ROUND(importance, 4) AS importance
FROM rf_feature_importance
ORDER BY importance DESC;

-- 2) OOB 점수 vs 테스트셋 정확도 (비슷해야 모델이 안정적으로 일반화됨)
SELECT * FROM rf_metrics;

-- 3) 혼동행렬
SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM rf_predictions;

-- 4) 랜덤포레스트와 의사결정나무의 변수중요도 1위가 같은지 비교 (앙상블이 단일 트리와 같은 신호를 보는지)
SELECT 'decision_tree' AS model, feature, importance FROM tree_feature_importance ORDER BY importance DESC LIMIT 1;
