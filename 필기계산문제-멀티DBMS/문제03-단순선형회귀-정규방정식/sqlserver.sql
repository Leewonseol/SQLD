-- 문제03: 단순선형회귀 정규방정식 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- SQL Server에는 REGR_SLOPE/REGR_INTERCEPT/REGR_R2가 없다 -> 정규방정식을 직접 전개.

IF OBJECT_ID('ad_sales', 'U') IS NOT NULL DROP TABLE ad_sales;

CREATE TABLE ad_sales (
    mon INT,
    x   FLOAT,
    y   FLOAT
);

INSERT INTO ad_sales (mon, x, y) VALUES
    (1, 1, 2), (2, 2, 4), (3, 3, 5), (4, 4, 4), (5, 5, 5);

SELECT
    (AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x)) AS beta1,
    AVG(y) - ((AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x))) * AVG(x) AS beta0,
    AVG(y) + ((AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x))) * (6 - AVG(x)) AS predict_at_x6
FROM ad_sales;
