-- 교차검증 입력 준비 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요
-- CHECKSUM(expr)은 부호 있는 INT를 반환하므로 ABS()로 음수를 제거한 뒤 % 5를 적용한다
-- (Oracle ORA_HASH는 애초에 0~max_bucket 범위만 반환해 ABS가 필요 없다는 점이 다르다).

IF OBJECT_ID('cv_folds', 'U') IS NOT NULL DROP TABLE cv_folds;
SELECT
    f.customer_id, l.churned, f.satisfaction_score, f.days_since_last_order,
    f.order_count, f.membership_years, f.annual_income_10k,
    (ABS(CHECKSUM(f.customer_id)) % 5) + 1 AS fold
INTO cv_folds
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

SELECT fold, COUNT(*) AS n, SUM(churned) AS n_churned, ROUND(AVG(1.0 * churned), 4) AS churn_rate
FROM cv_folds
GROUP BY fold
ORDER BY fold;
