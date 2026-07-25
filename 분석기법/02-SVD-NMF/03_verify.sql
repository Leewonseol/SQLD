-- SVD·NMF 결과 검산

-- 1) 특이값과 기여율 (k=3까지 대부분의 분산을 설명하는지 확인)
SELECT component, ROUND(singular_value, 3) AS singular_value,
       ROUND(explained_variance_ratio, 4) AS ratio
FROM svd_singular_values
ORDER BY component;

-- 2) 방법별 재구성 RMSE 비교 (NMF는 비음수 제약 때문에 SVD보다 오차가 같거나 클 수 있음)
SELECT method, k, ROUND(rmse, 4) AS rmse
FROM factorization_summary;

-- 3) 특정 고객의 원본 vs 재구성 금액 비교 (SVD 기준)
SELECT category, ROUND(original_amount, 1) AS original_amount,
       ROUND(reconstructed_amount, 1) AS reconstructed_amount,
       ROUND(abs_error, 1) AS abs_error
FROM factorization_reconstruction_error
WHERE method = 'SVD'
  AND customer_id = (SELECT customer_id FROM svd_customer_factors LIMIT 1)
ORDER BY category;

-- 4) 카테고리별 평균 재구성 오차 (어느 카테고리가 잘 근사되는지)
SELECT method, category, ROUND(AVG(abs_error), 2) AS avg_abs_error
FROM factorization_reconstruction_error
GROUP BY method, category
ORDER BY method, avg_abs_error DESC;
