-- 교차검증 입력 준비: 고객별 fold(1~5) 결정적 배정

DROP TABLE IF EXISTS cv_folds;
CREATE TABLE cv_folds AS
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

-- fold별 표본 수·클래스 비율 (완전한 층화는 아니지만 각 fold 이탈률이 크게 치우치지 않는지 확인)
SELECT fold, COUNT(*) AS n, SUM(churned) AS n_churned, ROUND(AVG(churned), 4) AS churn_rate
FROM cv_folds
GROUP BY fold
ORDER BY fold;
