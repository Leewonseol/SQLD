-- 모델평가지표 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE classification_metrics_detail (metric VARCHAR2(20), value NUMBER);
CREATE TABLE regression_metrics_detail (metric VARCHAR2(20), value NUMBER);

SELECT
    threshold, TP, FP, TN, FN,
    ROUND(TP / NULLIF(TP+FP, 0), 4) AS precision_from_sql,
    ROUND(TP / NULLIF(TP+FN, 0), 4) AS recall_from_sql,
    ROUND(2 * TP / NULLIF(2*TP+FP+FN, 0), 4) AS f1_from_sql
FROM eval_threshold_sweep
WHERE threshold = 0.5;

SELECT * FROM classification_metrics_detail;

SELECT
    threshold,
    ROUND(TP / NULLIF(TP+FP, 0), 4) AS precision,
    ROUND(TP / NULLIF(TP+FN, 0), 4) AS recall
FROM eval_threshold_sweep
ORDER BY threshold;

SELECT * FROM regression_metrics_detail;
