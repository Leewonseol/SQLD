-- 01-NULL판정: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
--   nickname = NULL은 "nickname의 값과 알 수 없는 값이 같은가"를 묻는
--   질문이라 애초에 답할 수 없다(UNKNOWN) — 리터럴 NULL이 아니라 컬럼끼리
--   비교해도 마찬가지다.
-- =====================================================================
SELECT COUNT(*) AS wrong_count_eq_null
FROM null_lab_customer WHERE nickname = NULL;       -- 0행(항상 UNKNOWN)

SELECT COUNT(*) AS wrong_count_neq_null
FROM null_lab_customer WHERE nickname <> NULL;      -- 0행(항상 UNKNOWN)

SELECT COUNT(*) AS correct_count_is_null
FROM null_lab_customer WHERE nickname IS NULL;      -- 실제 NULL 행 수

-- =====================================================================
-- STEP 3. Oracle 함정 — 빈 문자열 ''은 저장되는 순간 NULL이 된다.
--   customer_id=2, 8은 설계상 진짜 NULL, customer_id=3은 설계상 ''(빈 문자열)
--   이었지만 Oracle에서는 셋 다 IS NULL이 TRUE로 나와 구분이 안 된다.
-- =====================================================================
SELECT customer_id, nickname, LENGTH(nickname) AS nickname_length,
       CASE WHEN nickname IS NULL THEN 'NULL(TRUE)' ELSE 'NOT NULL' END AS is_null_check
FROM null_lab_customer
WHERE customer_id IN (2, 3, 4, 8)
ORDER BY customer_id;
-- 예상(Oracle): 2,3,8행 모두 nickname IS NULL = TRUE, nickname_length = NULL.
-- customer_id=4(공백 ' ')만 nickname_length=1로 남아 구분된다 — Oracle에서도
-- "공백 한 칸"은 NULL로 변하지 않는다(빈 문자열만 NULL이 된다).

-- =====================================================================
-- STEP 4. 빈 문자열 / 공백 문자열을 명시적으로 구분하려는 시도(Oracle 한계)
--   Oracle에서는 nickname='' 조건 자체가 "컬럼 = NULL"과 같아져 절대 TRUE가
--   될 수 없다(비어있던 원본 데이터를 Oracle에 넣는 순간 이미 정보가
--   사라졌기 때문 — 저장 이후에는 SQL로 복구 불가능).
-- =====================================================================
SELECT COUNT(*) AS empty_string_rows_found FROM null_lab_customer WHERE nickname = '';
-- 예상: 0 (Oracle은 ''를 NULL로 저장했으므로 이 조건은 nickname = NULL과 동치)

SELECT COUNT(*) AS whitespace_rows_found FROM null_lab_customer WHERE nickname = ' ';
-- 예상: 1 (customer_id=4) — 공백 한 칸은 실제 문자이므로 정상 비교됨
