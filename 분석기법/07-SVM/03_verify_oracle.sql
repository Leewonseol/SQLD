-- SVM 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE svm_metrics (n_support_vectors NUMBER, n_support_class0 NUMBER, n_support_class1 NUMBER,
                           n_train NUMBER, n_test NUMBER, accuracy NUMBER);
CREATE TABLE svm_predictions (customer_id VARCHAR2(32), actual NUMBER, predicted NUMBER, decision_score NUMBER);

SELECT * FROM svm_metrics;

SELECT
    SUM(CASE WHEN actual = 1 AND predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted = 0 THEN 1 ELSE 0 END) AS FN
FROM svm_predictions;

SELECT customer_id, actual, predicted, ROUND(decision_score, 3) AS decision_score
FROM svm_predictions
WHERE actual = 1 AND predicted = 0
ORDER BY decision_score ASC
FETCH FIRST 5 ROWS ONLY;

SELECT actual, COUNT(*) AS n,
       ROUND(SUM(CASE WHEN actual = predicted THEN 1 ELSE 0 END) / COUNT(*), 4) AS class_accuracy
FROM svm_predictions
GROUP BY actual;
