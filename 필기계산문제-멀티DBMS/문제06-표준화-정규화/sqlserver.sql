-- 문제06: Z-score 표준화 · Min-Max 정규화 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)

IF OBJECT_ID('sales', 'U') IS NOT NULL DROP TABLE sales;

CREATE TABLE sales (
    store  VARCHAR(5),
    amount FLOAT
);

INSERT INTO sales (store, amount) VALUES
    ('A', 12), ('B', 15), ('C', 11), ('D', 18), ('E', 14);

-- SQL Server도 STDEVP를 윈도우 함수(OVER())로 그대로 쓸 수 있다 - Oracle과 동일한 패턴.
SELECT
    store, amount,
    (amount - AVG(amount) OVER()) / STDEVP(amount) OVER() AS z_score,
    (amount - MIN(amount) OVER()) / (MAX(amount) OVER() - MIN(amount) OVER()) AS min_max
FROM sales
ORDER BY store;
