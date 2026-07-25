-- 의사결정나무 결과 검산

-- 1) 변수중요도 순위
SELECT feature, ROUND(importance, 4) AS importance
FROM tree_feature_importance
ORDER BY importance DESC;

-- 2) 트리 성능 요약
SELECT * FROM tree_metrics;

-- 3) 혼동행렬
SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM tree_predictions;

-- 4) 가장 중요한 변수(1순위)가 실제로 recency였는지, 01_prepare.sql의 탐색 결과와 논리적으로 일치하는지 확인
--    (recency_bucket별 이탈률이 계단식으로 증가했다면 트리도 days_since_last_order를 최상위로 선택할 가능성이 높음)
SELECT recency_bucket, COUNT(*) AS n, ROUND(AVG(churned), 4) AS churn_rate
FROM tree_input
GROUP BY recency_bucket
ORDER BY MIN(days_since_last_order);
