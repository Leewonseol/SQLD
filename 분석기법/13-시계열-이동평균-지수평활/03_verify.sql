-- 시계열(이동평균·지수평활) 결과 검산

-- 1) SQL 이동평균 vs Python 지수평활 적합값을 나란히 조회 (최근 6개월)
SELECT f.month_id, f.month_date, f.sales,
       ROUND(f.ma3, 1) AS ma3, ROUND(e.ses_fitted, 1) AS ses_fitted, ROUND(e.holt_fitted, 1) AS holt_fitted
FROM ts_features f
JOIN ts_exp_smoothing_fitted e ON e.month_id = f.month_id
ORDER BY f.month_id DESC
LIMIT 6;

-- 2) 이동평균(MA3)의 적합오차(MAE) - "한 기간 전 이동평균으로 이번 달을 예측했다면?" 관점의 벤치마크
SELECT ROUND(AVG(ABS(sales - ma3)), 2) AS ma3_mae
FROM ts_features
WHERE ma3 IS NOT NULL;

-- 3) 향후 6개월 예측치 (SES vs Holt) - Holt는 추세를 반영하므로 SES보다 더 가파르게 증가해야 함
SELECT * FROM ts_forecast ORDER BY month_id;

-- 4) 최근 12개월 전월대비 증감(mom_change) 추세 확인
SELECT month_id, month_date, sales, mom_change
FROM ts_features
ORDER BY month_id DESC
LIMIT 12;
