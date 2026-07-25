-- SVD·NMF 결과 검산 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

CREATE TABLE svd_singular_values (component VARCHAR(10), singular_value FLOAT, explained_variance_ratio FLOAT);
CREATE TABLE factorization_summary (method VARCHAR(10), k INT, rmse FLOAT);
CREATE TABLE factorization_reconstruction_error (
    method VARCHAR(10), customer_id VARCHAR(32), category VARCHAR(20),
    original_amount FLOAT, reconstructed_amount FLOAT, abs_error FLOAT
);
CREATE TABLE svd_customer_factors (customer_id VARCHAR(32), comp1 FLOAT, comp2 FLOAT, comp3 FLOAT);

SELECT component, ROUND(singular_value, 3) AS singular_value, ROUND(explained_variance_ratio, 4) AS ratio
FROM svd_singular_values
ORDER BY component;

SELECT method, k, ROUND(rmse, 4) AS rmse FROM factorization_summary;

SELECT category, ROUND(original_amount, 1) AS original_amount,
       ROUND(reconstructed_amount, 1) AS reconstructed_amount, ROUND(abs_error, 1) AS abs_error
FROM factorization_reconstruction_error
WHERE method = 'SVD'
  AND customer_id = (SELECT TOP 1 customer_id FROM svd_customer_factors)
ORDER BY category;

SELECT method, category, ROUND(AVG(abs_error), 2) AS avg_abs_error
FROM factorization_reconstruction_error
GROUP BY method, category
ORDER BY method, avg_abs_error DESC;
