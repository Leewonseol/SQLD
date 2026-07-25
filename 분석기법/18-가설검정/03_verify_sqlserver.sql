-- 가설검정 결과 검산 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요
-- 이 파일 전체에서 SUM(n)/COUNT(*) 등 INT 집계 결과를 나누는 지점마다 1.0*을 붙였다
-- (분석기법/06-로지스틱회귀, 필기계산문제-멀티DBMS/문제04와 같은 이유).

CREATE TABLE hypothesis_test_results (
    test VARCHAR(30), statistic FLOAT, p_value FLOAT, reject_h0_at_005 BIT
);

-- 0) Python이 계산한 검정 결과
SELECT * FROM hypothesis_test_results;

-- 1) 대응표본 t검정
SELECT
    ROUND(mean_diff, 4) AS mean_diff,
    ROUND(sample_sd_diff, 4) AS sample_sd_diff,
    n,
    ROUND(mean_diff / (sample_sd_diff / SQRT(1.0 * n)), 4) AS t_stat_from_sql
FROM paired_diff_summary;

-- 2) 일원배치 분산분석
WITH grand AS (
    SELECT SUM(mean_score * n) / SUM(1.0 * n) AS grand_mean, SUM(n) AS total_n, COUNT(*) AS k
    FROM branch_group_summary
),
ssb_ssw AS (
    SELECT
        SUM(b.n * POWER(b.mean_score - g.grand_mean, 2)) AS SSB,
        SUM(b.n * b.pop_variance) AS SSW,
        g.total_n AS total_n, g.k AS k
    FROM branch_group_summary b
    CROSS JOIN grand g
)
SELECT
    ROUND(SSB, 4) AS SSB, ROUND(SSW, 4) AS SSW,
    ROUND((SSB/(k-1)) / (SSW/(1.0*total_n-k)), 4) AS f_stat_from_sql
FROM ssb_ssw;

-- 3) 카이제곱 독립성 검정
WITH totals AS (
    SELECT variant, SUM(n) AS row_total FROM ab_contingency GROUP BY variant
),
col_totals AS (
    SELECT converted, SUM(n) AS col_total FROM ab_contingency GROUP BY converted
),
grand AS (
    SELECT SUM(n) AS grand_total FROM ab_contingency
),
expected AS (
    SELECT c.variant, c.converted, c.n AS observed,
           1.0 * t.row_total * ct.col_total / g.grand_total AS expected  -- INT*INT/INT 정수 나눗셈 방지 필수
    FROM ab_contingency c
    JOIN totals t ON t.variant = c.variant
    JOIN col_totals ct ON ct.converted = c.converted
    CROSS JOIN grand g
)
SELECT ROUND(SUM(POWER(observed-expected, 2)/expected), 4) AS chi2_stat_from_sql
FROM expected;
