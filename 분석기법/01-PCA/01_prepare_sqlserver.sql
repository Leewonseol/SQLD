-- PCA 입력 준비 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
--
-- customer_features 적재: Oracle 버전과 같은 합성 데이터를 BULK INSERT로 적재한다고
-- 가정한다(적재 자체는 문법 예시일 뿐 이 세션에서 실행하지 않음).

CREATE TABLE customer_features (
    customer_id             VARCHAR(32),
    age                     FLOAT,
    annual_income_10k       FLOAT,
    membership_years        FLOAT,
    order_count             FLOAT,
    avg_order_value         FLOAT,
    days_since_last_order   FLOAT,
    satisfaction_score      FLOAT
);
-- BULK INSERT customer_features FROM 'customer_features.csv'
--   WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n');

-- 결측치 처리 예시(이 합성 데이터에는 결측이 없지만, 결측이 있는 실기 문제라면):
--   ISNULL(age, (SELECT AVG(age) FROM customer_features WHERE age IS NOT NULL))

-- 표준화: SQL Server도 STDEVP를 파티션 없는 윈도우 함수로 바로 쓸 수 있다
-- (Oracle의 STDDEV_POP OVER()와 동일한 패턴, 함수 이름만 다름).
IF OBJECT_ID('pca_input', 'U') IS NOT NULL DROP TABLE pca_input;

SELECT
    customer_id,
    (age                   - AVG(age) OVER())                   / STDEVP(age) OVER()                   AS age_z,
    (annual_income_10k     - AVG(annual_income_10k) OVER())      / STDEVP(annual_income_10k) OVER()      AS income_z,
    (membership_years      - AVG(membership_years) OVER())       / STDEVP(membership_years) OVER()       AS membership_z,
    (order_count           - AVG(order_count) OVER())            / STDEVP(order_count) OVER()            AS orders_z,
    (avg_order_value       - AVG(avg_order_value) OVER())        / STDEVP(avg_order_value) OVER()        AS aov_z,
    (days_since_last_order - AVG(days_since_last_order) OVER())  / STDEVP(days_since_last_order) OVER()  AS recency_z,
    (satisfaction_score    - AVG(satisfaction_score) OVER())     / STDEVP(satisfaction_score) OVER()     AS satisfaction_z
INTO pca_input
FROM customer_features;

-- 표준화 검산: 평균 0, 분산 1 (COUNT(*)는 INT지만 AVG 결과는 FLOAT이라 정수 나눗셈 문제 없음)
SELECT ROUND(AVG(age_z), 4) AS mean_age_z, ROUND(AVG(age_z*age_z), 4) AS var_age_z, COUNT(*) AS n
FROM pca_input;
