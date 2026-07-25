-- 03-NULL과산술연산: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (SQL Server)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다.
--
-- *** SQL Server 대조 포인트: nickname에 넣은 ''(빈 문자열)는 SQL Server에서
-- NULL로 바뀌지 않고 그대로 ''로 저장된다(Oracle과 정반대). 그래서
-- customer_id=3의 nickname은 길이 0인 빈 문자열로 남고, customer_id=2/8
-- (진짜 NULL)과 IS NULL로 명확히 구분된다. ***
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더, 이 폴더에서는 안 씀).

IF OBJECT_ID('null_lab_excluded_codes', 'U') IS NOT NULL DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 안 씀).

-- =====================================================================
-- STEP 1. NULL이 포함된 산술연산의 결과는 항상 NULL
--   +, -, *, / 어떤 연산이든 피연산자 중 하나라도 NULL이면 결과 전체가 NULL.
--   purchase_amt NULL(5,11), age NULL(5), score NULL(3,9)로 확인.
-- =====================================================================
SELECT customer_id,
       purchase_amt,
       purchase_amt + 10000 AS amt_plus,
       purchase_amt * 1.1   AS amt_times,
       age,
       age + 1              AS age_plus_1,
       score,
       score * 2             AS score_times_2
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: purchase_amt가 NULL인 5, 11행은 amt_plus/amt_times도 NULL.
-- age가 NULL인 5행은 age_plus_1도 NULL. score가 NULL인 3, 9행은
-- score_times_2도 NULL. Oracle과 결과 동일(3값 논리와 마찬가지로 NULL
-- 산술 규칙 자체는 표준 SQL 공통이다).

-- =====================================================================
-- STEP 2. NULL과 문자열 결합(+) — 하나라도 NULL이면 전체가 NULL이 된다.
--   SQL Server는 문자열 결합에 || 대신 + 를 쓴다(CONCAT 함수도 있지만
--   05-NULL과문자열에서 다룬다). 여기서는 "NULL 산술의 한 예시"로만
--   간단히 다룬다.
-- =====================================================================
SELECT customer_id,
       nickname,
       nickname + N'님' AS greeting_raw
FROM null_lab_customer
ORDER BY customer_id;
-- 예상(SQL Server): nickname이 NULL인 2, 8행만 greeting_raw가 NULL이 된다.
-- customer_id=3은 nickname=''(빈 문자열, NULL 아님)이라 ''+'님'='님'으로
-- 정상 결합된다 — Oracle과 정반대(Oracle 버전에서는 3행도 NULL이 됨,
-- oracle.sql STEP 2 참고). 이 차이는 결국 01 폴더의 ''→NULL 저장 규칙
-- 차이에서 비롯된 것이다.

-- ISNULL/COALESCE로 방어 — NULL을 먼저 빈 문자열이나 대체 텍스트로 치환한
-- 뒤 결합하면 전체 결과가 NULL이 되는 것을 막을 수 있다.
SELECT customer_id,
       nickname,
       ISNULL(nickname, N'고객') + N'님' AS greeting_defended
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: 모든 행에서 NULL 없이 문자열이 채워진다(2, 8행 → '고객님', 3행은
-- 원래도 NULL이 아니므로 '님'으로 그대로 남는다).

-- =====================================================================
-- STEP 3. NULLIF를 이용한 0으로 나누기 방지
--   discount_qty: customer_id=2는 0(분모 0), customer_id=7은 NULL(분모 NULL).
--   "분모가 0인 것"과 "분모가 NULL인 것"은 서로 다른 현상임을 대조한다.
-- =====================================================================

-- (1) 방어 없이 그대로 나누면 customer_id=2에서 에러가 난다.
-- *** 아래 SELECT는 실행하면 에러 발생 예상: Divide by zero error encountered. ***
SELECT customer_id,
       order_qty,
       discount_qty,
       order_qty / discount_qty AS ratio_raw
FROM null_lab_customer
ORDER BY customer_id;

-- (2) customer_id=2를 제외하고 실행하면 나머지 행에서 대조가 뚜렷해진다 —
--     customer_id=7(discount_qty=NULL)은 에러 없이 그냥 NULL이 나온다.
SELECT customer_id,
       order_qty,
       discount_qty,
       order_qty / discount_qty AS ratio_raw
FROM null_lab_customer
WHERE customer_id <> 2
ORDER BY customer_id;
-- 예상: customer_id=7만 ratio_raw=NULL(에러 아님). 나머지는 정상 계산된 값
-- (order_qty, discount_qty 모두 INT라 정수 나눗셈이므로 소수부는 버려짐에
-- 주의). "0으로 나누기=에러", "NULL로 나누기=NULL"이라는 서로 다른 현상.

-- (3) NULLIF(discount_qty, 0)으로 0을 NULL로 바꿔 에러 대신 NULL을 받도록 방어
SELECT customer_id,
       order_qty,
       discount_qty,
       NULLIF(discount_qty, 0)               AS discount_qty_safe,
       order_qty / NULLIF(discount_qty, 0)   AS ratio_defended
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=2 → discount_qty_safe=NULL, ratio_defended=NULL
-- (에러 대신 NULL로 대체됨). customer_id=7 → discount_qty_safe=NULL(원래도
-- NULL이었으므로 NULLIF를 거쳐도 동일), ratio_defended=NULL. 결과적으로
-- 2행과 7행 모두 NULL이 나오지만, "에러를 막았다"는 점에서 (1)과 다르다.
