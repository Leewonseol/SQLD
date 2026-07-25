-- kNN 결측값 대체 입력 준비 + 10단계 대체 파이프라인 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- 로직은 optional/01_prepare_sqlite.sql로 이 저장소에서 실제 실행·검증한 뒤
-- SQL Server 문법으로 옮긴 것이다(수치 결과는 SQLite 실행 결과와 README를 참고).
--
-- 이 테이블은 Olist 원자료(olist_customers_dataset.csv)에서 만든 것이 아니라
-- kNN 결측값 대체·Oracle/SQL Server NULL 문법 차이를 보여주기 위해 새로 만든
-- 별도의 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다.
--
-- *** SQL Server는 Oracle과 달리 ''(빈 문자열)와 NULL을 별개 값으로 저장한다.
-- C005의 coupon_code_raw='' 는 그대로 ''로 남고, C003의 NULL과 명확히
-- 구분된다 — Oracle 버전(01_prepare_oracle.sql)에서는 이 둘이 저장 단계부터
-- 구분되지 않는다는 점과 정면으로 대조된다. ***

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

-- C010과 C014는 recency=8, frequency=7, monetary=96, delivery_days=4,
-- review_score=5로 값이 의도적으로 동일하다 — C018 기준 근접이웃 순위에서
-- 동률(tie)이 나오도록 설계했다. target_missing_value는 100/96으로 서로 달라,
-- "동률 이웃이라고 결과도 같지는 않다"는 점을 보여준다.

-- =====================================================================
-- STEP 1. NULL/빈 문자열/공백 식별 (SQL Server)
--   coupon_is_null 과 coupon_is_empty_string 이 서로 다른 행(C003 vs C005)을
--   가리킨다는 점이 Oracle 버전과 정반대다.
--   *** LEN()은 뒤쪽 공백을 잘라내고 길이를 센다 — LEN(' ')=0.
--   실제 저장된 바이트 길이는 DATALENGTH(' ')=1로 확인해야 한다.
--   즉 C006(공백 문자열)은 LEN 기준으로는 "빈 값처럼" 보이지만 실제로는
--   NULL도 ''도 아닌, 공백 1글자가 들어있는 값이다. ***
-- =====================================================================
IF OBJECT_ID('null_identification', 'U') IS NOT NULL DROP TABLE null_identification;
SELECT
    customer_id,
    CASE WHEN recency IS NULL THEN 1 ELSE 0 END AS recency_is_null,
    CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END AS delivery_days_is_null,
    CASE WHEN target_missing_value IS NULL THEN 1 ELSE 0 END AS target_is_null,
    CASE WHEN coupon_code_raw IS NULL THEN 1 ELSE 0 END AS coupon_is_null,
    CASE WHEN coupon_code_raw = '' THEN 1 ELSE 0 END AS coupon_is_empty_string,
    CASE WHEN coupon_code_raw = ' ' THEN 1 ELSE 0 END AS coupon_is_whitespace,
    LEN(coupon_code_raw) AS coupon_len_trimmed,
    DATALENGTH(coupon_code_raw) AS coupon_len_actual_bytes
INTO null_identification
FROM impute_practice_raw;

SELECT SUM(coupon_is_null) AS null_count,
       SUM(coupon_is_empty_string) AS empty_string_count,
       SUM(coupon_is_whitespace) AS whitespace_count
FROM null_identification;

-- =====================================================================
-- STEP 2. NULL 처리 함수 비교 (SQL Server: ISNULL, COALESCE, NULLIF, CASE)
--   SQL Server에는 NVL/NVL2가 없다 — ISNULL(expr, 대체값)이 NVL과 같은 역할을
--   하지만, ISNULL은 반환 타입을 첫 번째 인수(expr) 기준으로 고정한다는 점이
--   여러 타입의 인수를 넓혀 맞추는 COALESCE와 다르다(SQLD 필기 함정 포인트).
-- =====================================================================
SELECT TOP 6
    customer_id,
    coupon_code_raw,
    ISNULL(coupon_code_raw, '(NO_COUPON)') AS isnull_result,
    COALESCE(coupon_code_raw, '(NO_COUPON)') AS coalesce_result,
    -- SQL Server에서는 ''가 진짜 빈 문자열로 남아 있으므로, NULLIF는 원래
    -- 의도대로(빈 문자열이면 NULL로 바꿔서) 동작한다 — Oracle과 달리 의미가 있다.
    NULLIF(coupon_code_raw, '') AS nullif_result,
    CASE WHEN coupon_code_raw IS NULL THEN '(NO_COUPON via CASE)' ELSE coupon_code_raw END AS case_result
FROM impute_practice_raw
WHERE scenario_type IN ('complete', 'empty_string', 'whitespace_string')
ORDER BY customer_id;

-- =====================================================================
-- STEP 3~4. 단순 대체(전체 평균/중앙값) 베이스라인 — 도너 풀(15행) 기준
--   SQL Server에는 MEDIAN() 집계함수가 없다 — PERCENTILE_CONT(0.5)
--   WITHIN GROUP (ORDER BY ...) OVER ()로 대신한다(Oracle 버전과의 핵심 차이).
-- =====================================================================
SELECT DISTINCT
    AVG(target_missing_value) OVER () AS overall_mean,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY target_missing_value) OVER () AS overall_median,
    COUNT(*) OVER () AS donor_pool_count
INTO impute_baseline_stats
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL;

SELECT * FROM impute_baseline_stats;

-- =====================================================================
-- STEP 5. 도너 풀 / 대체 대상 풀 분리
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
-- STEP 6. 쌍별(pairwise) 거리 계산
--   대체 대상 쪽에서 NULL인 변수(C017의 recency, delivery_days)는 그 쌍의
--   거리 계산에서 제외한다(공통으로 관측된 변수만 사용).
-- =====================================================================
SELECT
    t.customer_id AS target_customer_id,
    d.customer_id AS donor_customer_id,
    d.target_missing_value AS donor_target_value,
    (
        (CASE WHEN t.recency IS NOT NULL THEN (t.recency - d.recency) * (t.recency - d.recency) ELSE 0 END) +
        (t.frequency - d.frequency) * (t.frequency - d.frequency) +
        (t.monetary - d.monetary) * (t.monetary - d.monetary) +
        (CASE WHEN t.delivery_days IS NOT NULL THEN (t.delivery_days - d.delivery_days) * (t.delivery_days - d.delivery_days) ELSE 0 END) +
        (t.review_score - d.review_score) * (t.review_score - d.review_score)
    ) AS raw_sq_sum,
    (
        (CASE WHEN t.recency IS NOT NULL THEN 1 ELSE 0 END) +
        1 + 1 +
        (CASE WHEN t.delivery_days IS NOT NULL THEN 1 ELSE 0 END) +
        1
    ) AS dims_used
INTO pairwise_distance
FROM impute_target_pool t
CROSS JOIN donor_pool d;

SELECT
    target_customer_id,
    donor_customer_id,
    donor_target_value,
    raw_sq_sum,
    dims_used,
    SQRT(raw_sq_sum) AS dist_raw,
    SQRT(raw_sq_sum * 1.0 / dims_used) AS dist_normalized
INTO pairwise_distance_final
FROM pairwise_distance;

-- =====================================================================
-- STEP 7. k = ROUND(SQRT(도너 풀 크기)) — Jonsson & Wohlin(2004) 규칙
--   도너 풀 15행 → sqrt(15) = 3.873 → round = 4
-- =====================================================================
SELECT
    donor_pool_count,
    SQRT(donor_pool_count * 1.0) AS sqrt_n,
    ROUND(SQRT(donor_pool_count * 1.0), 0) AS k
INTO knn_k_value
FROM impute_baseline_stats;

SELECT * FROM knn_k_value;

-- =====================================================================
-- STEP 8. 근접이웃 순위 매기기 — ROW_NUMBER(동률 시 customer_id로 결정적
--   타이브레이크)와 RANK(동률을 모두 포함) 두 방식을 함께 기록해 비교한다.
-- =====================================================================
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
-- STEP 9. k=4 최근접이웃 평균으로 대체값 계산 — 두 가지 이웃 선택 방식 비교
-- =====================================================================
SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_strict,
    COUNT(*) AS neighbors_used
INTO knn_imputed_strict
FROM ranked_neighbors rn
CROSS JOIN knn_k_value k
WHERE rn.rn_tiebreak <= k.k
GROUP BY rn.target_customer_id;

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
-- STEP 10. 최종 결과 테이블
-- =====================================================================
SELECT
    r.customer_id,
    r.scenario_type,
    r.target_missing_value AS original_value,
    b.overall_mean AS mean_imputed,
    b.overall_median AS median_imputed,
    s.knn_imputed_strict,
    s.neighbors_used AS knn_neighbors_strict,
    w.knn_imputed_with_ties,
    w.neighbors_used AS knn_neighbors_with_ties,
    r.true_value_for_check
INTO impute_practice_result
FROM impute_practice_raw r
LEFT JOIN knn_imputed_strict s ON s.customer_id = r.customer_id
LEFT JOIN knn_imputed_with_ties w ON w.customer_id = r.customer_id
CROSS JOIN impute_baseline_stats b
ORDER BY r.customer_id;

SELECT * FROM impute_practice_result ORDER BY customer_id;
