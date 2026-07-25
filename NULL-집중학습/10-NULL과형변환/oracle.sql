-- 10-NULL과형변환: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 쓰지 않음).

-- =====================================================================
-- STEP 1. CAST(NULL AS 자료형)은 여전히 NULL — 형변환은 NULL을 값 있는
--   상태로 바꾸지 못한다(당연해 보이지만 SQLD에서 "형변환하면 기본값이
--   채워질 것"이라 착각하게 만드는 문제가 자주 나온다).
-- =====================================================================
SELECT CAST(NULL AS NUMBER)       AS cast_null_number,
       CAST(NULL AS VARCHAR2(10)) AS cast_null_varchar,
       CAST(NULL AS DATE)         AS cast_null_date
FROM dual;
-- 예상: 세 컬럼 모두 NULL

-- =====================================================================
-- STEP 2. TO_CHAR / TO_NUMBER / TO_DATE에 NULL을 입력해도 결과는 NULL
-- =====================================================================
SELECT TO_CHAR(NULL)   AS to_char_null,
       TO_NUMBER(NULL) AS to_number_null,
       TO_DATE(NULL)   AS to_date_null
FROM dual;
-- 예상: 세 컬럼 모두 NULL(에러가 아니다)

-- =====================================================================
-- STEP 3. 자료형이 섞인 membership_code(VARCHAR2)를 숫자로 변환 시도
--   membership_code는 customer_id=5만 '0'(숫자로 변환 가능), 나머지는
--   'A001' 형태의 문자열(숫자로 변환 불가능)이다.
-- =====================================================================

-- 3-1. 정상 변환: '0' → 0
SELECT customer_id, membership_code, CAST(membership_code AS NUMBER) AS converted
FROM null_lab_customer
WHERE customer_id = 5;
-- 예상: converted = 0

-- 3-2. 비정상 변환 시도 — 아래 문장은 실행하면 ORA-01722(invalid number)
-- 에러가 발생한다(의도된 데모). 'A001'은 숫자로 변환할 수 없는 문자열이다.
SELECT customer_id, membership_code, CAST(membership_code AS NUMBER) AS converted
FROM null_lab_customer
WHERE customer_id = 1;
-- 예상: ORA-01722: invalid number 에러 발생(정상 동작, 버그 아님)

-- 3-3. 안전한 변환 — Oracle 12c+의 TO_NUMBER ... DEFAULT NULL ON
-- CONVERSION ERROR. SQL Server의 TRY_CAST/TRY_CONVERT에 대응하는 Oracle
-- 기능이며, Oracle에는 TRY_CAST 자체가 없다(12c 이전 버전에는 이 구문도
-- 없어 PL/SQL 예외처리로 우회해야 했다).
SELECT customer_id, membership_code,
       TO_NUMBER(membership_code DEFAULT NULL ON CONVERSION ERROR) AS safe_converted
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=5만 0, 나머지 11행은 모두 NULL(에러 대신 NULL 반환)

-- =====================================================================
-- STEP 4. join_date(DATE, NULL 포함)를 문자열로 변환 — NULL은 그대로 NULL
--   join_date가 NULL인 행은 customer_id 3, 11. 문자열로 변환해도 진짜
--   문자열 "NULL"이 되는 게 아니라 SQL NULL 그대로 남는다.
-- =====================================================================
SELECT customer_id, join_date,
       TO_CHAR(join_date, 'YYYY-MM-DD') AS join_date_str
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id 3, 11의 join_date_str은 SQL NULL(빈 값)이지 문자열
-- "NULL"이 아니다. 나머지는 'YYYY-MM-DD' 형식 문자열로 정상 변환된다.
