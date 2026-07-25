-- 하이퍼파라미터 탐색 입력 준비: 후보 그리드 + 5-fold 배정

DROP TABLE IF EXISTS hp_grid;
CREATE TABLE hp_grid AS
SELECT
    ROW_NUMBER() OVER (ORDER BY d.max_depth, m.min_samples_leaf) AS combo_id,
    d.max_depth,
    m.min_samples_leaf
FROM (SELECT 2 AS max_depth UNION ALL SELECT 4 UNION ALL SELECT 6 UNION ALL SELECT 8) d
CROSS JOIN (SELECT 5 AS min_samples_leaf UNION ALL SELECT 20 UNION ALL SELECT 50) m;

DROP TABLE IF EXISTS hp_folds;
CREATE TABLE hp_folds AS
SELECT
    f.customer_id,
    l.churned,
    f.satisfaction_score,
    f.days_since_last_order,
    f.order_count,
    f.membership_years,
    f.annual_income_10k,
    (f.ROWID % 5) + 1 AS fold
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

SELECT COUNT(*) AS n_combinations FROM hp_grid;
