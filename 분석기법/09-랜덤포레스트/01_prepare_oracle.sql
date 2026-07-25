-- 랜덤포레스트 입력 준비 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요
-- 주의: Oracle의 ROWID는 물리 주소 문자열이라 MOD(ROWID,5) 같은 산술이 불가능하다
-- (SQLite ROWID는 단순 정수라 산술이 됐지만 Oracle은 그렇지 않다) - 대신
-- ROW_NUMBER() OVER(ORDER BY customer_id)로 결정적 순번을 만들어 분할한다.

DROP TABLE rf_input;
CREATE TABLE rf_input AS
SELECT
    f.customer_id,
    l.churned,
    f.satisfaction_score,
    f.days_since_last_order,
    f.order_count,
    f.membership_years,
    f.annual_income_10k,
    f.avg_order_value,
    f.age,
    CASE
        WHEN f.avg_order_value < 10 THEN '저액'
        WHEN f.avg_order_value < 20 THEN '중액'
        ELSE '고액'
    END AS aov_bucket,
    CASE WHEN MOD(ROW_NUMBER() OVER (ORDER BY f.customer_id), 5) = 0 THEN 'test' ELSE 'train' END AS split
FROM customer_features f
JOIN customer_labels l ON l.customer_id = f.customer_id;

SELECT aov_bucket, COUNT(*) AS n, ROUND(AVG(churned), 4) AS churn_rate
FROM rf_input
GROUP BY aov_bucket;
