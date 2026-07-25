-- SVM 결과 검산

-- 1) 서포트벡터·정확도 요약
SELECT * FROM svm_metrics;

-- 2) 혼동행렬 (테스트셋)
SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM svm_predictions;

-- 3) 오분류 사례: 실제 이탈인데 결정경계에서 가장 멀리 벗어난(가장 자신있게 틀린) 고객
SELECT customer_id, actual, predicted, ROUND(decision_score, 3) AS decision_score
FROM svm_predictions
WHERE actual = 1 AND predicted = 0
ORDER BY decision_score ASC
LIMIT 5;

-- 4) 클래스별 정확도
SELECT actual, COUNT(*) AS n,
       ROUND(1.0 * SUM(CASE WHEN actual = predicted THEN 1 ELSE 0 END) / COUNT(*), 4) AS class_accuracy
FROM svm_predictions
GROUP BY actual;
