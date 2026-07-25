-- 교차검증 결과 검산

-- 1) fold별 성능
SELECT fold, n_test, ROUND(accuracy, 4) AS accuracy, ROUND(precision, 4) AS precision,
       ROUND(recall, 4) AS recall, ROUND(f1, 4) AS f1
FROM cv_fold_results
ORDER BY fold;

-- 2) Python이 계산한 평균·표준편차
SELECT * FROM cv_summary;

-- 3) SQL로 정확도의 평균·표준편차를 직접 재계산해 대조
--    주의: pandas .std()는 표본표준편차(ddof=1), 아래 SQL 식은 모표준편차(ddof=0)이므로
--    fold 수(5)가 작을 때는 두 값이 미세하게 다를 수 있다 (표본표준편차가 항상 더 크다).
SELECT
    ROUND(AVG(accuracy), 4) AS mean_accuracy_sql,
    ROUND(SQRT(AVG(accuracy*accuracy) - AVG(accuracy)*AVG(accuracy)), 4) AS population_std_accuracy_sql
FROM cv_fold_results;

-- 4) fold 간 성능 편차가 큰지 확인 (편차가 크면 데이터가 fold별로 이질적일 가능성)
SELECT MAX(accuracy) - MIN(accuracy) AS accuracy_range
FROM cv_fold_results;
