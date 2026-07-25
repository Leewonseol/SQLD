-- 기본 탐색 (2): 문자열 정제 / 대소문자·공백 정규화 / 지역 코드 형변환
-- 00-데이터사전에서 이미 확인했듯 이 CSV는 사전에 정규화되어 있다.
-- 아래 쿼리는 "지저분한 값을 고치는" 것이 아니라 "정규화되어 있음을 SQL로 증명"하는 것이다.
-- 정규화 함수를 적용해도 값이 바뀌지 않으면(멱등) 이미 정제된 데이터라는 뜻이다.

-- [7] 문자열 정제: TRIM 적용 전/후 city 값이 몇 건이나 달라지는지
SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN customer_city != TRIM(customer_city) THEN 1 ELSE 0 END) AS changed_by_trim
FROM customers_raw;

-- [8] 대소문자·공백 정규화: LOWER + 연속공백 제거(REPLACE 반복) 적용 전/후 비교
SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN customer_city != LOWER(TRIM(customer_city)) THEN 1 ELSE 0 END) AS changed_by_lower_trim,
    SUM(CASE WHEN customer_city LIKE '%  %' THEN 1 ELSE 0 END) AS has_double_space,
    SUM(CASE WHEN customer_state != UPPER(TRIM(customer_state)) THEN 1 ELSE 0 END) AS state_changed_by_upper_trim
FROM customers_raw;

-- [9] 지역 코드(zip) 형변환: 정수 캐스팅이 왜 위험한지 직접 확인
--     선행 0으로 시작하는 zip이 존재한다면, CAST(...AS INTEGER) 후 5자리로 되돌릴 때 정보가 사라진다.
SELECT
    COUNT(*) AS total_zip,
    SUM(CASE WHEN customer_zip_code_prefix LIKE '0%' THEN 1 ELSE 0 END) AS starts_with_zero,
    SUM(CASE WHEN LENGTH(CAST(CAST(customer_zip_code_prefix AS INTEGER) AS TEXT)) != 5 THEN 1 ELSE 0 END) AS digits_lost_after_int_roundtrip
FROM customers_raw;

-- zip은 계속 5자리 텍스트로 유지하는 것이 맞다는 결론을 뒷받침하는 근거 예시 5건
SELECT customer_zip_code_prefix,
       CAST(CAST(customer_zip_code_prefix AS INTEGER) AS TEXT) AS after_int_roundtrip
FROM customers_raw
WHERE customer_zip_code_prefix LIKE '0%'
LIMIT 5;
