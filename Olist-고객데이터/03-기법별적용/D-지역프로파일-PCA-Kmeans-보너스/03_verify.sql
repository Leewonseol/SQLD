-- 지역프로파일 PCA·K-means 결과 검산

SELECT * FROM state_pca_variance ORDER BY component;

-- 군집별 주 목록과 원 척도 평균 (실제 state_profile과 조인해 해석)
SELECT
    k.cluster,
    GROUP_CONCAT(k.state, ', ') AS states,
    COUNT(*) AS n_states,
    ROUND(AVG(p.n_customers), 0) AS avg_n_customers,
    ROUND(AVG(p.repeat_rate), 4) AS avg_repeat_rate,
    ROUND(AVG(p.city_hhi), 4) AS avg_city_hhi
FROM state_kmeans_clusters k
JOIN state_profile p ON p.state = k.state
GROUP BY k.cluster
ORDER BY k.cluster;

-- PC1 상/하위 주 (어떤 변수가 PC1을 지배하는지는 02_analyze.py 출력의 components_ 참고)
SELECT state, ROUND(PC1, 3) AS PC1, ROUND(PC2, 3) AS PC2
FROM state_pca_scores
ORDER BY PC1 DESC;
