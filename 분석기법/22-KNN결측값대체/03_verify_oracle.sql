-- kNN 결측값 대체 결과 검산 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
-- 쿼리 로직은 optional/03_verify_sqlite.sql로 이 저장소에서 실제 실행·검증했다.
-- 단순히 "대체 완료"라고 보고하지 않기 위한 11가지 확인 쿼리.

-- 1) 대체 후 남은 NULL이 없는지 확인
SELECT
    SUM(CASE WHEN original_value IS NULL AND knn_imputed_strict IS NULL THEN 1 ELSE 0 END) AS still_missing_count,
    COUNT(*) AS total_rows
FROM impute_practice_result;

-- 2) 원본 결측 5행에 대해서만 mean/median/knn(strict)/knn(with_ties) 나란히 비교
SELECT customer_id, scenario_type, mean_imputed, median_imputed,
       knn_imputed_strict, knn_neighbors_strict,
       knn_imputed_with_ties, knn_neighbors_with_ties,
       true_value_for_check
FROM impute_practice_result
WHERE original_value IS NULL
ORDER BY customer_id;

-- 3) 오차 검증 — C019(near_extreme)의 오차가 유난히 큰 것이 정상이다
--    (진짜 이웃이 1개뿐인 특이 관측치에서는 고정 k=4가 왜곡될 수 있다는,
--    이 실습이 확인해야 할 한계).
SELECT
    customer_id, scenario_type, knn_imputed_strict, true_value_for_check,
    ROUND(knn_imputed_strict - true_value_for_check, 2) AS error_strict,
    ROUND(ABS(knn_imputed_strict - true_value_for_check), 2) AS abs_error_strict,
    ROUND(knn_imputed_with_ties - true_value_for_check, 2) AS error_with_ties,
    ROUND(mean_imputed - true_value_for_check, 2) AS error_overall_mean,
    ROUND(median_imputed - true_value_for_check, 2) AS error_overall_median
FROM impute_practice_result
WHERE true_value_for_check IS NOT NULL
ORDER BY customer_id;

-- 4) RMSE 비교 — kNN(strict) vs 전체 평균 대체 vs 전체 중앙값 대체.
--    "kNN이 항상 더 낫다"고 일반화하면 안 된다 — 이웃이 실제로 가까운
--    조건에서만 kNN이 뚜렷이 유리하다(4-1 참고).
SELECT
    ROUND(SQRT(AVG((knn_imputed_strict - true_value_for_check) * (knn_imputed_strict - true_value_for_check))), 2) AS rmse_knn_strict,
    ROUND(SQRT(AVG((knn_imputed_with_ties - true_value_for_check) * (knn_imputed_with_ties - true_value_for_check))), 2) AS rmse_knn_with_ties,
    ROUND(SQRT(AVG((mean_imputed - true_value_for_check) * (mean_imputed - true_value_for_check))), 2) AS rmse_overall_mean,
    ROUND(SQRT(AVG((median_imputed - true_value_for_check) * (median_imputed - true_value_for_check))), 2) AS rmse_overall_median
FROM impute_practice_result
WHERE true_value_for_check IS NOT NULL;

-- 4-1) C019(near_extreme) 제외 RMSE — "이웃이 충분히 가까운 일반적인 조건"만
--      분리해서 보면 kNN이 평균 대체보다 뚜렷이 낫다.
SELECT
    ROUND(SQRT(AVG((knn_imputed_strict - true_value_for_check) * (knn_imputed_strict - true_value_for_check))), 2) AS rmse_knn_strict_excl_outlier,
    ROUND(SQRT(AVG((mean_imputed - true_value_for_check) * (mean_imputed - true_value_for_check))), 2) AS rmse_overall_mean_excl_outlier
FROM impute_practice_result
WHERE true_value_for_check IS NOT NULL AND scenario_type <> 'near_extreme';

-- 5) 동률(tie) 이웃이 몇 명에게 영향을 줬는지
SELECT customer_id, knn_neighbors_strict, knn_neighbors_with_ties,
       (knn_neighbors_with_ties - knn_neighbors_strict) AS extra_tied_neighbors
FROM impute_practice_result
WHERE original_value IS NULL AND knn_neighbors_strict <> knn_neighbors_with_ties;

-- 6) C018 기준 실제 동률 이웃 원본 데이터 확인(C008/C010/C014가 동일 거리인지)
SELECT donor_customer_id, donor_target_value, ROUND(dist_normalized, 4) AS dist
FROM pairwise_distance_final
WHERE target_customer_id = 'C018'
ORDER BY dist_normalized ASC, donor_customer_id ASC
FETCH FIRST 8 ROWS ONLY;

-- 7) 문자열 컬럼: NULL / '' / ' ' 집계 — Oracle은 null_count와
--    empty_string_count가 사실상 같은 대상(빈 문자열이 곧 NULL)을 가리킨다.
--    SQL Server 버전(03_verify_sqlserver.sql)의 결과와 반드시 대조할 것.
SELECT
    SUM(coupon_is_null) AS null_count,
    SUM(coupon_is_empty_string) AS empty_string_count,
    SUM(coupon_is_whitespace) AS whitespace_count
FROM null_identification;

-- 8) zero_value(C009)가 결측으로 잘못 처리되지 않았는지 확인 — 0은 유효한 값
SELECT r.customer_id, r.frequency, r.monetary, r.target_missing_value,
       CASE WHEN r.target_missing_value IS NULL THEN '결측' ELSE '정상값(0 포함)' END AS status
FROM impute_practice_raw r
WHERE r.customer_id = 'C009';

-- 9) multi_null(C017)이 recency/delivery_days 없이도 dims_used=3으로
--    처리됐는지 확인
SELECT DISTINCT dims_used
FROM pairwise_distance
WHERE target_customer_id = 'C017';

-- 10) 대체 전/후 평균·최소·최대 비교
SELECT
    'before(도너 15행만)' AS stage,
    ROUND(AVG(target_missing_value), 2) AS avg_target,
    ROUND(MIN(target_missing_value), 2) AS min_target,
    ROUND(MAX(target_missing_value), 2) AS max_target
FROM impute_practice_raw WHERE target_missing_value IS NOT NULL
UNION ALL
SELECT
    'after(20행, knn_imputed_strict로 채움)',
    ROUND(AVG(NVL(original_value, knn_imputed_strict)), 2),
    ROUND(MIN(NVL(original_value, knn_imputed_strict)), 2),
    ROUND(MAX(NVL(original_value, knn_imputed_strict)), 2)
FROM impute_practice_result;

-- 11) k값 근거 재확인 — sqrt(15)=3.87..., round=4
SELECT donor_pool_count, ROUND(sqrt_n, 4) AS sqrt_n, k FROM knn_k_value;
