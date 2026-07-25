-- 의사결정나무 입력 준비 (Oracle) — 실행 상태: 실제 Oracle 검증 필요
-- ROWID 산술 불가 문제(09-랜덤포레스트 참고)로 ROW_NUMBER() OVER(...)를 분할 키로 쓴다.

DROP TABLE tree_input;
CREATE TABLE tree_input AS
SELECT
    f.customer_id, l.churned, f.satisfaction_score, f.days_since_last_order,
    f.order_count, f.membership_years, f.annual_income_10k, f.avg_order_value,
    CASE
        WHEN f.days_since_last_order < 30  THEN '0-30일'
        WHEN f.days_since_last_order < 90  THEN '30-90일'
        WHEN f.days_since_last_order < 180 THEN '90-180일'
        ELSE '180일+'
    END AS recency_bucket,
    CASE WHEN MOD(ROW_NUMBER() OVER (ORDER BY f.customer_id), 5) = 0 THEN 'test' ELSE 'train' END AS split
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

-- 주의: GROUP BY에 별칭(recency_bucket) 대신 컬럼을 그대로 쓴다 — tree_input에 이미
-- recency_bucket 컬럼이 저장되어 있으므로(CASE 표현식이 아니라 값 자체) 별칭 문제가
-- 아니라 일반 컬럼 GROUP BY이며 Oracle/SQL Server에서도 문제없이 동작한다.
SELECT recency_bucket, COUNT(*) AS n, ROUND(AVG(churned), 4) AS churn_rate
FROM tree_input
GROUP BY recency_bucket
ORDER BY MIN(days_since_last_order);
