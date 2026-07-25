-- 12-평균-중앙값대치 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요(이 세션에는 Oracle 실행 환경이 없음).
-- 아래 impute_practice_raw 테이블은 분석기법/22-KNN결측값대체/01_prepare_oracle.sql
-- 에서 정의한 것과 완전히 같은 테이블을 그대로 재사용한다(새로 만든 데이터가
-- 아니다). 이 세션에서는 22-KNN결측값대체/optional/01_prepare_sqlite.sql로
-- 같은 로직을 SQLite로 실제 실행·검증했고, 그 결과 수치를 아래 STEP들이
-- 그대로 인용한다(README "12. 실제 실행 검증 여부" 참고).
--
-- Olist 원자료(olist_customers_dataset.csv)에는 실제 결측이 없다 — 이 표는
-- Olist와 무관한, kNN·평균·중앙값 대치 실습을 위한 별도의 작은 합성 데이터다.

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

-- =====================================================================
-- STEP 1. 결측 식별 — target_missing_value가 NULL인 5행(C016~C020)이
--   이번 대치 대상이다. C009(frequency=0, monetary=0, target=0)는 결측이
--   아니라 정상적인 0값이라는 것을 NVL/CASE로 구분해서 확인한다(04 폴더
--   "COUNT(*)와 COUNT(col)"과 같은 원리).
-- =====================================================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(target_missing_value) AS observed_rows,
    COUNT(*) - COUNT(target_missing_value) AS missing_rows
FROM impute_practice_raw;
-- 예상: total_rows=20, observed_rows=15, missing_rows=5

SELECT customer_id, frequency, monetary, target_missing_value,
       CASE WHEN target_missing_value IS NULL THEN '결측' ELSE '정상값(0 포함)' END AS status
FROM impute_practice_raw
WHERE customer_id = 'C009';
-- C009는 target_missing_value=0으로 "정상값"이지 결측이 아니다.

-- =====================================================================
-- STEP 2. 전체 평균/중앙값 계산 — 도너 풀(target 관측된 15행) 기준
--   Oracle은 MEDIAN() 집계함수를 바로 쓸 수 있다.
-- =====================================================================
CREATE TABLE impute_baseline_stats AS
SELECT
    AVG(target_missing_value) AS overall_mean,
    MEDIAN(target_missing_value) AS overall_median,
    COUNT(*) AS donor_pool_count
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL;

SELECT * FROM impute_baseline_stats;
-- 예상: overall_mean=6415.8, overall_median=96, donor_pool_count=15

-- =====================================================================
-- STEP 3. 평균/중앙값이 극단값(C012=95000)에 얼마나 민감한지 직접 비교
--   — "평균은 극단값에 민감, 중앙값은 상대적으로 안정적"이라는 통계 원칙을
--   숫자로 확인한다(빅분기 기술통계 연결).
-- =====================================================================
SELECT
    AVG(target_missing_value) AS mean_with_outlier,
    MEDIAN(target_missing_value) AS median_with_outlier
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL;
-- 예상: mean_with_outlier=6415.8, median_with_outlier=96

SELECT
    AVG(target_missing_value) AS mean_without_outlier,
    MEDIAN(target_missing_value) AS median_without_outlier
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL AND scenario_type <> 'extreme_value';
-- 예상: mean_without_outlier≈88.36(6415.8→88.36, 소수점 이하 다수), median_without_outlier=90.5
-- 평균은 C012 하나 빼자 6415.8→88.36로 폭락했지만, 중앙값은 96→90.5로 거의
-- 그대로다 — 평균이 극단값 하나에 얼마나 크게 흔들리는지 보여주는 핵심 증거.

-- =====================================================================
-- STEP 4. NVL/COALESCE로 즉석 대치(원본은 바꾸지 않고 SELECT에서만 채움)
--   vs 실제 컬럼 값을 바꾸는 UPDATE 방식 비교.
-- =====================================================================
SELECT customer_id, target_missing_value,
       NVL(target_missing_value, (SELECT overall_mean FROM impute_baseline_stats)) AS mean_imputed_inline,
       COALESCE(target_missing_value, (SELECT overall_median FROM impute_baseline_stats)) AS median_imputed_inline
FROM impute_practice_raw
WHERE target_missing_value IS NULL
ORDER BY customer_id;

-- =====================================================================
-- STEP 5. 최종 결과 테이블 — 원본/평균대체/중앙값대체/정답값을 나란히 비교
--   (kNN 대체 컬럼은 13-kNN결측값대체 폴더가 담당 — 여기서는 만들지 않는다)
-- =====================================================================
CREATE TABLE mean_median_impute_result AS
SELECT
    r.customer_id,
    r.scenario_type,
    r.target_missing_value AS original_value,
    b.overall_mean AS mean_imputed,
    b.overall_median AS median_imputed,
    r.true_value_for_check,
    ROUND(b.overall_mean - r.true_value_for_check, 2) AS error_mean,
    ROUND(b.overall_median - r.true_value_for_check, 2) AS error_median
FROM impute_practice_raw r
CROSS JOIN impute_baseline_stats b
WHERE r.target_missing_value IS NULL
ORDER BY r.customer_id;

SELECT * FROM mean_median_impute_result;

-- =====================================================================
-- STEP 6. RMSE 비교(평균 대체 vs 중앙값 대체) — 13 폴더의 kNN RMSE와
--   나란히 비교하기 위한 기준값.
-- =====================================================================
SELECT
    ROUND(SQRT(AVG((mean_imputed - true_value_for_check) * (mean_imputed - true_value_for_check))), 2) AS rmse_mean,
    ROUND(SQRT(AVG((median_imputed - true_value_for_check) * (median_imputed - true_value_for_check))), 2) AS rmse_median
FROM mean_median_impute_result;
-- 예상: rmse_mean=39576.11, rmse_median=41995.17 (22-KNN결측값대체 README와
-- 동일 — 같은 테이블, 같은 계산이므로 값도 같아야 한다)
