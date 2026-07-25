-- 하이퍼파라미터 탐색 결과 검산

-- 1) 상위 5개 조합
SELECT combo_id, max_depth, min_samples_leaf, ROUND(mean_accuracy, 4) AS mean_accuracy,
       ROUND(std_accuracy, 4) AS std_accuracy
FROM hp_search_results
ORDER BY mean_accuracy DESC
LIMIT 5;

-- 2) 하위 5개 조합 (과적합/과소적합 조합 확인)
SELECT combo_id, max_depth, min_samples_leaf, ROUND(mean_accuracy, 4) AS mean_accuracy
FROM hp_search_results
ORDER BY mean_accuracy ASC
LIMIT 5;

-- 3) max_depth별 평균 성능 (다른 조건을 통제하지 않은 단순 집계 - 트렌드 확인용)
SELECT max_depth, ROUND(AVG(mean_accuracy), 4) AS avg_across_min_samples_leaf
FROM hp_search_results
GROUP BY max_depth
ORDER BY max_depth;

-- 4) 최고 성능과 최저 성능의 차이 (하이퍼파라미터 선택이 성능에 미치는 영향 크기)
SELECT MAX(mean_accuracy) - MIN(mean_accuracy) AS accuracy_range
FROM hp_search_results;
