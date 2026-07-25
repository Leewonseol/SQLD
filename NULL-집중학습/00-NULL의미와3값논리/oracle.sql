-- 00-NULL의미와3값논리: 공통 데이터셋(canonical, 다른 폴더가 그대로 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (Oracle)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다
-- (Olist-고객데이터/00-데이터사전/profile.py로 확인됨) — 혼동 금지.
--
-- *** Oracle 고유 함정: nickname에 ''(빈 문자열)를 넣는 INSERT는 Oracle에서
-- 그 값을 NULL로 저장한다(Oracle은 ''와 NULL을 구분하지 않는다). 그래서
-- customer_id=3(설계 의도: 빈 문자열)은 Oracle에 적재되는 순간부터
-- nickname이 NULL이 되어, customer_id=2/8(원래부터 NULL)과 구분이 불가능
-- 해진다. 이는 버그가 아니라 이 모듈이 보여주려는 핵심 차이다 — SQL Server
-- 버전(sqlserver.sql)에서는 ''가 그대로 ''로 남아 NULL과 구분된다. ***
-- =====================================================================

DROP TABLE null_lab_customer;

CREATE TABLE null_lab_customer (
    customer_id      NUMBER        PRIMARY KEY,
    customer_name    VARCHAR2(20)  NOT NULL,
    nickname         VARCHAR2(20),
    age              NUMBER,
    membership_code  VARCHAR2(5),
    score             NUMBER,
    purchase_amt     NUMBER(10,2),
    order_qty        NUMBER,
    discount_qty     NUMBER,
    dept_code        VARCHAR2(5),
    join_date        DATE
);

INSERT INTO null_lab_customer VALUES (1, '김민준', '민준', 28,   'A001', 85,  120000, 10, 2,    'D01', DATE '2024-01-10');
INSERT INTO null_lab_customer VALUES (2, '이서연', NULL,  34,   'A002', 92,  98000,  5,  0,    'D02', DATE '2024-02-15');
INSERT INTO null_lab_customer VALUES (3, '박지훈', '',    41,   'A003', NULL,150000, 8,  4,    'D03', NULL);
INSERT INTO null_lab_customer VALUES (4, '최유진', ' ',   0,    'A004', 77,  0,      3,  1,    NULL,  DATE '2024-03-05');
INSERT INTO null_lab_customer VALUES (5, '정하은', '하은',NULL, '0',   60,  NULL,   6,  2,    'D01', DATE '2024-01-22');
INSERT INTO null_lab_customer VALUES (6, '강도현', '도현',29,   'A006', 0,   45000,  0,  3,    'D02', DATE '2024-04-11');
INSERT INTO null_lab_customer VALUES (7, '윤서준', '서준',33,   'A007', 88,  76000,  4,  NULL, 'D03', DATE '2024-05-02');
INSERT INTO null_lab_customer VALUES (8, '임수아', NULL,  45,   'A008', 95,  210000, 12, 5,    'D99', DATE '2024-06-19');
INSERT INTO null_lab_customer VALUES (9, '한지민', '지민',26,   'A009', NULL,89000,  7,  2,    'D01', DATE '2024-07-08');
INSERT INTO null_lab_customer VALUES (10,'오세훈', '세훈',38,   'A010', 70,  132000, 9,  3,    NULL,  DATE '2024-08-14');
INSERT INTO null_lab_customer VALUES (11,'배수지', '수지',31,   'A011', 82,  NULL,   5,  2,    'D02', NULL);
INSERT INTO null_lab_customer VALUES (12,'조현우', '현우',50,   'A012', 99,  300000, 15, 5,    'D03', DATE '2024-09-30');

COMMIT;

DROP TABLE null_lab_dept;

CREATE TABLE null_lab_dept (
    dept_code  VARCHAR2(5) PRIMARY KEY,
    dept_name  VARCHAR2(20)
);

INSERT INTO null_lab_dept VALUES ('D01', '총무팀');
INSERT INTO null_lab_dept VALUES ('D02', '영업팀');
INSERT INTO null_lab_dept VALUES ('D03', '개발팀');

COMMIT;
-- customer_id=8(dept_code='D99'), 4·10(dept_code=NULL)은 null_lab_dept에
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더).

DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR2(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);

COMMIT;
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습.

-- =====================================================================
-- STEP 1. NULL은 "값이 없다"가 아니라 "알 수 없다(unknown)"다.
--   등호 비교조차 성립하지 않는다는 것을 직접 확인한다.
-- =====================================================================
SELECT customer_id, score,
       score = NULL   AS eq_null_literal,   -- 항상 UNKNOWN → 결과 NULL로 표시됨
       score <> NULL  AS neq_null_literal,  -- 마찬가지로 항상 UNKNOWN
       score IS NULL  AS is_null_correct    -- 유일하게 올바른 판정 방법
FROM null_lab_customer
WHERE customer_id IN (1, 3, 9);
-- eq_null_literal / neq_null_literal 두 컬럼은 TRUE도 FALSE도 아닌 NULL(UNKNOWN)로
-- 나온다 — "SELECT 목록에 조건식을 쓰면 UNKNOWN이 NULL로 표시된다"는 것 자체가
-- 3값 논리가 눈에 보이는 방식이다.

-- =====================================================================
-- STEP 2. 3값 논리 진리표 — AND
--   TRUE=1, FALSE=0, UNKNOWN=NULL 인 두 컬럼을 모든 조합으로 만들어 CASE로
--   AND 연산을 직접 구현해서 결과를 확인한다.
-- =====================================================================
WITH truth_values AS (
    SELECT 'TRUE' AS label, 1 AS v FROM DUAL UNION ALL
    SELECT 'FALSE', 0 FROM DUAL UNION ALL
    SELECT 'UNKNOWN', NULL FROM DUAL
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
ORDER BY a.v DESC NULLS LAST, b.v DESC NULLS LAST;
-- 핵심 결과: TRUE AND UNKNOWN = UNKNOWN, FALSE AND UNKNOWN = FALSE(단축 평가),
--           TRUE OR UNKNOWN = TRUE(단축 평가), FALSE OR UNKNOWN = UNKNOWN,
--           UNKNOWN AND UNKNOWN = UNKNOWN, UNKNOWN OR UNKNOWN = UNKNOWN.
-- "AND는 FALSE가 하나라도 있으면 무조건 FALSE", "OR는 TRUE가 하나라도 있으면
-- 무조건 TRUE" — UNKNOWN이 섞여도 이 두 규칙이 우선한다는 것이 SQLD 함정 포인트.

-- =====================================================================
-- STEP 3. NOT UNKNOWN = UNKNOWN (부정해도 UNKNOWN은 UNKNOWN 그대로)
-- =====================================================================
SELECT customer_id, score,
       CASE WHEN score > 80 THEN 'TRUE'
            WHEN NOT (score > 80) THEN 'FALSE'
            ELSE 'UNKNOWN(NOT으로도 못 뒤집음)' END AS not_result
FROM null_lab_customer
WHERE customer_id IN (1, 3, 9);
-- customer_id=3,9는 score가 NULL이라 score>80도 UNKNOWN, NOT(score>80)도
-- UNKNOWN이라 두 WHEN 모두 걸리지 않고 ELSE로 떨어진다.

-- =====================================================================
-- STEP 4. WHERE절은 딱 TRUE인 행만 반환한다 — FALSE와 UNKNOWN을 구분하지 않고
--   둘 다 버린다는 것을 직접 확인(자세한 실습은 06 폴더).
-- =====================================================================
SELECT customer_id, score FROM null_lab_customer WHERE score > 80;          -- TRUE인 행만
SELECT customer_id, score FROM null_lab_customer WHERE NOT (score > 80);    -- score IS NOT NULL AND score<=80 인 행만(NULL은 여기도 안 나옴)
SELECT customer_id, score FROM null_lab_customer WHERE score IS NULL;       -- score가 NULL인 행(위 두 결과 모두에서 빠진 행들)
-- 세 쿼리를 합쳐도 12행이 되고, 겹치는 행이 없다 — WHERE는 TRUE/FALSE/UNKNOWN을
-- 서로 배타적으로 나누지만, "조건과 그 반대 조건"만으로는 전체 행을 다 못 덮는다는
-- 뜻이다(UNKNOWN 몫은 IS NULL로 따로 잡아야 한다).
