-- 문제02: 피어슨 상관계수 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- SQL Server에는 CORR 집계함수가 없다 -> 공식을 직접 전개해야 한다(Oracle과 근본적으로
-- 다른 지점: 함수 이름이 다른 게 아니라 함수 자체가 없다).

IF OBJECT_ID('ad_sales', 'U') IS NOT NULL DROP TABLE ad_sales;

CREATE TABLE ad_sales (
    mon INT,
    x   FLOAT,
    y   FLOAT
);

INSERT INTO ad_sales (mon, x, y) VALUES
    (1, 1, 2), (2, 2, 4), (3, 3, 5), (4, 4, 4), (5, 5, 5);

-- r = cov(x,y) / (σx · σy), 모집단 기준(VARP)으로 공식을 직접 전개
SELECT
    (AVG(x*y) - AVG(x)*AVG(y))
    / (
        SQRT(VARP(x)) * SQRT(VARP(y))
      ) AS r_manual
FROM ad_sales;
