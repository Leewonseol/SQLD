-- kNN 결측값 대체 결과 검산 (SQLite 보조 실행) — 이 저장소에서 실제로 실행 확인됨
-- 단순히 "대체 완료"라고 보고하지 않기 위한 11가지 확인 쿼리.

-- 1) 대체 후 target_missing_value에 해당하는 최종 컬럼(knn_imputed_strict)에
--    남은 NULL이 없는지 확인 — 대체 대상 5행 모두 채워졌는지
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

-- 3) 정확도 검증 — 오차(대체값 - 정답값)와 절대오차. C019(near_extreme)의 오차가
--    유난히 크게 나오는 것이 정상이다(4-이웃 고정 kNN이 진짜 이웃이 1개뿐인
--    특이 관측치에서는 왜곡될 수 있다는, 이 논문 기반 실습에서 확인해야 할 한계).
SELECT
    customer_id,
    scenario_type,
    knn_imputed_strict,
    true_value_for_check,
    ROUND(knn_imputed_strict - true_value_for_check, 2) AS error_strict,
    ROUND(ABS(knn_imputed_strict - true_value_for_check), 2) AS abs_error_strict,
    ROUND(knn_imputed_with_ties - true_value_for_check, 2) AS error_with_ties,
    ROUND(mean_imputed - true_value_for_check, 2) AS error_overall_mean,
    ROUND(median_imputed - true_value_for_check, 2) AS error_overall_median
FROM impute_practice_result
WHERE true_value_for_check IS NOT NULL
ORDER BY customer_id;

-- 4) RMSE 비교 — kNN(strict) vs 전체 평균 대체 vs 전체 중앙값 대체.
--    전체 평균은 C012(극단값 95000)에 끌려가 대부분의 "평범한" 행에서 kNN보다
--    나쁘지만, C019(near_extreme)처럼 진짜 이웃이 outlier뿐인 행에서는 고정
--    k=4 kNN이 오히려 무관한 이웃 3명 때문에 왜곡된다 — "kNN이 항상 더
--    낫다"고 일반화하면 안 된다는 점을 수치로 보여준다.
SELECT
    ROUND(SQRT(AVG((knn_imputed_strict - true_value_for_check) * (knn_imputed_strict - true_value_for_check))), 2) AS rmse_knn_strict,
    ROUND(SQRT(AVG((knn_imputed_with_ties - true_value_for_check) * (knn_imputed_with_ties - true_value_for_check))), 2) AS rmse_knn_with_ties,
    ROUND(SQRT(AVG((mean_imputed - true_value_for_check) * (mean_imputed - true_value_for_check))), 2) AS rmse_overall_mean,
    ROUND(SQRT(AVG((median_imputed - true_value_for_check) * (median_imputed - true_value_for_check))), 2) AS rmse_overall_median
FROM impute_practice_result
WHERE true_value_for_check IS NOT NULL;

-- 4-1) C019(near_extreme)를 제외했을 때의 RMSE — "이웃이 충분히 가까운
--      일반적인 조건"에서만 보면 kNN이 평균 대체보다 뚜렷이 낫다는 것을
--      분리해서 보여준다(이상치 자체를 대체할 때는 다른 문제라는 점과 구분).
SELECT
    ROUND(SQRT(AVG((knn_imputed_strict - true_value_for_check) * (knn_imputed_strict - true_value_for_check))), 2) AS rmse_knn_strict_excl_outlier,
    ROUND(SQRT(AVG((mean_imputed - true_value_for_check) * (mean_imputed - true_value_for_check))), 2) AS rmse_overall_mean_excl_outlier
FROM impute_practice_result
WHERE true_value_for_check IS NOT NULL AND scenario_type <> 'near_extreme';

-- 5) 동률(tie) 이웃이 실제로 몇 명에게 영향을 줬는지 — strict와 with_ties의
--    이웃 수가 다른 행 = 4등 자리에서 동률이 발생한 행
SELECT customer_id, knn_neighbors_strict, knn_neighbors_with_ties,
       (knn_neighbors_with_ties - knn_neighbors_strict) AS extra_tied_neighbors
FROM impute_practice_result
WHERE original_value IS NULL AND knn_neighbors_strict <> knn_neighbors_with_ties;

-- 6) C018 기준 실제 동률 이웃 원본 데이터 확인(C008/C010/C014가 동일 거리인지)
SELECT donor_customer_id, donor_target_value, ROUND(dist_normalized, 4) AS dist
FROM pairwise_distance_final
WHERE target_customer_id = 'C018'
ORDER BY dist_normalized ASC, donor_customer_id ASC
LIMIT 8;

-- 7) 문자열 컬럼: NULL / '' / ' ' 세 값의 개수가 서로 다르게 집계되는지 확인
--    (SQLite는 셋을 모두 구분한다 — Oracle은 ''를 IS NULL로 취급해 여기서
--    coupon_is_null과 coupon_is_empty_string이 같아진다는 점이
--    01_prepare_oracle.sql의 동일 쿼리와 달라지는 지점이다)
SELECT
    SUM(coupon_is_null) AS null_count,
    SUM(coupon_is_empty_string) AS empty_string_count,
    SUM(coupon_is_whitespace) AS whitespace_count
FROM null_identification;

-- 8) zero_value(C009)가 결측으로 잘못 처리되지 않았는지 확인 — 0은 유효한 값
--    (0이라면 target_missing_value가 NULL이 아니라 0.0으로 남아 있어야 하고,
--    도너 풀에 포함되어 다른 행의 kNN 대체에도 정상적으로 쓰였어야 한다)
SELECT r.customer_id, r.frequency, r.monetary, r.target_missing_value,
       CASE WHEN r.target_missing_value IS NULL THEN '결측' ELSE '정상값(0 포함)' END AS status
FROM impute_practice_raw r
WHERE r.customer_id = 'C009';

-- 9) multi_null(C017)이 recency/delivery_days 없이도 distance 계산에서
--    제외된 변수 개수(dims_used)가 3(=5-2)으로 처리됐는지 확인
SELECT DISTINCT dims_used
FROM pairwise_distance
WHERE target_customer_id = 'C017';

-- 10) 대체 전/후 평균과 표준편차 비교(대체 대상 5행이 채워지면서
--     전체 target 분포가 어떻게 바뀌는지) — 극단값(C012) 포함 여부로
--     평균이 크게 흔들리는 것을 재확인
SELECT
    'before(도너 15행만)' AS stage,
    ROUND(AVG(target_missing_value), 2) AS avg_target,
    ROUND(MIN(target_missing_value), 2) AS min_target,
    ROUND(MAX(target_missing_value), 2) AS max_target
FROM impute_practice_raw WHERE target_missing_value IS NOT NULL
UNION ALL
SELECT
    'after(20행, knn_imputed_strict로 채움)',
    ROUND(AVG(COALESCE(original_value, knn_imputed_strict)), 2),
    ROUND(MIN(COALESCE(original_value, knn_imputed_strict)), 2),
    ROUND(MAX(COALESCE(original_value, knn_imputed_strict)), 2)
FROM impute_practice_result;

-- 11) k값 근거 재확인 — sqrt(15)=3.87..., round=4
SELECT donor_pool_count, ROUND(sqrt_n, 4) AS sqrt_n, k FROM knn_k_value;
