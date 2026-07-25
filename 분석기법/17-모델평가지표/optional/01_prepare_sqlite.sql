-- 모델평가지표 입력 준비: 여러 임계값에 대한 혼동행렬을 한 번에 집계
-- (06-로지스틱회귀의 logistic_predictions 테이블이 먼저 생성되어 있어야 한다)

DROP TABLE IF EXISTS eval_threshold_sweep;
CREATE TABLE eval_threshold_sweep AS
SELECT
    t.threshold,
    SUM(CASE WHEN lp.actual = 1 AND lp.predicted_prob >= t.threshold THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN lp.actual = 0 AND lp.predicted_prob >= t.threshold THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN lp.actual = 0 AND lp.predicted_prob <  t.threshold THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN lp.actual = 1 AND lp.predicted_prob <  t.threshold THEN 1 ELSE 0 END) AS FN
FROM logistic_predictions lp
CROSS JOIN (
    SELECT 0.1 AS threshold UNION ALL SELECT 0.2 UNION ALL SELECT 0.3 UNION ALL
    SELECT 0.4 UNION ALL SELECT 0.5 UNION ALL SELECT 0.6 UNION ALL
    SELECT 0.7 UNION ALL SELECT 0.8 UNION ALL SELECT 0.9
) t
GROUP BY t.threshold;

SELECT * FROM eval_threshold_sweep ORDER BY threshold;
