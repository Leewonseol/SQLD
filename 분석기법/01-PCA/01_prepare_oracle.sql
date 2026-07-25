-- PCA 입력 준비 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
--
-- customer_features 적재: 이 저장소가 만든 합성 고객 데이터(_data/build_db.py,
-- customer_id 1,000명 x 7개 수치형 특성)를 CSV로 내보낸 뒤 SQL*Loader로 적재한다고
-- 가정한다(적재 자체는 문법 예시일 뿐 이 세션에서 실행하지 않음).

CREATE TABLE customer_features (
    customer_id             VARCHAR2(32),
    age                     NUMBER,
    annual_income_10k       NUMBER,
    membership_years        NUMBER,
    order_count             NUMBER,
    avg_order_value         NUMBER,
    days_since_last_order   NUMBER,
    satisfaction_score      NUMBER
);
-- SQL*Loader 예시: sqlldr control=customer_features.ctl (FIELDS TERMINATED BY ',')

-- 결측치 처리 예시(이 합성 데이터에는 결측이 없지만, 결측이 있는 실기 문제라면):
--   NVL(age, (SELECT AVG(age) FROM customer_features WHERE age IS NOT NULL))
-- 처럼 컬럼별 평균으로 대체한 뒤 표준화한다.

-- 표준화: Oracle은 STDDEV_POP을 파티션 없는 윈도우 함수로 바로 쓸 수 있어
-- SQLite 버전(optional/01_prepare_sqlite.sql)의 CROSS JOIN 서브쿼리가 필요 없다.
DROP TABLE pca_input;

CREATE TABLE pca_input AS
SELECT
    customer_id,
    (age                   - AVG(age) OVER())                   / STDDEV_POP(age) OVER()                   AS age_z,
    (annual_income_10k     - AVG(annual_income_10k) OVER())      / STDDEV_POP(annual_income_10k) OVER()      AS income_z,
    (membership_years      - AVG(membership_years) OVER())       / STDDEV_POP(membership_years) OVER()       AS membership_z,
    (order_count           - AVG(order_count) OVER())            / STDDEV_POP(order_count) OVER()            AS orders_z,
    (avg_order_value       - AVG(avg_order_value) OVER())        / STDDEV_POP(avg_order_value) OVER()        AS aov_z,
    (days_since_last_order - AVG(days_since_last_order) OVER())  / STDDEV_POP(days_since_last_order) OVER()  AS recency_z,
    (satisfaction_score    - AVG(satisfaction_score) OVER())     / STDDEV_POP(satisfaction_score) OVER()     AS satisfaction_z
FROM customer_features;

-- 표준화 검산: 평균 0, 분산 1
SELECT ROUND(AVG(age_z), 4) AS mean_age_z, ROUND(AVG(age_z*age_z), 4) AS var_age_z, COUNT(*) AS n
FROM pca_input;
