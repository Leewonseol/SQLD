-- 모델평가지표 입력 준비 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요
-- (06-로지스틱회귀/03_verify_sqlserver.sql의 logistic_predictions가 먼저 있어야 한다)
-- SQL Server는 Oracle과 달리 FROM 없이 리터럴만 SELECT할 수 있다(DUAL 같은 더미
-- 테이블이 필요 없음) - 아래 UNION ALL 상수 목록이 그 예다.

IF OBJECT_ID('eval_threshold_sweep', 'U') IS NOT NULL DROP TABLE eval_threshold_sweep;
SELECT
    t.threshold,
    SUM(CASE WHEN lp.actual = 1 AND lp.predicted_prob >= t.threshold THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN lp.actual = 0 AND lp.predicted_prob >= t.threshold THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN lp.actual = 0 AND lp.predicted_prob <  t.threshold THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN lp.actual = 1 AND lp.predicted_prob <  t.threshold THEN 1 ELSE 0 END) AS FN
INTO eval_threshold_sweep
FROM logistic_predictions lp
CROSS JOIN (
    SELECT 0.1 AS threshold UNION ALL SELECT 0.2 UNION ALL SELECT 0.3 UNION ALL
    SELECT 0.4 UNION ALL SELECT 0.5 UNION ALL SELECT 0.6 UNION ALL
    SELECT 0.7 UNION ALL SELECT 0.8 UNION ALL SELECT 0.9
) t
GROUP BY t.threshold;

SELECT * FROM eval_threshold_sweep ORDER BY threshold;
