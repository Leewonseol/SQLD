-- 의사결정나무 입력 준비 (SQL Server) — 실행 상태: 실제 SQL Server 검증 필요

IF OBJECT_ID('tree_input', 'U') IS NOT NULL DROP TABLE tree_input;
SELECT
    f.customer_id, l.churned, f.satisfaction_score, f.days_since_last_order,
    f.order_count, f.membership_years, f.annual_income_10k, f.avg_order_value,
    CASE
        WHEN f.days_since_last_order < 30  THEN '0-30일'
        WHEN f.days_since_last_order < 90  THEN '30-90일'
        WHEN f.days_since_last_order < 180 THEN '90-180일'
        ELSE '180일+'
    END AS recency_bucket,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY f.customer_id) % 5 = 0 THEN 'test' ELSE 'train' END AS split
INTO tree_input
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

-- recency_bucket은 tree_input의 실제 컬럼이므로(별칭이 아니라 값) GROUP BY에 그대로 쓸 수 있다.
SELECT recency_bucket, COUNT(*) AS n, ROUND(AVG(1.0 * churned), 4) AS churn_rate
FROM tree_input
GROUP BY recency_bucket
ORDER BY MIN(days_since_last_order);
