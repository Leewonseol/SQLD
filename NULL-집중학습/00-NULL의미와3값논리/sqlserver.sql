-- 00-NULL의미와3값논리: 공통 데이터셋(canonical, 다른 폴더가 그대로 복사)
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
-- STEP 1. NULL은 "값이 없다"가 아니라 "알 수 없다(unknown)"다.
--   등호 비교조차 성립하지 않는다는 것을 직접 확인한다.
-- =====================================================================
SELECT customer_id, score,
       CASE WHEN score = NULL THEN 1 WHEN NOT (score = NULL) THEN 0 END AS eq_null_literal,
       CASE WHEN score <> NULL THEN 1 WHEN NOT (score <> NULL) THEN 0 END AS neq_null_literal,
       CASE WHEN score IS NULL THEN 1 ELSE 0 END AS is_null_correct
FROM null_lab_customer
WHERE customer_id IN (1, 3, 9);
-- eq_null_literal / neq_null_literal 두 컬럼은 항상 NULL로 나온다(TRUE도 FALSE도
-- 아님). SQL Server는 `score = NULL`을 SELECT의 최상위 불리언 표현식으로 직접
-- 쓸 수 없어(비교 predicate만 허용) CASE WHEN으로 감쌌다 — Oracle과의 문법 차이.
-- SET ANSI_NULLS OFF(레거시, 비권장)를 켜면 `= NULL`이 `IS NULL`처럼 동작하도록
-- 바뀌지만, 이는 표준을 어기는 예외적 설정이라 이 저장소에서는 쓰지 않는다.

-- =====================================================================
-- STEP 2. 3값 논리 진리표 — AND / OR
--   TRUE=1, FALSE=0, UNKNOWN=NULL 인 두 컬럼을 모든 조합으로 만들어 CASE로
--   AND/OR 연산을 직접 구현해서 결과를 확인한다.
-- =====================================================================
WITH truth_values AS (
    SELECT 'TRUE' AS label, 1 AS v
    UNION ALL SELECT 'FALSE', 0
    UNION ALL SELECT 'UNKNOWN', NULL
)
SELECT
    a.label AS a_value,
    b.label AS b_value,
    CASE
        WHEN a.v = 0 OR b.v = 0 THEN 'FALSE'
        WHEN a.v = 1 AND b.v = 1 THEN 'TRUE'
        ELSE 'UNKNOWN'
    END AS a_and_b,
    CASE
        WHEN a.v = 1 OR b.v = 1 THEN 'TRUE'
        WHEN a.v = 0 AND b.v = 0 THEN 'FALSE'
        ELSE 'UNKNOWN'
    END AS a_or_b
FROM truth_values a
CROSS JOIN truth_values b
ORDER BY CASE WHEN a.v IS NULL THEN 1 ELSE 0 END, a.v DESC,
         CASE WHEN b.v IS NULL THEN 1 ELSE 0 END, b.v DESC;
-- 핵심 결과는 Oracle과 완전히 같다(3값 논리 자체는 표준 SQL 공통 규칙이며
-- DBMS마다 다르지 않다 — 여기서 달라지는 것은 정렬 문법(NULLS LAST 유무)뿐):
-- TRUE AND UNKNOWN = UNKNOWN, FALSE AND UNKNOWN = FALSE(단축 평가),
-- TRUE OR UNKNOWN = TRUE(단축 평가), FALSE OR UNKNOWN = UNKNOWN,
-- UNKNOWN AND UNKNOWN = UNKNOWN, UNKNOWN OR UNKNOWN = UNKNOWN.

-- =====================================================================
-- STEP 3. NOT UNKNOWN = UNKNOWN (부정해도 UNKNOWN은 UNKNOWN 그대로)
-- =====================================================================
SELECT customer_id, score,
       CASE WHEN score > 80 THEN 'TRUE'
            WHEN NOT (score > 80) THEN 'FALSE'
            ELSE 'UNKNOWN(NOT으로도 못 뒤집음)' END AS not_result
FROM null_lab_customer
WHERE customer_id IN (1, 3, 9);

-- =====================================================================
-- STEP 4. WHERE절은 딱 TRUE인 행만 반환한다 — FALSE와 UNKNOWN을 구분하지 않고
--   둘 다 버린다는 것을 직접 확인(자세한 실습은 06 폴더).
-- =====================================================================
SELECT customer_id, score FROM null_lab_customer WHERE score > 80;
SELECT customer_id, score FROM null_lab_customer WHERE NOT (score > 80);
SELECT customer_id, score FROM null_lab_customer WHERE score IS NULL;
-- 세 쿼리를 합쳐도 12행이 되고, 겹치는 행이 없다 — Oracle과 동일한 결과.
