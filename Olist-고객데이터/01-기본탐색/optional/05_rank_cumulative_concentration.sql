-- 기본 탐색 (4): 고객 수 기준 순위 / 지역별 누적 비율 / 고객 분포의 편중도

-- [12] 고객 수 기준 순위 (RANK: 동점이면 같은 순위, 다음 순위는 건너뜀)
DROP TABLE IF EXISTS state_rank;
CREATE TABLE state_rank AS
SELECT
    customer_state,
    COUNT(*) AS n_customers,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_by_customers
FROM customers_raw
GROUP BY customer_state;

SELECT * FROM state_rank ORDER BY rank_by_customers LIMIT 10;

-- [13] 지역별 누적 비율 (파레토 분석: 상위 몇 개 주가 전체의 몇 %를 차지하는가)
DROP TABLE IF EXISTS state_cumulative;
CREATE TABLE state_cumulative AS
SELECT
    customer_state,
    n_customers,
    ROUND(100.0 * n_customers / SUM(n_customers) OVER (), 2) AS pct,
    ROUND(100.0 * SUM(n_customers) OVER (ORDER BY n_customers DESC
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(n_customers) OVER (), 2) AS cumulative_pct
FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state) t;

SELECT * FROM state_cumulative ORDER BY cumulative_pct;

-- 상위 몇 개 주가 누적 80%를 넘기는 시점(파레토 80/20 확인)
SELECT MIN(rn) AS n_states_to_reach_80pct
FROM (
    SELECT customer_state, cumulative_pct, ROW_NUMBER() OVER (ORDER BY cumulative_pct) AS rn
    FROM state_cumulative
) t
WHERE cumulative_pct >= 80;

-- [14] 고객 분포의 편중도: 허핀달-허쉬만 지수(HHI) = Σ(점유율)^2 (점유율은 0~1)
--     HHI가 1에 가까울수록 특정 지역에 집중, 1/N에 가까울수록 고르게 분산
SELECT
    ROUND(SUM((1.0 * n_customers / total) * (1.0 * n_customers / total)), 4) AS hhi,
    COUNT(*) AS n_states,
    ROUND(1.0 / COUNT(*), 4) AS hhi_if_perfectly_even
FROM (
    SELECT customer_state, n_customers, (SELECT COUNT(*) FROM customers_raw) AS total
    FROM (SELECT customer_state, COUNT(*) AS n_customers FROM customers_raw GROUP BY customer_state)
) t;
