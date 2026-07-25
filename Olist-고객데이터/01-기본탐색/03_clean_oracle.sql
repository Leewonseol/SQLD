-- Olist 고객 데이터 문자열 정제 검증 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요
-- 00-데이터사전에서 이미 확인했듯 이 CSV는 사전 정규화되어 있다 - 아래 쿼리는
-- "고치는" 것이 아니라 "이미 정규화됨을 증명"하는 것이다(멱등 함수 적용 전후 비교).

SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN customer_city != TRIM(customer_city) THEN 1 ELSE 0 END) AS changed_by_trim,
    SUM(CASE WHEN customer_city != LOWER(customer_city) THEN 1 ELSE 0 END) AS changed_by_lower,
    SUM(CASE WHEN customer_state != UPPER(TRIM(customer_state)) THEN 1 ELSE 0 END) AS state_changed
FROM customers_raw;
