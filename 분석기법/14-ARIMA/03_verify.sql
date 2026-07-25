-- ARIMA 결과 검산

-- 1) 모형 비교: AIC가 가장 작은 모형 확인
SELECT model, model_order, ROUND(aic, 2) AS aic, ROUND(in_sample_rmse, 3) AS in_sample_rmse
FROM arima_model_comparison
ORDER BY aic;

-- 2) 최종 모형(ARIMA(1,1,1)) 6개월 예측 및 신뢰구간
SELECT month_id, ROUND(forecast, 1) AS forecast,
       ROUND(ci_lower, 1) AS ci_lower, ROUND(ci_upper, 1) AS ci_upper
FROM arima_forecast
ORDER BY month_id;

-- 3) 잔차 평균 (0에 가까워야 편향 없는 모형)
SELECT ROUND(AVG(residual), 3) AS mean_residual, ROUND(SQRT(AVG(residual*residual)), 3) AS rmse
FROM arima_residuals;

-- 4) 잔차의 1차 자기상관 (백색잡음이면 0에 가까워야 함) - corr(e_t, e_{t-1})
WITH r AS (
    SELECT month_id, residual,
           LAG(residual, 1) OVER (ORDER BY month_id) AS residual_lag1
    FROM arima_residuals
)
SELECT
    (AVG(residual*residual_lag1) - AVG(residual)*AVG(residual_lag1))
    / (
        SQRT(AVG(residual*residual) - AVG(residual)*AVG(residual))
        * SQRT(AVG(residual_lag1*residual_lag1) - AVG(residual_lag1)*AVG(residual_lag1))
      ) AS residual_autocorr_lag1
FROM r
WHERE residual_lag1 IS NOT NULL;
