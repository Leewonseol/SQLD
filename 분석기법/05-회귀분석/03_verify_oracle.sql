-- 회귀분석 결과 검산 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요
--
-- 02_analyze.py(statsmodels.OLS) 결과를 저장할 테이블 DDL
CREATE TABLE regression_coefficients (
    variable VARCHAR2(30), coef NUMBER, std_err NUMBER, t_value NUMBER, p_value NUMBER
);
CREATE TABLE regression_predictions (
    customer_id VARCHAR2(32), actual NUMBER, predicted NUMBER, residual NUMBER
);
CREATE TABLE regression_metrics (
    r_squared NUMBER, adj_r_squared NUMBER, rmse NUMBER, mae NUMBER, n NUMBER
);

-- 1) 유의한 변수만 (p < 0.05)
SELECT variable, ROUND(coef, 4) AS coef, ROUND(std_err, 4) AS std_err,
       ROUND(t_value, 3) AS t_value, ROUND(p_value, 5) AS p_value
FROM regression_coefficients
WHERE p_value < 0.05
ORDER BY ABS(t_value) DESC;

-- 2) R^2를 SQL로 직접 재계산해 Python 결과와 대조 (Oracle NUMBER는 나눗셈 캐스팅 불필요)
SELECT
    ROUND(1 - SUM(residual*residual) / (
        SELECT SUM(POWER(actual - avg_actual, 2))
        FROM regression_predictions
        CROSS JOIN (SELECT AVG(actual) AS avg_actual FROM regression_predictions)
    ), 4) AS r_squared_from_sql,
    (SELECT ROUND(r_squared, 4) FROM regression_metrics) AS r_squared_from_python
FROM regression_predictions;

-- 3) 잔차 절대값 상위 5건
SELECT customer_id, ROUND(actual, 1) AS actual, ROUND(predicted, 1) AS predicted, ROUND(residual, 1) AS residual
FROM regression_predictions
ORDER BY ABS(residual) DESC
FETCH FIRST 5 ROWS ONLY;

-- 4) 전체 성능 지표
SELECT * FROM regression_metrics;
