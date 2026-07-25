-- 가설검정 결과 검산

SELECT * FROM hyp_test_results;

-- 카이제곱 통계량을 SQL로 직접 재계산 (교차표 -> 기대빈도 -> 카이제곱)
WITH obs AS (
    SELECT state_group, is_repeat_customer, COUNT(*) AS n
    FROM hyp_input
    GROUP BY state_group, is_repeat_customer
),
row_totals AS (
    SELECT state_group, SUM(n) AS row_total FROM obs GROUP BY state_group
),
col_totals AS (
    SELECT is_repeat_customer, SUM(n) AS col_total FROM obs GROUP BY is_repeat_customer
),
grand AS (SELECT SUM(n) AS grand_total FROM obs),
expected AS (
    SELECT o.state_group, o.is_repeat_customer, o.n AS observed,
           1.0 * r.row_total * c.col_total / g.grand_total AS expected
    FROM obs o
    JOIN row_totals r ON r.state_group = o.state_group
    JOIN col_totals c ON c.is_repeat_customer = o.is_repeat_customer
    CROSS JOIN grand g
)
SELECT ROUND(SUM((observed-expected)*(observed-expected)/expected), 4) AS chi2_from_sql
FROM expected;

-- 주별 n_orders 평균 (분산분석의 "집단간 차이"가 실제로 어느 정도인지 눈으로 확인)
SELECT state_group, COUNT(*) AS n, ROUND(AVG(n_orders), 4) AS avg_n_orders
FROM hyp_input
GROUP BY state_group
ORDER BY avg_n_orders DESC;
