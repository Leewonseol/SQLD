-- 로지스틱회귀 결과 검산 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE logistic_coefficients (
    variable VARCHAR2(30), coef NUMBER, odds_ratio NUMBER, std_err NUMBER, z_value NUMBER, p_value NUMBER
);
CREATE TABLE logistic_predictions (
    customer_id VARCHAR2(32), actual NUMBER, predicted_prob NUMBER, predicted_class NUMBER
);

-- 1) SQL EXP()로 오즈비 재계산해 Python 결과와 대조
SELECT variable, ROUND(coef, 4) AS coef,
       ROUND(EXP(coef), 4) AS odds_ratio_from_sql,
       ROUND(odds_ratio, 4) AS odds_ratio_from_python,
       ROUND(p_value, 5) AS p_value
FROM logistic_coefficients
ORDER BY variable;

-- 2) 혼동행렬
SELECT
    SUM(CASE WHEN actual = 1 AND predicted_class = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN actual = 0 AND predicted_class = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN actual = 0 AND predicted_class = 0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN actual = 1 AND predicted_class = 0 THEN 1 ELSE 0 END) AS FN
FROM logistic_predictions;

-- 3) 정확도 (Oracle NUMBER는 캐스팅 없이도 정확)
SELECT ROUND(SUM(CASE WHEN actual = predicted_class THEN 1 ELSE 0 END) / COUNT(*), 4) AS accuracy
FROM logistic_predictions;

-- 4) 예측확률 구간별 실제 이탈률(calibration)
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
GROUP BY CASE
        WHEN predicted_prob < 0.1 THEN '0.0-0.1'
        WHEN predicted_prob < 0.3 THEN '0.1-0.3'
        WHEN predicted_prob < 0.5 THEN '0.3-0.5'
        ELSE '0.5+'
    END
ORDER BY prob_bucket;
