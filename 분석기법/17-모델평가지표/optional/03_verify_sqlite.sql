-- 모델평가지표 결과 검산

-- 1) 임계값 0.5에서 SQL로 정밀도·재현율·F1을 직접 계산해 Python 결과와 대조
SELECT
    threshold,
    TP, FP, TN, FN,
    ROUND(1.0 * TP / NULLIF(TP+FP, 0), 4) AS precision_from_sql,
    ROUND(1.0 * TP / NULLIF(TP+FN, 0), 4) AS recall_from_sql,
    ROUND(2.0 * TP / NULLIF(2*TP+FP+FN, 0), 4) AS f1_from_sql
FROM eval_threshold_sweep
WHERE threshold = 0.5;

-- 2) Python이 계산한 분류 지표 (위 SQL 값과 비교)
SELECT * FROM classification_metrics_detail;

-- 3) 임계값이 올라갈수록 정밀도는 대체로 오르고 재현율은 내려가는지 확인 (트레이드오프)
SELECT
    threshold,
    ROUND(1.0 * TP / NULLIF(TP+FP, 0), 4) AS precision,
    ROUND(1.0 * TP / NULLIF(TP+FN, 0), 4) AS recall
FROM eval_threshold_sweep
ORDER BY threshold;

-- 4) 회귀 지표 (05-회귀분석에서 SQL로 재계산한 R²와 동일해야 함)
SELECT * FROM regression_metrics_detail;
