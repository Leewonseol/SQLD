-- kNN 결측값 대체 입력 준비 (SQLite 보조 실행) — 이 저장소에서 실제로 실행 확인됨
--
-- 이 테이블은 Olist 원자료(olist_customers_dataset.csv)에서 만든 것이 아니라
-- kNN 결측값 대체·Oracle/SQL Server NULL 문법 차이를 보여주기 위해 새로 만든
-- 별도의 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다
-- (00-데이터사전/profile.py 로 확인됨) — 이 테이블을 Olist 실측 결측으로 오인하지 말 것.

DROP TABLE IF EXISTS impute_practice_raw;

CREATE TABLE impute_practice_raw (
    customer_id           TEXT PRIMARY KEY,
    recency                REAL,    -- 최근 구매 후 경과일. C017에서 NULL(다중 결측 시나리오)
    frequency               REAL,    -- 구매 횟수. C009에서 0(정상값, 결측 아님)
    monetary                REAL,    -- 누적 구매액(단위: 천원). C012에서 극단값
    delivery_days           REAL,    -- 평균 배송일. C017에서 NULL(다중 결측 시나리오)
    review_score            REAL,    -- 리뷰 평점 1~5
    target_missing_value    REAL,    -- kNN으로 대체할 타깃(다음달 예상 지출, 단위: 천원). C016~C020에서 NULL
    coupon_code_raw         TEXT,    -- 문자열 컬럼: NULL / '' / ' ' 세 가지를 구분해서 담는다
    true_value_for_check    REAL,    -- 검증 전용 정답값. 대체 계산에는 절대 쓰지 않는다. 실무라면 알 수 없는 값
    scenario_type           TEXT     -- 이 행이 어떤 데이터 품질 시나리오를 보여주는지 표시
);

-- 도너 풀(target_missing_value가 관측된 15행) -----------------------------
INSERT INTO impute_practice_raw VALUES
('C001', 10, 8, 120, 3, 5, 130,  'WELCOME10', NULL, 'complete'),
('C002', 45, 3, 60,  5, 3, 55,   'SPRING5',   NULL, 'complete'),
('C003', 5,  12,200, 2, 5, 210,  NULL,        NULL, 'complete'),
('C004', 90, 1, 20,  7, 2, 15,   'WINTER20',  NULL, 'complete'),
('C005', 30, 5, 80,  4, 4, 85,   '',          NULL, 'empty_string'),
('C006', 15, 7, 110, 3, 4, 120,  ' ',         NULL, 'whitespace_string'),
('C007', 60, 2, 40,  6, 3, 35,   'FALL15',    NULL, 'complete'),
('C008', 8,  9, 150, 2, 5, 160,  'SUMMER25',  NULL, 'complete'),
('C009', 100,0, 0,   9, 1, 0,    'EXPIRED',   NULL, 'zero_value'),
('C010', 8,  7, 96,  4, 5, 100,  'WELCOME10', NULL, 'complete'),
('C011', 12, 8, 125, 3, 5, 135,  'WELCOME10', NULL, 'complete'),
('C012', 25, 4, 98000,3, 5, 95000,'VIP1',     NULL, 'extreme_value'),
('C013', 40, 3, 65,  5, 3, 58,   'SPRING5',   NULL, 'complete'),
('C014', 8,  7, 96,  4, 5, 96,   'WELCOME10', NULL, 'complete'),
('C015', 50, 2, 42,  6, 3, 38,   'FALL15',    NULL, 'complete');

-- 대체 대상(target_missing_value가 NULL인 5행) -----------------------------
INSERT INTO impute_practice_raw VALUES
('C016', 11,   8, 122,   3,   5, NULL, 'WELCOME10', 132,   'single_null'),
('C017', NULL, 3, 62,    NULL,3, NULL, 'SPRING5',   56,    'multi_null'),
('C018', 13,   8, 123,   3,   5, NULL, 'WELCOME10', 133,   'distance_tie'),
('C019', 24,   4, 97500, 3,   5, NULL, 'VIP1',      94000, 'near_extreme'),
('C020', 95,   1, 18,    8,   2, NULL, 'WINTER20',  17,    'single_null');

-- 참고: C010과 C014는 값이 의도적으로 동일하다(recency=8, frequency=7,
-- monetary=96, delivery_days=4, review_score=5) — C018 기준 4번째 근접이웃
-- 자리에서 동률(tie)이 나도록 설계했다. target_missing_value는 100/96으로
-- 서로 달라, "동률 이웃이라고 결과도 같지는 않다"는 점을 보여준다.


-- =====================================================================
-- STEP 1. NULL/빈 문자열/공백 식별
-- =====================================================================
DROP VIEW IF EXISTS null_identification;
CREATE VIEW null_identification AS
SELECT
    customer_id,
    CASE WHEN recency IS NULL THEN 1 ELSE 0 END AS recency_is_null,
    CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END AS delivery_days_is_null,
    CASE WHEN target_missing_value IS NULL THEN 1 ELSE 0 END AS target_is_null,
    CASE WHEN coupon_code_raw IS NULL THEN 1 ELSE 0 END AS coupon_is_null,
    CASE WHEN coupon_code_raw = '' THEN 1 ELSE 0 END AS coupon_is_empty_string,
    CASE WHEN coupon_code_raw = ' ' THEN 1 ELSE 0 END AS coupon_is_whitespace
FROM impute_practice_raw;

-- =====================================================================
-- STEP 2. NULL 처리 함수 비교 데모 (SQLite 보조: IFNULL/COALESCE/NULLIF)
--   실제 Oracle 버전은 NVL/NVL2/COALESCE, SQL Server 버전은
--   ISNULL/COALESCE 를 각각 01_prepare_oracle.sql / 01_prepare_sqlserver.sql 에서 다룬다.
--   여기서는 이식 가능한 IFNULL/COALESCE 로 "함수 자체의 결측 대체 동작"만 보여준다.
-- =====================================================================
SELECT
    customer_id,
    coupon_code_raw,
    IFNULL(coupon_code_raw, '(NO_COUPON)') AS ifnull_result,
    COALESCE(coupon_code_raw, '(NO_COUPON)') AS coalesce_result,
    NULLIF(coupon_code_raw, '') AS nullif_empty_to_null
FROM impute_practice_raw
WHERE scenario_type IN ('complete', 'empty_string', 'whitespace_string')
ORDER BY customer_id
LIMIT 6;

-- =====================================================================
-- STEP 3~4. 단순 대체(전체 평균/중앙값) 베이스라인 — 도너 풀(15행) 기준
-- =====================================================================
DROP TABLE IF EXISTS impute_baseline_stats;
CREATE TABLE impute_baseline_stats AS
SELECT
    AVG(target_missing_value) AS overall_mean,
    (
        -- SQLite에는 MEDIAN()이 없어 정렬 후 중앙 순번을 직접 뽑는다(도너 15행 → 8번째 값)
        SELECT target_missing_value FROM impute_practice_raw
        WHERE target_missing_value IS NOT NULL
        ORDER BY target_missing_value
        LIMIT 1 OFFSET 7
    ) AS overall_median,
    COUNT(*) AS donor_pool_count
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL;

SELECT * FROM impute_baseline_stats;

-- =====================================================================
-- STEP 5. 도너 풀 / 대체 대상 풀 분리
-- =====================================================================
DROP VIEW IF EXISTS donor_pool;
CREATE VIEW donor_pool AS
SELECT * FROM impute_practice_raw WHERE target_missing_value IS NOT NULL;

DROP VIEW IF EXISTS impute_target_pool;
CREATE VIEW impute_target_pool AS
SELECT * FROM impute_practice_raw WHERE target_missing_value IS NULL;

-- =====================================================================
-- STEP 6. 쌍별(pairwise) 거리 계산
--   대체 대상 쪽에서 NULL인 변수(C017의 recency, delivery_days)는 그 쌍의
--   거리 계산에서 제외한다(공통으로 관측된 변수만 사용). 도너 풀은 설계상
--   5개 변수 모두 NULL이 없다.
--   raw_sq_sum: 논문 원래 공식(Σ(X_io-X_jo)^2) 그대로의 제곱합
--   dims_used : 이번 쌍에서 실제로 비교에 쓰인 변수 개수(4 또는 5)
--   dist_normalized: sqrt(raw_sq_sum / dims_used) — 변수 개수가 쌍마다
--     달라질 수 있어(C017), 개수가 다른 쌍끼리도 비교 가능하도록 평균
--     제곱거리의 제곱근을 쓴다. dims_used가 항상 5로 같다면 raw와 동일한
--     순위를 준다.
-- =====================================================================
DROP TABLE IF EXISTS pairwise_distance;
CREATE TABLE pairwise_distance AS
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
FROM impute_target_pool t
CROSS JOIN donor_pool d;

DROP TABLE IF EXISTS pairwise_distance_final;
CREATE TABLE pairwise_distance_final AS
SELECT
    target_customer_id,
    donor_customer_id,
    donor_target_value,
    raw_sq_sum,
    dims_used,
    SQRT(raw_sq_sum) AS dist_raw,
    SQRT(1.0 * raw_sq_sum / dims_used) AS dist_normalized
FROM pairwise_distance;

-- =====================================================================
-- STEP 7. k = round(sqrt(도너 풀 크기)) — Jonsson & Wohlin(2004) 규칙
--   도너 풀 15행 → sqrt(15) = 3.873 → round = 4
-- =====================================================================
DROP TABLE IF EXISTS knn_k_value;
CREATE TABLE knn_k_value AS
SELECT
    donor_pool_count,
    SQRT(1.0 * donor_pool_count) AS sqrt_n,
    CAST(ROUND(SQRT(1.0 * donor_pool_count)) AS INTEGER) AS k
FROM impute_baseline_stats;

SELECT * FROM knn_k_value;

-- =====================================================================
-- STEP 8. 근접이웃 순위 매기기 — ROW_NUMBER(동률 시 customer_id로 결정적
--   타이브레이크)와 RANK(동률을 모두 포함) 두 방식을 함께 기록해 비교한다.
-- =====================================================================
DROP TABLE IF EXISTS ranked_neighbors;
CREATE TABLE ranked_neighbors AS
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
FROM pairwise_distance_final;

-- =====================================================================
-- STEP 9. k=4 최근접이웃 평균으로 대체값 계산 — 두 가지 이웃 선택 방식 비교
--   knn_imputed_strict : ROW_NUMBER <= k (동률이어도 정확히 4명만, customer_id로 결정)
--   knn_imputed_with_ties : RANK <= k (4등이 동률이면 k보다 많은 이웃 모두 포함)
-- =====================================================================
DROP TABLE IF EXISTS knn_imputed_strict;
CREATE TABLE knn_imputed_strict AS
SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_strict,
    COUNT(*) AS neighbors_used
FROM ranked_neighbors rn, knn_k_value k
WHERE rn.rn_tiebreak <= k.k
GROUP BY rn.target_customer_id;

DROP TABLE IF EXISTS knn_imputed_with_ties;
CREATE TABLE knn_imputed_with_ties AS
SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_with_ties,
    COUNT(*) AS neighbors_used
FROM ranked_neighbors rn, knn_k_value k
WHERE rn.rnk_with_ties <= k.k
GROUP BY rn.target_customer_id;

-- =====================================================================
-- STEP 10. 최종 결과 테이블 — 원본, 평균 대체, 중앙값 대체, kNN 대체(두 방식),
--   검증용 정답값을 한 테이블에 모은다.
-- =====================================================================
DROP TABLE IF EXISTS impute_practice_result;
CREATE TABLE impute_practice_result AS
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
FROM impute_practice_raw r
LEFT JOIN knn_imputed_strict s ON s.customer_id = r.customer_id
LEFT JOIN knn_imputed_with_ties w ON w.customer_id = r.customer_id
CROSS JOIN impute_baseline_stats b
ORDER BY r.customer_id;

SELECT * FROM impute_practice_result;
