-- kNN 결측값 대체 입력 준비 + 10단계 대체 파이프라인 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
-- 로직은 optional/01_prepare_sqlite.sql로 이 저장소에서 실제 실행·검증한 뒤
-- Oracle 문법으로 옮긴 것이다(수치 결과는 SQLite 실행 결과와 README를 참고).
--
-- 이 테이블은 Olist 원자료(olist_customers_dataset.csv)에서 만든 것이 아니라
-- kNN 결측값 대체·Oracle/SQL Server NULL 문법 차이를 보여주기 위해 새로 만든
-- 별도의 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다.
--
-- *** Oracle 고유 함정: coupon_code_raw에 ''(빈 문자열)를 넣는 INSERT는
-- Oracle에서 그 값을 NULL로 저장한다(Oracle은 ''와 NULL을 구분하지 않는다).
-- 그래서 C005(설계 의도: empty_string 시나리오)는 Oracle에 적재되는 순간부터
-- coupon_code_raw가 NULL이 되어, C003(원래부터 NULL)과 저장소 안에서 구분이
-- 불가능해진다. 이는 버그가 아니라 이 실습이 보여주려는 핵심 차이다 —
-- SQL Server 버전(01_prepare_sqlserver.sql)에서는 C005의 ''가 그대로 ''로
-- 남아 C003의 NULL과 구분된다. ***

DROP TABLE impute_practice_raw;

CREATE TABLE impute_practice_raw (
    customer_id           VARCHAR2(10) PRIMARY KEY,
    recency                NUMBER,
    frequency               NUMBER,
    monetary                NUMBER,
    delivery_days           NUMBER,
    review_score            NUMBER,
    target_missing_value    NUMBER,
    coupon_code_raw         VARCHAR2(20),
    true_value_for_check    NUMBER,
    scenario_type           VARCHAR2(30)
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

COMMIT;

-- C010과 C014는 recency=8, frequency=7, monetary=96, delivery_days=4,
-- review_score=5로 값이 의도적으로 동일하다 — C018 기준 근접이웃 순위에서
-- 동률(tie)이 나오도록 설계했다. target_missing_value는 100/96으로 서로 달라,
-- "동률 이웃이라고 결과도 같지는 않다"는 점을 보여준다.

-- =====================================================================
-- STEP 1. NULL/빈 문자열/공백 식별 (Oracle)
--   coupon_is_null 과 coupon_is_empty_string 이 사실상 같은 결과를 준다는
--   점 자체가 Oracle의 ''=NULL 특성을 보여준다(SQL Server 버전과 대조).
-- =====================================================================
CREATE TABLE null_identification AS
SELECT
    customer_id,
    CASE WHEN recency IS NULL THEN 1 ELSE 0 END AS recency_is_null,
    CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END AS delivery_days_is_null,
    CASE WHEN target_missing_value IS NULL THEN 1 ELSE 0 END AS target_is_null,
    CASE WHEN coupon_code_raw IS NULL THEN 1 ELSE 0 END AS coupon_is_null,
    -- Oracle에서는 이 조건이 항상 FALSE/UNKNOWN이다: ''는 저장되는 순간 NULL이
    -- 되므로 coupon_code_raw = '' 는 "NULL = ''" 와 같아져 결코 TRUE가 될 수 없다.
    CASE WHEN coupon_code_raw = '' THEN 1 ELSE 0 END AS coupon_is_empty_string,
    CASE WHEN coupon_code_raw = ' ' THEN 1 ELSE 0 END AS coupon_is_whitespace,
    -- LENGTH는 공백을 포함해 그대로 길이를 센다(C006 ' ' → 1).
    LENGTH(coupon_code_raw) AS coupon_length
FROM impute_practice_raw;

SELECT SUM(coupon_is_null) AS null_count,
       SUM(coupon_is_empty_string) AS empty_string_count,
       SUM(coupon_is_whitespace) AS whitespace_count
FROM null_identification;

-- =====================================================================
-- STEP 2. NULL 처리 함수 비교 (Oracle: NVL, NVL2, COALESCE, NULLIF, CASE)
-- =====================================================================
SELECT
    customer_id,
    coupon_code_raw,
    NVL(coupon_code_raw, '(NO_COUPON)') AS nvl_result,
    -- NVL2(expr, expr_not_null이면_반환, expr_null이면_반환)
    NVL2(coupon_code_raw, 'HAS_VALUE', 'NO_VALUE') AS nvl2_result,
    COALESCE(coupon_code_raw, '(NO_COUPON)') AS coalesce_result,
    -- Oracle 함정: coupon_code_raw가 이미 NULL이면 NULLIF(x, '')는 비교 대상인
    -- ''도 NULL이라 "NULL = NULL"이 never TRUE가 되어 결과가 항상 원래 expr(NULL)
    -- 그대로다 — NULLIF가 이 컬럼에서는 사실상 아무 의미가 없어진다.
    NULLIF(coupon_code_raw, '') AS nullif_result,
    CASE WHEN coupon_code_raw IS NULL THEN '(NO_COUPON via CASE)' ELSE coupon_code_raw END AS case_result
FROM impute_practice_raw
WHERE scenario_type IN ('complete', 'empty_string', 'whitespace_string')
ORDER BY customer_id
FETCH FIRST 6 ROWS ONLY;

-- =====================================================================
-- STEP 3~4. 단순 대체(전체 평균/중앙값) 베이스라인 — 도너 풀(15행) 기준
--   Oracle은 MEDIAN() 집계함수를 바로 쓸 수 있다(SQL Server에는 없음 —
--   SQL Server 버전은 PERCENTILE_CONT(0.5) WITHIN GROUP(...) OVER()로 대신한다).
-- =====================================================================
CREATE TABLE impute_baseline_stats AS
SELECT
    AVG(target_missing_value) AS overall_mean,
    MEDIAN(target_missing_value) AS overall_median,
    COUNT(*) AS donor_pool_count
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL;

SELECT * FROM impute_baseline_stats;

-- =====================================================================
-- STEP 5. 도너 풀 / 대체 대상 풀 분리
-- =====================================================================
CREATE VIEW donor_pool AS
SELECT * FROM impute_practice_raw WHERE target_missing_value IS NOT NULL;

CREATE VIEW impute_target_pool AS
SELECT * FROM impute_practice_raw WHERE target_missing_value IS NULL;

-- =====================================================================
-- STEP 6. 쌍별(pairwise) 거리 계산
--   대체 대상 쪽에서 NULL인 변수(C017의 recency, delivery_days)는 그 쌍의
--   거리 계산에서 제외한다(공통으로 관측된 변수만 사용).
--   raw_sq_sum: 논문 원래 공식(Σ(X_io-X_jo)^2) 그대로의 제곱합
--   dims_used : 이번 쌍에서 실제로 비교에 쓰인 변수 개수(4 또는 5)
--   dist_normalized: SQRT(raw_sq_sum / dims_used) — 변수 개수가 쌍마다
--     달라질 수 있어(C017), 개수가 다른 쌍끼리도 비교 가능하도록 평균
--     제곱거리의 제곱근을 쓴다.
-- =====================================================================
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

CREATE TABLE pairwise_distance_final AS
SELECT
    target_customer_id,
    donor_customer_id,
    donor_target_value,
    raw_sq_sum,
    dims_used,
    SQRT(raw_sq_sum) AS dist_raw,
    SQRT(raw_sq_sum / dims_used) AS dist_normalized
FROM pairwise_distance;

-- =====================================================================
-- STEP 7. k = ROUND(SQRT(도너 풀 크기)) — Jonsson & Wohlin(2004) 규칙
--   도너 풀 15행 → sqrt(15) = 3.873 → round = 4
-- =====================================================================
CREATE TABLE knn_k_value AS
SELECT
    donor_pool_count,
    SQRT(donor_pool_count) AS sqrt_n,
    ROUND(SQRT(donor_pool_count)) AS k
FROM impute_baseline_stats;

SELECT * FROM knn_k_value;

-- =====================================================================
-- STEP 8. 근접이웃 순위 매기기 — ROW_NUMBER(동률 시 customer_id로 결정적
--   타이브레이크)와 RANK(동률을 모두 포함) 두 방식을 함께 기록해 비교한다.
-- =====================================================================
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
-- =====================================================================
CREATE TABLE knn_imputed_strict AS
SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_strict,
    COUNT(*) AS neighbors_used
FROM ranked_neighbors rn, knn_k_value k
WHERE rn.rn_tiebreak <= k.k
GROUP BY rn.target_customer_id;

CREATE TABLE knn_imputed_with_ties AS
SELECT
    rn.target_customer_id AS customer_id,
    AVG(rn.donor_target_value) AS knn_imputed_with_ties,
    COUNT(*) AS neighbors_used
FROM ranked_neighbors rn, knn_k_value k
WHERE rn.rnk_with_ties <= k.k
GROUP BY rn.target_customer_id;

-- =====================================================================
-- STEP 10. 최종 결과 테이블
-- =====================================================================
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
