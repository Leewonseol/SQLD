-- 회귀분석 결과 검산

-- 1) 유의한 변수만 조회 (p < 0.05)
SELECT variable, ROUND(coef, 4) AS coef, ROUND(std_err, 4) AS std_err,
       ROUND(t_value, 3) AS t_value, ROUND(p_value, 5) AS p_value
FROM regression_coefficients
WHERE p_value < 0.05
ORDER BY ABS(t_value) DESC;

-- 2) Python이 계산한 R²와 SQL로 직접 재계산한 R² 비교(검산)
--    R^2 = 1 - SS_res/SS_tot
WITH stat AS (
    SELECT
        SUM(residual*residual) AS ss_res,
        (SELECT SUM((actual - avg_actual)*(actual - avg_actual))
         FROM regression_predictions, (SELECT AVG(actual) AS avg_actual FROM regression_predictions)) AS ss_tot
    FROM regression_predictions
)
SELECT
    ROUND(1 - ss_res / ss_tot, 4) AS r_squared_from_sql,
    (SELECT ROUND(r_squared, 4) FROM regression_metrics) AS r_squared_from_python
FROM stat;

-- 3) 잔차 절대값 상위 5건 (예측이 가장 많이 빗나간 고객)
SELECT customer_id, ROUND(actual, 1) AS actual, ROUND(predicted, 1) AS predicted,
       ROUND(residual, 1) AS residual
FROM regression_predictions
ORDER BY ABS(residual) DESC
LIMIT 5;

-- 4) 전체 성능 지표
SELECT * FROM regression_metrics;
