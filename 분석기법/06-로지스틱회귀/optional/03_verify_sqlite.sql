-- 로지스틱회귀 결과 검산

-- 1) SQL EXP()로 오즈비를 직접 재계산해 Python 결과와 대조
SELECT variable, ROUND(coef, 4) AS coef,
       ROUND(EXP(coef), 4) AS odds_ratio_from_sql,
       ROUND(odds_ratio, 4) AS odds_ratio_from_python,
       ROUND(p_value, 5) AS p_value
FROM logistic_coefficients
ORDER BY variable;

-- 2) 혼동행렬 (임계값 0.5 기준)
SELECT
    SUM(CASE WHEN actual = 1 AND predicted_class = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted_class = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted_class = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted_class = 0 THEN 1 ELSE 0 END) AS FN
FROM logistic_predictions;

-- 3) 정확도 SQL로 직접 계산
SELECT ROUND(1.0 * SUM(CASE WHEN actual = predicted_class THEN 1 ELSE 0 END) / COUNT(*), 4) AS accuracy
FROM logistic_predictions;

-- 4) 예측확률 구간별 실제 이탈률 (calibration 확인: 확률 구간이 올라갈수록 실제 이탈률도 올라가야 함)
SELECT
    CASE
        WHEN predicted_prob < 0.1 THEN '0.0-0.1'
        WHEN predicted_prob < 0.3 THEN '0.1-0.3'
        WHEN predicted_prob < 0.5 THEN '0.3-0.5'
        ELSE '0.5+'
    END AS prob_bucket,
    COUNT(*) AS n,
    ROUND(AVG(actual), 4) AS actual_churn_rate
FROM logistic_predictions
GROUP BY prob_bucket
ORDER BY prob_bucket;
