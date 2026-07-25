-- 모델평가지표 결과 검산 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요
-- TP/FP/TN/FN은 SUM(CASE WHEN...THEN 1 ELSE 0 END) 결과라 INT다 - 나눗셈마다 1.0*가 필요하다
-- (Oracle 버전은 NUMBER라 필요 없다 - 03_verify_oracle.sql과 비교).

CREATE TABLE classification_metrics_detail (metric VARCHAR(20), value FLOAT);
CREATE TABLE regression_metrics_detail (metric VARCHAR(20), value FLOAT);

SELECT
    threshold, TP, FP, TN, FN,
    ROUND(1.0 * TP / NULLIF(TP+FP, 0), 4) AS precision_from_sql,
    ROUND(1.0 * TP / NULLIF(TP+FN, 0), 4) AS recall_from_sql,
    ROUND(2.0 * TP / NULLIF(2*TP+FP+FN, 0), 4) AS f1_from_sql
FROM eval_threshold_sweep
WHERE threshold = 0.5;

SELECT * FROM classification_metrics_detail;

SELECT
    threshold,
    ROUND(1.0 * TP / NULLIF(TP+FP, 0), 4) AS precision,
    ROUND(1.0 * TP / NULLIF(TP+FN, 0), 4) AS recall
FROM eval_threshold_sweep
ORDER BY threshold;

SELECT * FROM regression_metrics_detail;
