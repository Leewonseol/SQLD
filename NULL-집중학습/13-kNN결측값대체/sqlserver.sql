-- 13-kNN결측값대체 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요(이 세션에는 SQL Server 실행 환경이 없음).
-- impute_practice_raw는 분석기법/22-KNN결측값대체/01_prepare_sqlserver.sql과
-- 완전히 같은 테이블을 재사용한다(12-평균-중앙값대치와 동일한 데이터).
-- 이 파일은 22-KNN결측값대체의 STEP 5~10을 이 학습 모듈 안에서 재현한
-- 축약판이다 — 상세 설계 배경은 분석기법/22-KNN결측값대체/README.md 참고.
--
-- Olist 원자료(olist_customers_dataset.csv)에는 실제 결측이 없다 — 이 표는
-- Olist와 무관한, kNN·평균·중앙값 대치 실습을 위한 별도의 작은 합성 데이터다.

IF OBJECT_ID('impute_practice_raw', 'U') IS NOT NULL DROP TABLE impute_practice_raw;

CREATE TABLE impute_practice_raw (
    customer_id           VARCHAR(10) PRIMARY KEY,
    recency                FLOAT,
    frequency               FLOAT,
    monetary                FLOAT,
    delivery_days           FLOAT,
    review_score            FLOAT,
    target_missing_value    FLOAT,
    coupon_code_raw         VARCHAR(20),
    true_value_for_check    FLOAT,
    scenario_type           VARCHAR(30)
);

INSERT INTO impute_practice_raw VALUES ('C001', 10, 8, 120, 3, 5, 130,  'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C002', 45, 3, 60,  5, 3, 55,   'SPRING5',   NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C003', 5,  12,200, 2, 5, 210,  NULL,        NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C004', 90, 1, 20,  7, 2, 15,   'WINTER20',  NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C005', 30, 5, 80,  4, 4, 85,   '',          NULL, 'empty_string');
INSERT INTO impute_practice_raw VALUES ('C006', 15, 7, 110, 3, 4, 120,  ' ',         NULL, 'whitespace_string');
INSERT INTO impute_practice_raw VALUES ('C007', 60, 2, 40,  6, 3, 35,   'FALL15',    NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C008', 8,  9, 150, 2, 5, 160,  'SUMMER25',  NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C009', 100,0, 0,   9, 1, 0,    'EXPIRED',   NULL, 'zero_value');
INSERT INTO impute_practice_raw VALUES ('C010', 8,  7, 96,  4, 5, 100,  'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C011', 12, 8, 125, 3, 5, 135,  'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C012', 25, 4, 98000,3, 5, 95000,'VIP1',     NULL, 'extreme_value');
INSERT INTO impute_practice_raw VALUES ('C013', 40, 3, 65,  5, 3, 58,   'SPRING5',   NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C014', 8,  7, 96,  4, 5, 96,   'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C015', 50, 2, 42,  6, 3, 38,   'FALL15',    NULL, 'complete');

INSERT INTO impute_practice_raw VALUES ('C016', 11,   8, 122,   3,   5, NULL, 'WELCOME10', 132,   'single_null');
INSERT INTO impute_practice_raw VALUES ('C017', NULL, 3, 62,    NULL,3, NULL, 'SPRING5',   56,    'multi_null');
INSERT INTO impute_practice_raw VALUES ('C018', 13,   8, 123,   3,   5, NULL, 'WELCOME10', 133,   'distance_tie');
INSERT INTO impute_practice_raw VALUES ('C019', 24,   4, 97500, 3,   5, NULL, 'VIP1',      94000, 'near_extreme');
INSERT INTO impute_practice_raw VALUES ('C020', 95,   1, 18,    8,   2, NULL, 'WINTER20',  17,    'single_null');

-- =====================================================================
-- STEP 1. 도너 풀 / 대체 대상 풀 분리
-- =====================================================================
IF OBJECT_ID('donor_pool', 'V') IS NOT NULL DROP VIEW donor_pool;
GO
CREATE VIEW donor_pool AS
SELECT * FROM impute_practice_raw WHERE target_missing_value IS NOT NULL;
GO

IF OBJECT_ID('impute_target_pool', 'V') IS NOT NULL DROP VIEW impute_target_pool;
GO
CREATE VIEW impute_target_pool AS
SELECT * FROM impute_practice_raw WHERE target_missing_value IS NULL;
GO

-- =====================================================================
-- STEP 2. k = ROUND(SQRT(도너 풀 크기))
-- =====================================================================
IF OBJECT_ID('knn_k_value', 'U') IS NOT NULL DROP TABLE knn_k_value;

SELECT
    COUNT(*) AS donor_pool_count,
    SQRT(COUNT(*) * 1.0) AS sqrt_n,
    ROUND(SQRT(COUNT(*) * 1.0), 0) AS k
INTO knn_k_value
FROM donor_pool;

SELECT * FROM knn_k_value;

-- =====================================================================
-- STEP 3. 쌍별 유클리드 거리 계산(정규화 거리)
-- =====================================================================
IF OBJECT_ID('pairwise_distance_final', 'U') IS NOT NULL DROP TABLE pairwise_distance_final;

SELECT
    t.customer_id AS target_customer_id,
    d.customer_id AS donor_customer_id,
    d.target_missing_value AS donor_target_value,
    SQRT(
        (
            (CASE WHEN t.recency IS NOT NULL THEN (t.recency - d.recency) * (t.recency - d.recency) ELSE 0 END) +
            (t.frequency - d.frequency) * (t.frequency - d.frequency) +
            (t.monetary - d.monetary) * (t.monetary - d.monetary) +
            (CASE WHEN t.delivery_days IS NOT NULL THEN (t.delivery_days - d.delivery_days) * (t.delivery_days - d.delivery_days) ELSE 0 END) +
            (t.review_score - d.review_score) * (t.review_score - d.review_score)
        ) * 1.0
        /
        (
            (CASE WHEN t.recency IS NOT NULL THEN 1 ELSE 0 END) + 1 + 1 +
            (CASE WHEN t.delivery_days IS NOT NULL THEN 1 ELSE 0 END) + 1
        )
    ) AS dist_normalized
INTO pairwise_distance_final
FROM impute_target_pool t
CROSS JOIN donor_pool d;

-- =====================================================================
-- STEP 4. 근접이웃 순위 매기기
-- =====================================================================
IF OBJECT_ID('ranked_neighbors', 'U') IS NOT NULL DROP TABLE ranked_neighbors;

SELECT
    target_customer_id,
    donor_customer_id,
    donor_target_value,
    dist_normalized,
    ROW_NUMBER() OVER (
        PARTITION BY target_customer_id ORDER BY dist_normalized ASC, donor_customer_id ASC
    ) AS rn_tiebreak,
    RANK() OVER (
        PARTITION BY target_customer_id ORDER BY dist_normalized ASC
    ) AS rnk_with_ties
INTO ranked_neighbors
FROM pairwise_distance_final;

-- =====================================================================
-- STEP 5. k=4 최근접이웃 평균으로 대체값 계산
-- =====================================================================
IF OBJECT_ID('knn_imputed_strict', 'U') IS NOT NULL DROP TABLE knn_imputed_strict;

SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_strict,
    COUNT(*) AS neighbors_used
INTO knn_imputed_strict
FROM ranked_neighbors rn
CROSS JOIN knn_k_value k
WHERE rn.rn_tiebreak <= k.k
GROUP BY rn.target_customer_id;

IF OBJECT_ID('knn_imputed_with_ties', 'U') IS NOT NULL DROP TABLE knn_imputed_with_ties;

SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_with_ties,
    COUNT(*) AS neighbors_used
INTO knn_imputed_with_ties
FROM ranked_neighbors rn
CROSS JOIN knn_k_value k
WHERE rn.rnk_with_ties <= k.k
GROUP BY rn.target_customer_id;

-- =====================================================================
-- STEP 6. 최종 비교 테이블 — kNN 대체 vs 12-평균-중앙값대치의 평균/중앙값 대체
-- =====================================================================
IF OBJECT_ID('knn_vs_baseline_result', 'U') IS NOT NULL DROP TABLE knn_vs_baseline_result;

SELECT
    r.customer_id,
    r.scenario_type,
    r.true_value_for_check,
    s.knn_imputed_strict,
    ROUND(s.knn_imputed_strict - r.true_value_for_check, 2) AS error_knn_strict,
    w.knn_imputed_with_ties,
    b.overall_mean AS mean_imputed,
    b.overall_median AS median_imputed
INTO knn_vs_baseline_result
FROM impute_practice_raw r
JOIN knn_imputed_strict s ON s.customer_id = r.customer_id
JOIN knn_imputed_with_ties w ON w.customer_id = r.customer_id
CROSS JOIN (
    SELECT AVG(target_missing_value) AS overall_mean,
           (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY target_missing_value)
            FROM donor_pool) AS overall_median
    FROM donor_pool
) b
WHERE r.target_missing_value IS NULL;

SELECT * FROM knn_vs_baseline_result ORDER BY customer_id;

-- =====================================================================
-- STEP 7. RMSE 비교
-- =====================================================================
SELECT
    ROUND(SQRT(AVG((knn_imputed_strict - true_value_for_check) * (knn_imputed_strict - true_value_for_check))), 2) AS rmse_knn_strict,
    ROUND(SQRT(AVG((mean_imputed - true_value_for_check) * (mean_imputed - true_value_for_check))), 2) AS rmse_mean,
    ROUND(SQRT(AVG((median_imputed - true_value_for_check) * (median_imputed - true_value_for_check))), 2) AS rmse_median
FROM knn_vs_baseline_result;
-- 예상: rmse_knn_strict=31360.29, rmse_mean=39576.11, rmse_median=41995.17
-- (분석기법/22-KNN결측값대체/README.md와 동일 — 같은 데이터·같은 계산)
