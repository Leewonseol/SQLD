-- 문제01: 평균·분산·표준편차 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- SQL Server Management Studio, Azure Data Studio 등 실제 SQL Server 환경에
-- 그대로 복사해 실행 가능.

IF OBJECT_ID('sales', 'U') IS NOT NULL DROP TABLE sales;

CREATE TABLE sales (
    store  VARCHAR(5),
    amount FLOAT
);

-- SQL Server는 다중행 VALUES를 한 문장으로 지원한다(Oracle과 다른 지점).
INSERT INTO sales (store, amount) VALUES
    ('A', 12), ('B', 15), ('C', 11), ('D', 18), ('E', 14);

SELECT
    AVG(amount)     AS mean,
    VARP(amount)    AS pop_variance,
    STDEVP(amount)  AS pop_stddev,
    VAR(amount)     AS sample_variance,   -- SQL Server: VAR = 표본분산 (Oracle VARIANCE와 동일 의미)
    STDEV(amount)   AS sample_stddev      -- SQL Server: STDEV = 표본표준편차 (Oracle STDDEV와 동일 의미)
FROM sales;
