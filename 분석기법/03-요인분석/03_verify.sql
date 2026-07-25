-- 요인분석 결과 검산

-- 1) 문항 간 상관관계: {q1,q2}(품질군), {q3,q4}(서비스군)가 서로 강한 상관을 보이는지 확인
SELECT item1, item2, ROUND(correlation, 3) AS correlation
FROM survey_correlation_matrix
WHERE item1 < item2
ORDER BY correlation DESC
LIMIT 10;

-- 2) 요인별 적재량 상위 문항 (|loading| >= 0.4 를 유의미로 판단)
SELECT factor, item, ROUND(loading, 3) AS loading
FROM fa_loadings
WHERE ABS(loading) >= 0.4
ORDER BY factor, ABS(loading) DESC;

-- 3) 요인점수 분포 요약
SELECT
    ROUND(AVG(Factor1), 3) AS mean_f1, ROUND(AVG(Factor2), 3) AS mean_f2,
    COUNT(*) AS n
FROM fa_scores;

-- 4) 고유요인(오차) 분산이 큰 문항 확인 (공통요인으로 설명되지 않는 부분이 큰 문항)
SELECT item, ROUND(noise_variance, 3) AS noise_variance
FROM fa_noise_variance
ORDER BY noise_variance DESC;
