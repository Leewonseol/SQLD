-- 08-NOT-IN과NOT-EXISTS: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더), 이 폴더(08)의
-- NOT IN/NOT EXISTS 비교에서도 그대로 활용한다.

IF OBJECT_ID('null_lab_excluded_codes', 'U') IS NOT NULL DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);
-- 이 폴더(08)의 핵심 실습 테이블 — NOT IN 서브쿼리 결과에 NULL이 섞이는
-- 고전적 함정을 시연하기 위해 일부러 NULL 한 행을 포함시켰다.

-- =====================================================================
-- STEP 1. NOT IN 함정 — SQL Server도 Oracle과 완전히 동일한 3값 논리를
--   따르므로 결과가 똑같이 0행이다. NOT IN의 NULL 함정은 문법이 아니라
--   ANSI SQL 표준의 3값 논리 자체에서 비롯되므로 DBMS를 가리지 않는다.
--
--   dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는
--   내부적으로 다음과 같이 풀린다.
--     dept_code <> 'D02' AND dept_code <> 'D03' AND dept_code <> NULL
--   마지막 항은 항상 UNKNOWN이라 AND 전체가 절대 TRUE가 될 수 없다.
-- =====================================================================
SELECT customer_id, customer_name, dept_code
FROM null_lab_customer
WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes);
-- 예상: 0행 (Oracle과 동일한 함정)

-- =====================================================================
-- STEP 2. NOT EXISTS — 상관 서브쿼리는 EXISTS/NOT EXISTS 자체가 항상
--   TRUE/FALSE로만 평가되므로(절대 UNKNOWN이 되지 않음) NULL이 섞여
--   있어도 안전하다.
-- =====================================================================
SELECT c.customer_id, c.customer_name, c.dept_code
FROM null_lab_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM null_lab_excluded_codes e
    WHERE e.dept_code = c.dept_code
)
ORDER BY c.customer_id;
-- 예상: dept_code가 'D02'/'D03'이 아닌 행 + dept_code가 NULL인 행 =
-- customer_id 1(D01), 4(NULL), 5(D01), 8(D99), 9(D01), 10(NULL) → 6행

-- =====================================================================
-- STEP 3. 안전한 대안 ① — NOT IN 서브쿼리에 IS NOT NULL을 추가.
--   서브쿼리가 깨끗해져도 "바깥쪽" dept_code 자체가 NULL인 행(4, 10)은
--   여전히 걸러진다 — dept_code <> 'D02' AND dept_code <> 'D03'에서
--   dept_code가 NULL이면 양쪽 다 UNKNOWN이 되기 때문이다.
-- =====================================================================
SELECT customer_id, customer_name, dept_code
FROM null_lab_customer
WHERE dept_code NOT IN (
    SELECT dept_code FROM null_lab_excluded_codes WHERE dept_code IS NOT NULL
)
ORDER BY customer_id;
-- 예상: customer_id 1(D01), 5(D01), 8(D99), 9(D01) → 4행
-- (STEP 2의 NOT EXISTS 결과 6행과 다르다 — 4, 10행이 여기서는 빠진다.)

-- =====================================================================
-- STEP 4. 세 방식의 결과 건수를 한 번에 비교 — 0행 vs 6행 vs 4행
-- =====================================================================
SELECT 'NOT IN (원본, NULL 포함 서브쿼리)' AS approach, COUNT(*) AS row_count
FROM null_lab_customer
WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)
UNION ALL
SELECT 'NOT EXISTS', COUNT(*)
FROM null_lab_customer c
WHERE NOT EXISTS (SELECT 1 FROM null_lab_excluded_codes e WHERE e.dept_code = c.dept_code)
UNION ALL
SELECT 'NOT IN (서브쿼리에 IS NOT NULL 추가)', COUNT(*)
FROM null_lab_customer
WHERE dept_code NOT IN (
    SELECT dept_code FROM null_lab_excluded_codes WHERE dept_code IS NOT NULL
);
-- 예상: 0, 6, 4 — 세 방식이 모두 다른 값을 낸다. "NOT IN 서브쿼리를 쓸 때는
-- 항상 NULL 가능성부터 점검하라"가 SQLD/실무 공통의 정석이다.
