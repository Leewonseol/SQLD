-- Olist 고객 데이터 문자열 정제 검증 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요
-- TRIM은 SQL Server 2017+에서 지원한다. 2016 이하는 LTRIM(RTRIM(x))로 대체해야 한다
-- (Oracle TRIM은 버전 제약 없이 항상 지원 - 이 차이 자체가 하나의 포인트).

SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN customer_city != TRIM(customer_city) THEN 1 ELSE 0 END) AS changed_by_trim,
    SUM(CASE WHEN customer_city != LOWER(customer_city) THEN 1 ELSE 0 END) AS changed_by_lower,
    SUM(CASE WHEN customer_state != UPPER(TRIM(customer_state)) THEN 1 ELSE 0 END) AS state_changed
FROM customers_raw;

-- SQL Server 2016 이하 호환 버전(TRIM 미지원 시)
-- SELECT SUM(CASE WHEN customer_city != LTRIM(RTRIM(customer_city)) THEN 1 ELSE 0 END) AS changed_by_trim
-- FROM customers_raw;
