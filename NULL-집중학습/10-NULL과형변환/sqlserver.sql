-- 10-NULL과형변환: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (SQL Server)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다.
--
-- *** SQL Server 대조 포인트: nickname에 넣은 ''(빈 문자열)는 SQL Server에서
-- NULL로 바뀌지 않고 그대로 ''로 저장된다(Oracle과 정반대). ***
-- =====================================================================

IF OBJECT_ID('null_lab_customer', 'U') IS NOT NULL DROP TABLE null_lab_customer;

CREATE TABLE null_lab_customer (
    customer_id      INT           PRIMARY KEY,
    customer_name    VARCHAR(20)   NOT NULL,
    nickname         VARCHAR(20)   NULL,
    age              INT           NULL,
    membership_code  VARCHAR(5)    NULL,
    score            INT           NULL,
    purchase_amt     DECIMAL(10,2) NULL,
    order_qty        INT           NULL,
    discount_qty     INT           NULL,
    dept_code        VARCHAR(5)    NULL,
    join_date        DATE          NULL
);

INSERT INTO null_lab_customer VALUES (1, '김민준', '민준', 28,   'A001', 85,  120000, 10, 2,    'D01', '2024-01-10');
INSERT INTO null_lab_customer VALUES (2, '이서연', NULL,  34,   'A002', 92,  98000,  5,  0,    'D02', '2024-02-15');
INSERT INTO null_lab_customer VALUES (3, '박지훈', '',    41,   'A003', NULL,150000, 8,  4,    'D03', NULL);
INSERT INTO null_lab_customer VALUES (4, '최유진', ' ',   0,    'A004', 77,  0,      3,  1,    NULL,  '2024-03-05');
INSERT INTO null_lab_customer VALUES (5, '정하은', '하은',NULL, '0',   60,  NULL,   6,  2,    'D01', '2024-01-22');
INSERT INTO null_lab_customer VALUES (6, '강도현', '도현',29,   'A006', 0,   45000,  0,  3,    'D02', '2024-04-11');
INSERT INTO null_lab_customer VALUES (7, '윤서준', '서준',33,   'A007', 88,  76000,  4,  NULL, 'D03', '2024-05-02');
INSERT INTO null_lab_customer VALUES (8, '임수아', NULL,  45,   'A008', 95,  210000, 12, 5,    'D99', '2024-06-19');
INSERT INTO null_lab_customer VALUES (9, '한지민', '지민',26,   'A009', NULL,89000,  7,  2,    'D01', '2024-07-08');
INSERT INTO null_lab_customer VALUES (10,'오세훈', '세훈',38,   'A010', 70,  132000, 9,  3,    NULL,  '2024-08-14');
INSERT INTO null_lab_customer VALUES (11,'배수지', '수지',31,   'A011', 82,  NULL,   5,  2,    'D02', NULL);
INSERT INTO null_lab_customer VALUES (12,'조현우', '현우',50,   'A012', 99,  300000, 15, 5,    'D03', '2024-09-30');

IF OBJECT_ID('null_lab_dept', 'U') IS NOT NULL DROP TABLE null_lab_dept;

CREATE TABLE null_lab_dept (
    dept_code  VARCHAR(5) PRIMARY KEY,
    dept_name  VARCHAR(20)
);

INSERT INTO null_lab_dept VALUES ('D01', '총무팀');
INSERT INTO null_lab_dept VALUES ('D02', '영업팀');
INSERT INTO null_lab_dept VALUES ('D03', '개발팀');
-- customer_id=8(dept_code='D99'), 4·10(dept_code=NULL)은 null_lab_dept에
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더).

IF OBJECT_ID('null_lab_excluded_codes', 'U') IS NOT NULL DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 쓰지 않음).

-- =====================================================================
-- STEP 1. CAST(NULL AS 자료형)은 여전히 NULL
-- =====================================================================
SELECT CAST(NULL AS INT)         AS cast_null_int,
       CAST(NULL AS VARCHAR(10)) AS cast_null_varchar,
       CAST(NULL AS DATE)        AS cast_null_date;
-- 예상: 세 컬럼 모두 NULL

-- =====================================================================
-- STEP 2. CONVERT / CAST / TRY_CONVERT / TRY_CAST에 NULL을 입력해도
--   결과는 NULL. TRY_CONVERT/TRY_CAST는 SQL Server 2012+ 전용 함수다.
-- =====================================================================
SELECT CONVERT(VARCHAR(10), NULL) AS convert_null,
       CAST(NULL AS INT)          AS cast_null,
       TRY_CONVERT(INT, NULL)     AS try_convert_null,
       TRY_CAST(NULL AS INT)      AS try_cast_null;
-- 예상: 네 컬럼 모두 NULL(에러가 아니다)

-- =====================================================================
-- STEP 3. 자료형이 섞인 membership_code(VARCHAR)를 숫자로 변환 시도
--   membership_code는 customer_id=5만 '0'(숫자로 변환 가능), 나머지는
--   'A001' 형태의 문자열(숫자로 변환 불가능)이다.
-- =====================================================================

-- 3-1. 정상 변환: '0' → 0
SELECT customer_id, membership_code, CAST(membership_code AS INT) AS converted
FROM null_lab_customer
WHERE customer_id = 5;
-- 예상: converted = 0

-- 3-2. 비정상 변환 시도 — 아래 문장은 실행하면
-- "Conversion failed when converting the varchar value 'A001' to data
-- type int." 에러가 발생한다(의도된 데모). CAST와 CONVERT 둘 다 에러가
-- 난다 — TRY_CAST/TRY_CONVERT가 아니면 SQL Server도 Oracle처럼 그대로
-- 에러를 낸다는 것을 보여준다.
SELECT customer_id, membership_code, CAST(membership_code AS INT) AS converted
FROM null_lab_customer
WHERE customer_id = 1;
-- 예상: 변환 에러 발생(정상 동작, 버그 아님)

-- 3-3. 안전한 변환 — TRY_CAST / TRY_CONVERT(SQL Server 2012+ 전용).
-- 변환에 실패하면 에러 대신 NULL을 반환한다. Oracle에는 TRY_CAST가 없어
-- TO_NUMBER(... DEFAULT NULL ON CONVERSION ERROR)(12c+)로 유사하게
-- 흉내낸다(oracle.sql STEP 3-3 참고).
SELECT customer_id, membership_code,
       TRY_CAST(membership_code AS INT)    AS safe_converted_try_cast,
       TRY_CONVERT(INT, membership_code)   AS safe_converted_try_convert
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=5만 0, 나머지 11행은 모두 NULL(에러 대신 NULL 반환)

-- =====================================================================
-- STEP 4. join_date(DATE, NULL 포함)를 문자열로 변환 — NULL은 그대로 NULL
--   join_date가 NULL인 행은 customer_id 3, 11. 문자열로 변환해도 진짜
--   문자열 "NULL"이 되는 게 아니라 SQL NULL 그대로 남는다.
-- =====================================================================
SELECT customer_id, join_date,
       CONVERT(VARCHAR(10), join_date, 120) AS join_date_str
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id 3, 11의 join_date_str은 SQL NULL(빈 값)이지 문자열
-- "NULL"이 아니다. 나머지는 'YYYY-MM-DD' 형식 문자열로 정상 변환된다
-- (스타일 코드 120 = ODBC canonical, 'YYYY-MM-DD HH:MI:SS'의 날짜 부분).
