-- 가설검정 결과 검산 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE hypothesis_test_results (
    test VARCHAR2(30), statistic NUMBER, p_value NUMBER, reject_h0_at_005 NUMBER
);

-- 0) Python이 계산한 검정 결과
SELECT * FROM hypothesis_test_results;

-- 1) 대응표본 t검정: SQL 요약통계로 t값 직접 재계산
SELECT
    ROUND(mean_diff, 4) AS mean_diff,
    ROUND(sample_sd_diff, 4) AS sample_sd_diff,
    n,
    ROUND(mean_diff / (sample_sd_diff / SQRT(n)), 4) AS t_stat_from_sql
FROM paired_diff_summary;

-- 2) 일원배치 분산분석: SQL 요약통계로 F값 직접 재계산
WITH grand AS (
    SELECT SUM(mean_score * n) / SUM(n) AS grand_mean, SUM(n) AS total_n, COUNT(*) AS k
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
    ROUND((SSB/(k-1)) / (SSW/(total_n-k)), 4) AS f_stat_from_sql
FROM ssb_ssw;

-- 3) 카이제곱 독립성 검정: SQL 교차표로 카이제곱 통계량 직접 재계산
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
           t.row_total * ct.col_total / g.grand_total AS expected   -- Oracle NUMBER는 캐스팅 불필요
    FROM ab_contingency c
    JOIN totals t ON t.variant = c.variant
    JOIN col_totals ct ON ct.converted = c.converted
    CROSS JOIN grand g
)
SELECT ROUND(SUM(POWER(observed-expected, 2)/expected), 4) AS chi2_stat_from_sql
FROM expected;
