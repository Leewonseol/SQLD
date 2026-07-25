-- 의사결정나무 입력 준비: 원 척도 특성 + 파생 구간변수 + train/test 분할
-- 트리 기반 모델은 스케일링이 필요 없으므로 표준화 없이 원값을 그대로 사용한다.

DROP TABLE IF EXISTS tree_input;
CREATE TABLE tree_input AS
SELECT
    f.customer_id,
    l.churned,
    f.satisfaction_score,
    f.days_since_last_order,
    f.order_count,
    f.membership_years,
    f.annual_income_10k,
    f.avg_order_value,
    CASE
        WHEN f.days_since_last_order < 30  THEN '0-30일'
        WHEN f.days_since_last_order < 90  THEN '30-90일'
        WHEN f.days_since_last_order < 180 THEN '90-180일'
        ELSE '180일+'
    END AS recency_bucket,
    CASE WHEN f.ROWID % 5 = 0 THEN 'test' ELSE 'train' END AS split
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

-- recency_bucket별 실제 이탈률 (SQL만으로 확인 가능한 1차 탐색 -> 트리도 비슷한 분할을 찾는지 검증용)
SELECT recency_bucket, COUNT(*) AS n, ROUND(AVG(churned), 4) AS churn_rate
FROM tree_input
GROUP BY recency_bucket
ORDER BY MIN(days_since_last_order);
