-- 교차검증 입력 준비 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- ORA_HASH(expr, max_bucket)은 0~max_bucket 범위의 해시값을 직접 반환한다
-- (SQLite는 이런 해시함수가 없어 ROWID % 5로 대체했었다).

DROP TABLE cv_folds;
CREATE TABLE cv_folds AS
SELECT
    f.customer_id, l.churned, f.satisfaction_score, f.days_since_last_order,
    f.order_count, f.membership_years, f.annual_income_10k,
    ORA_HASH(f.customer_id, 4) + 1 AS fold   -- 0~4 -> 1~5
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

SELECT fold, COUNT(*) AS n, SUM(churned) AS n_churned, ROUND(AVG(churned), 4) AS churn_rate
FROM cv_folds
GROUP BY fold
ORDER BY fold;
