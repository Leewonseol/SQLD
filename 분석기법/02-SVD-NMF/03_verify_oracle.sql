-- SVD·NMF 결과 검산 (Oracle) — 실행 상태: 실제 Oracle 검증 필요

CREATE TABLE svd_singular_values (component VARCHAR2(10), singular_value NUMBER, explained_variance_ratio NUMBER);
CREATE TABLE factorization_summary (method VARCHAR2(10), k NUMBER, rmse NUMBER);
CREATE TABLE factorization_reconstruction_error (
    method VARCHAR2(10), customer_id VARCHAR2(32), category VARCHAR2(20),
    original_amount NUMBER, reconstructed_amount NUMBER, abs_error NUMBER
);
CREATE TABLE svd_customer_factors (customer_id VARCHAR2(32), comp1 NUMBER, comp2 NUMBER, comp3 NUMBER);

SELECT component, ROUND(singular_value, 3) AS singular_value, ROUND(explained_variance_ratio, 4) AS ratio
FROM svd_singular_values
ORDER BY component;

SELECT method, k, ROUND(rmse, 4) AS rmse FROM factorization_summary;

SELECT category, ROUND(original_amount, 1) AS original_amount,
       ROUND(reconstructed_amount, 1) AS reconstructed_amount, ROUND(abs_error, 1) AS abs_error
FROM factorization_reconstruction_error
WHERE method = 'SVD'
  AND customer_id = (SELECT customer_id FROM svd_customer_factors FETCH FIRST 1 ROWS ONLY)
ORDER BY category;

SELECT method, category, ROUND(AVG(abs_error), 2) AS avg_abs_error
FROM factorization_reconstruction_error
GROUP BY method, category
ORDER BY method, avg_abs_error DESC;
