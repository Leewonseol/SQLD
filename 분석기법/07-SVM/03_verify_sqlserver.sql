-- SVM 결과 검산 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE svm_metrics (n_support_vectors INT, n_support_class0 INT, n_support_class1 INT,
                           n_train INT, n_test INT, accuracy FLOAT);
CREATE TABLE svm_predictions (customer_id VARCHAR(32), actual INT, predicted INT, decision_score FLOAT);

SELECT * FROM svm_metrics;

SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM svm_predictions;

SELECT TOP 5 customer_id, actual, predicted, ROUND(decision_score, 3) AS decision_score
FROM svm_predictions
WHERE actual = 1 AND predicted = 0
ORDER BY decision_score ASC;

-- actual/predicted가 INT이므로 1.0*로 정수 나눗셈 방지
SELECT actual, COUNT(*) AS n,
       ROUND(1.0 * SUM(CASE WHEN actual = predicted THEN 1 ELSE 0 END) / COUNT(*), 4) AS class_accuracy
FROM svm_predictions
GROUP BY actual;
