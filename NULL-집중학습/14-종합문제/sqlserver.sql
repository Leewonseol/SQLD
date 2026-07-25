-- 14-종합문제: null_lab_customer 계열 공통 데이터셋(00~11과 동일, 복사)
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


-- 14-종합문제: impute_practice_raw 계열 공통 데이터셋(12~13과 동일, 복사)
-- 새로 만든 데이터가 아니다 — 분석기법/22-KNN결측값대체 참고.
-- 12-평균-중앙값대치 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요(이 세션에는 SQL Server 실행 환경이 없음).
-- 아래 impute_practice_raw 테이블은 분석기법/22-KNN결측값대체/01_prepare_sqlserver.sql
-- 에서 정의한 것과 완전히 같은 테이블을 그대로 재사용한다(새로 만든 데이터가
-- 아니다). 같은 로직을 SQLite로 실제 실행·검증한 결과 수치를 아래 STEP들이
-- 그대로 인용한다(README "12. 실제 실행 검증 여부" 참고).
--
-- Olist 원자료(olist_customers_dataset.csv)에는 실제 결측이 없다 — 이 표는
-- Olist와 무관한, kNN·평균·중앙값 대치 실습을 위한 별도의 작은 합성 데이터다.

IF OBJECT_ID('impute_practice_raw', 'U') IS NOT NULL DROP TABLE impute_practice_raw;

CREATE TABLE impute_practice_raw (
    customer_id           VARCHAR(10) PRIMARY KEY,
    recency                FLOAT,
    frequency               FLOAT,
    monetary                FLOAT,
    delivery_days           FLOAT,
    review_score            FLOAT,
    target_missing_value    FLOAT,
    coupon_code_raw         VARCHAR(20),
    true_value_for_check    FLOAT,
    scenario_type           VARCHAR(30)
);

INSERT INTO impute_practice_raw VALUES ('C001', 10, 8, 120, 3, 5, 130,  'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C002', 45, 3, 60,  5, 3, 55,   'SPRING5',   NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C003', 5,  12,200, 2, 5, 210,  NULL,        NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C004', 90, 1, 20,  7, 2, 15,   'WINTER20',  NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C005', 30, 5, 80,  4, 4, 85,   '',          NULL, 'empty_string');
INSERT INTO impute_practice_raw VALUES ('C006', 15, 7, 110, 3, 4, 120,  ' ',         NULL, 'whitespace_string');
INSERT INTO impute_practice_raw VALUES ('C007', 60, 2, 40,  6, 3, 35,   'FALL15',    NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C008', 8,  9, 150, 2, 5, 160,  'SUMMER25',  NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C009', 100,0, 0,   9, 1, 0,    'EXPIRED',   NULL, 'zero_value');
INSERT INTO impute_practice_raw VALUES ('C010', 8,  7, 96,  4, 5, 100,  'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C011', 12, 8, 125, 3, 5, 135,  'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C012', 25, 4, 98000,3, 5, 95000,'VIP1',     NULL, 'extreme_value');
INSERT INTO impute_practice_raw VALUES ('C013', 40, 3, 65,  5, 3, 58,   'SPRING5',   NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C014', 8,  7, 96,  4, 5, 96,   'WELCOME10', NULL, 'complete');
INSERT INTO impute_practice_raw VALUES ('C015', 50, 2, 42,  6, 3, 38,   'FALL15',    NULL, 'complete');

INSERT INTO impute_practice_raw VALUES ('C016', 11,   8, 122,   3,   5, NULL, 'WELCOME10', 132,   'single_null');
INSERT INTO impute_practice_raw VALUES ('C017', NULL, 3, 62,    NULL,3, NULL, 'SPRING5',   56,    'multi_null');
INSERT INTO impute_practice_raw VALUES ('C018', 13,   8, 123,   3,   5, NULL, 'WELCOME10', 133,   'distance_tie');
INSERT INTO impute_practice_raw VALUES ('C019', 24,   4, 97500, 3,   5, NULL, 'VIP1',      94000, 'near_extreme');
INSERT INTO impute_practice_raw VALUES ('C020', 95,   1, 18,    8,   2, NULL, 'WINTER20',  17,    'single_null');

-- =====================================================================
-- 두 데이터셋이 모두 준비됐는지 확인하는 종합 점검 쿼리 — quiz.sql의
-- 문제들은 이 두 테이블(null_lab_customer 계열, impute_practice_raw)을
-- 모두 사용한다.
-- =====================================================================
SELECT 'null_lab_customer' AS table_name, COUNT(*) AS row_count,
       SUM(CASE WHEN nickname IS NULL THEN 1 ELSE 0 END) AS null_nickname_count
FROM null_lab_customer
UNION ALL
SELECT 'null_lab_dept', COUNT(*), NULL FROM null_lab_dept
UNION ALL
SELECT 'null_lab_excluded_codes', COUNT(*), NULL FROM null_lab_excluded_codes
UNION ALL
SELECT 'impute_practice_raw', COUNT(*),
       SUM(CASE WHEN target_missing_value IS NULL THEN 1 ELSE 0 END)
FROM impute_practice_raw;
-- 예상: null_lab_customer=12행(SQL Server 기준 null_nickname_count=2행만
-- — nickname=''인 3행은 NULL이 아니므로 제외), null_lab_dept=3행,
-- null_lab_excluded_codes=3행, impute_practice_raw=20행
-- (target_missing_value NULL 5행)
