-- 05-NULL과문자열: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더).

IF OBJECT_ID('null_lab_excluded_codes', 'U') IS NOT NULL DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습.

-- =====================================================================
-- STEP 1. + 연산자 — NULL이 하나라도 섞이면 결과 문자열 전체가 NULL이 된다.
--   Oracle의 || 와 정반대 동작이라는 것이 이 폴더의 핵심 함정이다.
-- =====================================================================
SELECT customer_id, customer_name, nickname,
       customer_name + N'(' + nickname + N')' AS concat_plus
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8);
-- 예상: customer_id=2,8(nickname NULL) → concat_plus 전체가 NULL.
-- customer_id=3(SQL Server에서는 ''로 저장, NULL 아님) → '박지훈()' 정상 연결.
-- customer_id=4(' ') → '최유진( )' 정상 연결.

-- =====================================================================
-- STEP 2. CONCAT(a, b, ...) — NULL을 빈 문자열로 취급해서 결과가 NULL이
--   되지 않는다. 인수 개수 제한도 없다(Oracle CONCAT과 다른 점).
-- =====================================================================
SELECT customer_id, customer_name, nickname,
       CONCAT(customer_name, N'(', nickname, N')') AS concat_func
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8);
-- 예상: customer_id=2,8 → '이서연()', '임수아()' (nickname 자리만 빈 문자열
-- 취급되고 전체는 NULL이 되지 않음) — STEP 1의 + 결과와 정면으로 대조된다.

SELECT customer_id,
       CASE WHEN customer_name + N'(' + nickname + N')' IS NULL THEN 'NULL 전체'
            ELSE customer_name + N'(' + nickname + N')' END AS plus_result,
       CONCAT(customer_name, N'(', nickname, N')') AS concat_result
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8)
ORDER BY customer_id;
-- 두 컬럼을 나란히 놓고 비교 — nickname이 NULL인 2,8행에서만 두 결과가 갈린다.

-- =====================================================================
-- STEP 3. LEN vs DATALENGTH — NULL, 빈 문자열, 공백, 앞뒤 공백이 섞인
--   리터럴까지 폭넓게 비교한다. LEN은 뒤쪽 공백을 잘라내고 센다.
-- =====================================================================
SELECT customer_id, nickname,
       LEN(nickname)                 AS len_nickname,
       DATALENGTH(nickname)          AS datalength_nickname,
       LEN('  hello  ')              AS len_literal_padded,        -- 7 (뒤쪽 공백만 제거, 앞쪽은 유지)
       DATALENGTH('  hello  ')       AS datalength_literal_padded  -- 9 (원본 그대로)
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8)
ORDER BY customer_id;
-- 예상: customer_id=2,8 → LEN/DATALENGTH 모두 NULL.
-- customer_id=3(nickname='') → LEN=0, DATALENGTH=0.
-- customer_id=4(nickname=' ') → LEN=0(!), DATALENGTH=1 — LEN만으로는 3행과
-- 4행을 구분할 수 없다(01 폴더에서 이미 확인한 함정과 동일).
-- len_literal_padded=7, datalength_literal_padded=9 — LEN이 뒤쪽 공백 2개만
-- 잘라내고 앞쪽 공백 2개는 남긴다는 것을 리터럴로 명확히 보여준다.

-- =====================================================================
-- STEP 4. TRIM / LTRIM / RTRIM과 NULL — TRIM(NULL)은 NULL이지만, SQL
--   Server는 ''을 NULL로 바꾸지 않으므로 Oracle과 결과가 달라진다.
-- =====================================================================
SELECT customer_id, nickname,
       TRIM(nickname)  AS trim_nickname,   -- SQL Server 2017 이상
       LTRIM(nickname) AS ltrim_nickname,
       RTRIM(nickname) AS rtrim_nickname,
       DATALENGTH(TRIM(nickname)) AS trim_datalength
FROM null_lab_customer
WHERE customer_id IN (2, 3, 4, 8)
ORDER BY customer_id;
-- 예상: customer_id=2,8 → 세 컬럼 모두 NULL(TRIM(NULL)=NULL), trim_datalength도 NULL.
-- customer_id=3(nickname='') → TRIM/LTRIM/RTRIM 모두 '' 그대로, trim_datalength=0
--   (Oracle에서는 이 자리가 NULL로 나왔던 것과 정반대 — SQL Server는 ''을 NULL로
--   바꾸지 않기 때문이다).
-- customer_id=4(nickname=' ') → TRIM 결과 '', trim_datalength=0(공백이 전부
--   제거되어 길이 0인 진짜 빈 문자열이 남는다. Oracle이었다면 이 자리가 NULL로
--   나왔을 것이다).
