-- 모델평가지표 입력 준비 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- (06-로지스틱회귀/03_verify_oracle.sql의 logistic_predictions가 먼저 있어야 한다)

DROP TABLE eval_threshold_sweep;
CREATE TABLE eval_threshold_sweep AS
SELECT
    t.threshold,
    SUM(CASE WHEN lp.actual = 1 AND lp.predicted_prob >= t.threshold THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN lp.actual = 0 AND lp.predicted_prob >= t.threshold THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN lp.actual = 0 AND lp.predicted_prob <  t.threshold THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN lp.actual = 1 AND lp.predicted_prob <  t.threshold THEN 1 ELSE 0 END) AS FN
FROM logistic_predictions lp
CROSS JOIN (
    SELECT 0.1 AS threshold FROM DUAL UNION ALL SELECT 0.2 FROM DUAL UNION ALL SELECT 0.3 FROM DUAL UNION ALL
    SELECT 0.4 FROM DUAL UNION ALL SELECT 0.5 FROM DUAL UNION ALL SELECT 0.6 FROM DUAL UNION ALL
    SELECT 0.7 FROM DUAL UNION ALL SELECT 0.8 FROM DUAL UNION ALL SELECT 0.9 FROM DUAL
) t
GROUP BY t.threshold;

SELECT * FROM eval_threshold_sweep ORDER BY threshold;
