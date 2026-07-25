-- Olist 고객 데이터 지역별 순위·누적비율·편중도(HHI) (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요
-- 주의: COUNT(*)는 INT를 반환하므로 n_customers/total을 캐스팅 없이 나누면
-- 정수 나눗셈으로 절단된다(필기계산문제-멀티DBMS/문제04 참고). 아래는 1.0*로 방지했다.

SELECT TOP 10 customer_state, COUNT(*) AS n_customers,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_by_customers
FROM customers_raw
GROUP BY customer_state
ORDER BY rank_by_customers;

SELECT customer_state, n_customers,
       ROUND(100.0 * n_customers / SUM(n_customers) OVER (), 2) AS pct,
       ROUND(100.0 * SUM(n_customers) OVER (ORDER BY n_customers DESC
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             / SUM(n_customers) OVER (), 2) AS cumulative_pct
FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state) t
ORDER BY cumulative_pct;

-- 편중도(HHI) = Σ(점유율)^2  -- 1.0*로 정수 나눗셈 방지
SELECT ROUND(SUM(POWER(1.0 * n_customers / total, 2)), 4) AS hhi
FROM (
    SELECT n_customers, (SELECT COUNT(*) FROM customers_raw) AS total
    FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state) x
) y;
