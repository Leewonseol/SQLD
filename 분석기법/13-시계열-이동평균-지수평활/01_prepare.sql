-- 시계열 입력 준비: 3/6개월 이동평균, 전월 대비(lag) 컬럼을 윈도우 함수로 생성

DROP TABLE IF EXISTS ts_features;
CREATE TABLE ts_features AS
SELECT
    month_id,
    month_date,
    sales,
    AVG(sales) OVER (ORDER BY month_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ma3,
    AVG(sales) OVER (ORDER BY month_id ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS ma6,
    LAG(sales, 1) OVER (ORDER BY month_id) AS prev_month_sales,
    sales - LAG(sales, 1) OVER (ORDER BY month_id) AS mom_change
FROM monthly_sales
ORDER BY month_id;

SELECT month_id, month_date, sales, ROUND(ma3, 1) AS ma3, ROUND(ma6, 1) AS ma6
FROM ts_features
ORDER BY month_id DESC
LIMIT 5;
