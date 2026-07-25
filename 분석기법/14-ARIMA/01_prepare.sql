-- ARIMA 입력 준비: 1차 차분, 시차(lag) 컬럼 생성

DROP TABLE IF EXISTS arima_features;
CREATE TABLE arima_features AS
SELECT
    month_id,
    month_date,
    sales,
    sales - LAG(sales, 1) OVER (ORDER BY month_id) AS diff1,
    LAG(sales, 1) OVER (ORDER BY month_id) AS lag1,
    LAG(sales, 2) OVER (ORDER BY month_id) AS lag2
FROM monthly_sales
ORDER BY month_id;

-- 정상성 육안 확인: 원계열 vs 차분계열의 전반부/후반부 분산 비교
-- (차분 후 분산이 안정되면 -> 전반부/후반부 분산이 비슷해짐)
SELECT
    'original' AS series,
    (SELECT SQRT(AVG(sales*sales)-AVG(sales)*AVG(sales)) FROM arima_features WHERE month_id <= 24) AS sd_first_half,
    (SELECT SQRT(AVG(sales*sales)-AVG(sales)*AVG(sales)) FROM arima_features WHERE month_id > 24) AS sd_second_half
UNION ALL
SELECT
    'diff1',
    (SELECT SQRT(AVG(diff1*diff1)-AVG(diff1)*AVG(diff1)) FROM arima_features WHERE month_id <= 24 AND diff1 IS NOT NULL),
    (SELECT SQRT(AVG(diff1*diff1)-AVG(diff1)*AVG(diff1)) FROM arima_features WHERE month_id > 24 AND diff1 IS NOT NULL);
