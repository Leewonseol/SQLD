-- 12. 평균·중앙값 대치 — 정답 및 해설

-- Q1 정답: ②
-- 해설: 도너 풀에 C012(target=95000)라는 값의 자릿수 자체가 다른 극단값이
-- 있어, 전체 평균(6415.8)이 나머지 값들(수십~수백대)과 동떨어진 값이
-- 된다. 중앙값(96)은 순위 중간값이라 극단값 하나의 영향을 거의 받지
-- 않는다(STEP 3에서 극단값 제외 시 평균은 98.6% 변했지만 중앙값은
-- 5.7%만 변한 것으로 확인됨).

-- Q2 정답: ①
-- 해설: C009의 target_missing_value=0은 NULL이 아니라 실제로 관측된
-- 정상값이다(scenario_type='zero_value'). 평균/중앙값 계산은 이미
-- WHERE target_missing_value IS NOT NULL 조건으로 도너 풀만 쓰므로
-- C009는 계산에 포함되지만(정상), 이를 "결측이라 채워야 할 값"으로
-- 잘못 판단하면 안 된다는 것이 핵심.

-- Q3 정답 (Oracle 기준)
SELECT
    AVG(target_missing_value) AS mean_without_outlier,
    MEDIAN(target_missing_value) AS median_without_outlier
FROM impute_practice_raw
WHERE target_missing_value IS NOT NULL
  AND scenario_type <> 'extreme_value';
-- 결과: mean_without_outlier ≈ 88.36, median_without_outlier = 90.5
-- (SQL Server라면 MEDIAN() 대신 PERCENTILE_CONT(0.5) WITHIN GROUP
-- (ORDER BY target_missing_value)를 서브쿼리나 OVER()로 써야 한다 — 05절 참고)

-- Q4 정답
SELECT customer_id, error_mean, error_median,
       ABS(error_mean) AS abs_error_mean, ABS(error_median) AS abs_error_median
FROM mean_median_impute_result
WHERE ABS(error_mean) > ABS(error_median)
ORDER BY customer_id;
-- 결과: C016, C017, C018, C020 (4행) — C019(near_extreme)만 예외로, 이
-- 행은 정답값 자체가 94000이라는 극단값이라 오히려 평균 대치(6415.8)의
-- 오차(87584.2)가 중앙값 대치(96)의 오차(93904)보다 작다. "중앙값이 항상
-- 더 정확하다"고 일반화하면 안 된다는 것을 보여주는 반례.
