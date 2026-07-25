-- 회귀분석 결과 검산 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE regression_coefficients (
    variable VARCHAR(30), coef FLOAT, std_err FLOAT, t_value FLOAT, p_value FLOAT
);
CREATE TABLE regression_predictions (
    customer_id VARCHAR(32), actual FLOAT, predicted FLOAT, residual FLOAT
);
CREATE TABLE regression_metrics (
    r_squared FLOAT, adj_r_squared FLOAT, rmse FLOAT, mae FLOAT, n INT
);

-- 1) 유의한 변수만 (p < 0.05)
SELECT variable, ROUND(coef, 4) AS coef, ROUND(std_err, 4) AS std_err,
       ROUND(t_value, 3) AS t_value, ROUND(p_value, 5) AS p_value
FROM regression_coefficients
WHERE p_value < 0.05
ORDER BY ABS(t_value) DESC;

-- 2) R^2를 SQL로 직접 재계산해 Python 결과와 대조
-- (residual/actual은 FLOAT 컬럼이라 정수 나눗셈 문제는 없지만, 습관적으로 실수 리터럴 사용)
SELECT
    ROUND(1.0 - SUM(residual*residual) / (
        SELECT SUM(POWER(actual - avg_actual, 2))
        FROM regression_predictions, (SELECT AVG(actual) AS avg_actual FROM regression_predictions) a
    ), 4) AS r_squared_from_sql,
    (SELECT ROUND(r_squared, 4) FROM regression_metrics) AS r_squared_from_python
FROM regression_predictions;

-- 3) 잔차 절대값 상위 5건
SELECT TOP 5 customer_id, ROUND(actual, 1) AS actual, ROUND(predicted, 1) AS predicted, ROUND(residual, 1) AS residual
FROM regression_predictions
ORDER BY ABS(residual) DESC;

-- 4) 전체 성능 지표
SELECT * FROM regression_metrics;
