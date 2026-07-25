-- SVM 입력 준비: 표준화 + 학습/평가 분할(80/20, ROWID 기반 결정적 분할)

DROP TABLE IF EXISTS svm_input;
CREATE TABLE svm_input AS
SELECT
    f.customer_id,
    l.churned,
    (f.satisfaction_score    - s.m1) / s.sd1 AS satisfaction_z,
    (f.days_since_last_order - s.m2) / s.sd2 AS recency_z,
    (f.order_count           - s.m3) / s.sd3 AS orders_z,
    (f.membership_years      - s.m4) / s.sd4 AS membership_z,
    (f.annual_income_10k     - s.m5) / s.sd5 AS income_z,
    CASE WHEN f.ROWID % 5 = 0 THEN 'test' ELSE 'train' END AS split
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id
CROSS JOIN (
    SELECT
        AVG(satisfaction_score) m1, SQRT(AVG(satisfaction_score*satisfaction_score)-AVG(satisfaction_score)*AVG(satisfaction_score)) sd1,
        AVG(days_since_last_order) m2, SQRT(AVG(days_since_last_order*days_since_last_order)-AVG(days_since_last_order)*AVG(days_since_last_order)) sd2,
        AVG(order_count) m3, SQRT(AVG(order_count*order_count)-AVG(order_count)*AVG(order_count)) sd3,
        AVG(membership_years) m4, SQRT(AVG(membership_years*membership_years)-AVG(membership_years)*AVG(membership_years)) sd4,
        AVG(annual_income_10k) m5, SQRT(AVG(annual_income_10k*annual_income_10k)-AVG(annual_income_10k)*AVG(annual_income_10k)) sd5
    FROM customer_features
) s;

-- 분할 비율 확인
SELECT split, COUNT(*) AS n, SUM(churned) AS n_churned
FROM svm_input
GROUP BY split;
