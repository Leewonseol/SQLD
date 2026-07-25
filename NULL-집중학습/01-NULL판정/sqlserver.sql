-- 01-NULL판정: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- STEP 1. IS NULL / IS NOT NULL — 유일하게 올바른 NULL 판정 방법
-- =====================================================================
SELECT customer_id, nickname, score, purchase_amt
FROM null_lab_customer
WHERE nickname IS NULL;

SELECT customer_id, nickname, score, purchase_amt
FROM null_lab_customer
WHERE nickname IS NOT NULL;

-- =====================================================================
-- STEP 2. = NULL / <> NULL이 작동하지 않는 이유를 직접 확인
-- =====================================================================
SELECT COUNT(*) AS wrong_count_eq_null
FROM null_lab_customer WHERE nickname = NULL;       -- 0행(항상 UNKNOWN, ANSI_NULLS ON 기본값 기준)

SELECT COUNT(*) AS wrong_count_neq_null
FROM null_lab_customer WHERE nickname <> NULL;      -- 0행(항상 UNKNOWN)

SELECT COUNT(*) AS correct_count_is_null
FROM null_lab_customer WHERE nickname IS NULL;      -- 실제 NULL 행 수
-- SQL Server 기본 세션 옵션 ANSI_NULLS는 ON이라 위 두 조건은 Oracle과 똑같이
-- 항상 UNKNOWN이다. (레거시 `SET ANSI_NULLS OFF`를 쓰면 `= NULL`이 `IS NULL`
-- 처럼 동작하도록 바뀌지만, Microsoft 공식 문서도 이 옵션을 향후 제거 예정인
-- 비권장 설정으로 안내한다 — 이 저장소에서는 절대 쓰지 않는다.)

-- =====================================================================
-- STEP 3. SQL Server 대조 — 빈 문자열 ''은 NULL로 바뀌지 않고 그대로 남는다.
--   customer_id=2, 8은 진짜 NULL, customer_id=3은 빈 문자열 ''이며
--   SQL Server에서는 이 셋이 IS NULL 결과로 명확히 구분된다(Oracle과 정반대).
-- =====================================================================
SELECT customer_id, nickname, LEN(nickname) AS nickname_len,
       DATALENGTH(nickname) AS nickname_datalength,
       CASE WHEN nickname IS NULL THEN 'NULL(TRUE)' ELSE 'NOT NULL' END AS is_null_check
FROM null_lab_customer
WHERE customer_id IN (2, 3, 4, 8)
ORDER BY customer_id;
-- 예상(SQL Server):
--   2,8행: nickname IS NULL = TRUE, LEN/DATALENGTH 모두 NULL
--   3행 (''): IS NULL = FALSE, LEN=0, DATALENGTH=0  ← Oracle과 정반대 결과
--   4행 (' '): IS NULL = FALSE, LEN=0(!), DATALENGTH=1
-- LEN은 뒤쪽 공백을 잘라내고 세기 때문에 공백 한 칸짜리 문자열의 길이도 0으로
-- 나온다 — ''과 ' '을 LEN만으로는 구분할 수 없다(05 폴더에서 상세히 다룸).
-- 진짜 저장된 바이트 길이를 보려면 DATALENGTH를 써야 ''(0)과 ' '(1)이 구분된다.

-- =====================================================================
-- STEP 4. SQL Server의 진짜 함정 — ANSI 공백 패딩(padding) 비교
--   SQL Server(및 ANSI SQL 표준)는 = 비교에서 짧은 문자열의 뒤를 공백으로
--   채워(pad) 길이를 맞춘 뒤 비교한다. 그래서 ''(길이0)과 ' '(길이1)을
--   비교하면 ''가 ' '로 채워져 서로 "같다"고 판정된다 — ''과 ' '이 SQL
--   Server에서도 별개 값으로 저장은 되지만, = 비교로는 구분되지 않는다.
-- =====================================================================
SELECT COUNT(*) AS empty_string_rows_found FROM null_lab_customer WHERE nickname = '';
-- 예상: 2 (customer_id=3 그리고 4!) — ''이 ' '로 패딩되어 ' '(customer_id=4)
-- 와도 같다고 판정되기 때문. "SQL Server는 ''과 NULL을 구분하니 '' 비교는
-- 안전하다"고 넘어가면 이 함정에 걸린다.

SELECT COUNT(*) AS whitespace_rows_found FROM null_lab_customer WHERE nickname = ' ';
-- 예상: 2 (customer_id=3, 4 모두) — 위와 같은 이유로 대칭적으로 똑같이 걸린다.

-- ''과 ' '을 진짜로 구분하려면 = 비교가 아니라 DATALENGTH(정확한 바이트 길이)를
-- 함께 써야 한다.
SELECT customer_id, nickname,
       CASE WHEN nickname = '' AND DATALENGTH(nickname) = 0 THEN 'TRUE_EMPTY_STRING'
            WHEN nickname = '' AND DATALENGTH(nickname) > 0 THEN 'WHITESPACE_NOT_EMPTY'
            ELSE 'OTHER' END AS empty_vs_whitespace
FROM null_lab_customer
WHERE nickname = ''
ORDER BY customer_id;
-- 예상: customer_id=3 → TRUE_EMPTY_STRING, customer_id=4 → WHITESPACE_NOT_EMPTY
