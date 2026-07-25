-- PCA 결과 검산

-- 1) 성분별 고유값·기여율·누적기여율 (Kaiser 기준: eigenvalue > 1)
SELECT component, ROUND(eigenvalue, 4) AS eigenvalue,
       ROUND(explained_variance_ratio, 4) AS ratio,
       ROUND(cumulative_ratio, 4) AS cum_ratio,
       CASE WHEN eigenvalue > 1 THEN 'Y' ELSE 'N' END AS kaiser_keep
FROM pca_variance
ORDER BY component;

-- 2) PC1에 가장 큰 적재량을 가진 변수 확인
SELECT feature, ROUND(loading, 4) AS loading
FROM pca_loadings
WHERE component = 'PC1'
ORDER BY ABS(loading) DESC;

-- 3) 원본 고객 수와 성분점수 테이블 행 수 일치 검산
SELECT
    (SELECT COUNT(*) FROM customer_features) AS n_customers,
    (SELECT COUNT(*) FROM pca_scores)        AS n_scores;

-- 4) PC1 점수 상위 5명 / 하위 5명 고객 (원본 특성과 함께 조회)
SELECT s.customer_id, ROUND(s.PC1, 3) AS pc1, f.annual_income_10k, f.avg_order_value
FROM pca_scores s
JOIN customer_features f ON f.customer_id = s.customer_id
ORDER BY s.PC1 DESC
LIMIT 5;
