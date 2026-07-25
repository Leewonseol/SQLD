-- 문제07: 문자열·날짜·상위N행·NULL 문법 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)

IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;

CREATE TABLE customers (
    last_name   VARCHAR(5),
    first_name  VARCHAR(5),
    signup_date DATE,
    phone       VARCHAR(20)
);

INSERT INTO customers (last_name, first_name, signup_date, phone) VALUES
    ('김','민준','2024-03-15','010-1111-2222'),
    ('이','서연','2024-07-01', NULL),
    ('박','도윤','2023-11-20','010-3333-4444'),
    ('최','하은','2025-01-10', NULL),
    ('정','지호','2024-05-05','010-5555-6666');

-- (1) 문자열 결합: + (NULL 전파 주의, 이 쿼리는 last_name/first_name이 NULL이 아니므로
--     안전. phone처럼 NULL이 섞이는 컬럼은 결합 전 ISNULL로 방어해야 한다)
-- (2) 날짜 차이: DATEDIFF(day, ...) / (3) NULL 처리: ISNULL / (4) 상위 3행: TOP
SELECT TOP 3
       last_name + first_name AS full_name,
       signup_date,
       DATEDIFF(day, signup_date, '2025-06-01') AS days_since_signup,
       ISNULL(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC;

-- OFFSET...FETCH 버전(표준 SQL에 더 가까운 최신 문법)
SELECT last_name + first_name AS full_name,
       signup_date,
       DATEDIFF(day, signup_date, '2025-06-01') AS days_since_signup,
       ISNULL(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- NULL 함정: SQL Server는 ''과 NULL을 구분한다 - Oracle과 정반대 결과가 나온다.
INSERT INTO customers (last_name, first_name, signup_date, phone) VALUES
    ('강','서준','2024-09-09','');
SELECT phone, phone IS NULL AS is_actually_null
FROM customers
WHERE last_name = '강';
-- 예상: phone은 빈 문자열 ''로 저장되고, IS NULL 조건은 FALSE(0)가 나온다
-- (Oracle의 oracle.sql에서는 같은 코드가 TRUE(1)이 나온다 - 정반대 결과).
