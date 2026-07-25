-- 랜덤포레스트 결과 검산 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE rf_feature_importance (feature VARCHAR(30), importance FLOAT);
CREATE TABLE rf_metrics (n_estimators INT, oob_score FLOAT, test_accuracy FLOAT);
CREATE TABLE rf_predictions (customer_id VARCHAR(32), actual INT, predicted INT);

-- 1) 변수중요도 순위
SELECT feature, ROUND(importance, 4) AS importance
FROM rf_feature_importance
ORDER BY importance DESC;

-- 2) OOB 점수 vs 테스트셋 정확도
SELECT * FROM rf_metrics;

-- 3) 혼동행렬
SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM rf_predictions;

-- 4) 랜덤포레스트와 의사결정나무의 변수중요도 1위 비교
-- (08-의사결정나무/03_verify_sqlserver.sql이 먼저 실행되어 tree_feature_importance가 있어야 함)
SELECT TOP 1 'decision_tree' AS model, feature, importance
FROM tree_feature_importance
ORDER BY importance DESC;
