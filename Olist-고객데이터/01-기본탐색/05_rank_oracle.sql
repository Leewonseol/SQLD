-- Olist 고객 데이터 지역별 순위·누적비율·편중도(HHI) (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요

-- 순위 (RANK: 동점이면 같은 순위, 다음 순위는 건너뜀)
SELECT customer_state, COUNT(*) AS n_customers,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_by_customers
FROM customers_raw
GROUP BY customer_state
ORDER BY rank_by_customers
FETCH FIRST 10 ROWS ONLY;

-- 누적 비율(파레토)
SELECT customer_state, n_customers,
       ROUND(100 * n_customers / SUM(n_customers) OVER (), 2) AS pct,
       ROUND(100 * SUM(n_customers) OVER (ORDER BY n_customers DESC
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             / SUM(n_customers) OVER (), 2) AS cumulative_pct
FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state)
ORDER BY cumulative_pct;

-- 편중도(HHI) = Σ(점유율)^2
SELECT ROUND(SUM(POWER(n_customers / total, 2)), 4) AS hhi
FROM (
    SELECT n_customers, (SELECT COUNT(*) FROM customers_raw) AS total
    FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state)
);
