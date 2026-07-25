-- 04-NULL과집계함수: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- STEP 1. COUNT(*) vs COUNT(컬럼) — NULL 포함 여부의 차이
--   score는 customer_id 3, 9행이 NULL(12행 중 2행).
-- =====================================================================
SELECT COUNT(*)      AS count_star,      -- 전체 행 수(NULL 여부 무관)
       COUNT(score)  AS count_score      -- score가 NULL이 아닌 행 수
FROM null_lab_customer;
-- 예상: count_star=12, count_score=10. Oracle과 동일.

-- =====================================================================
-- STEP 2. AVG(score) vs AVG(COALESCE(score, 0)) — 서로 다른 평균값
--   score 값: 85,92,NULL,77,60,0,88,95,NULL,70,82,99
--
--   *** SQL Server 고유 함정: score가 INT로 선언되어 있으면 AVG(score)의
--   반환 타입도 INT로 고정되어, 계산된 평균의 소수부가 "반올림"이 아니라
--   "버림(truncate)"된다. 정확한 소수 평균을 얻으려면 DECIMAL/FLOAT로
--   CAST한 뒤 AVG해야 한다 — Oracle의 NUMBER는 이런 제약이 없다. ***
-- =====================================================================
SELECT AVG(score)                              AS avg_ignore_null_int,     -- INT로 잘림(버림)
       AVG(CAST(score AS DECIMAL(10,2)))        AS avg_ignore_null_decimal, -- 정확한 소수 평균
       AVG(COALESCE(score, 0))                  AS avg_null_as_zero_int,     -- INT로 잘림(버림)
       AVG(CAST(COALESCE(score, 0) AS DECIMAL(10,2))) AS avg_null_as_zero_decimal, -- 정확한 소수 평균
       SUM(score)                               AS sum_score,
       COUNT(score)                             AS n_ignore_null,
       COUNT(*)                                 AS n_all
FROM null_lab_customer;
-- 예상: sum_score=748, n_ignore_null=10.
-- avg_ignore_null_int = 74   (748/10=74.8 인데 INT로 버림)
-- avg_ignore_null_decimal = 74.80 (정확한 값)
-- avg_null_as_zero_int = 62  (748/12=62.333... 인데 INT로 버림)
-- avg_null_as_zero_decimal = 62.333333(반올림 자리수는 CAST 스케일에 따라 다름, 정확히는 62.33...)
-- CAST 없이 AVG(score)만 쓰면 74.8이 아니라 74가 나온다는 것이 이 STEP의
-- 핵심 함정 — Oracle에서는 이런 잘림이 발생하지 않는다(oracle.sql STEP 2 참고).

-- =====================================================================
-- STEP 3. SUM/MIN/MAX도 기본적으로 NULL을 무시하고 계산한다
--   (COUNT/AVG/SUM/MIN/MAX 모두 "NULL은 집계 대상에서 제외"라는 공통 원칙)
-- =====================================================================
SELECT SUM(score) AS sum_score,   -- 748 (NULL 2개는 계산에서 제외, 0으로 치환되는 게 아님)
       MIN(score) AS min_score,   -- 0 (customer_id=6, 실제 숫자 0 — NULL이 아니라서 포함됨)
       MAX(score) AS max_score    -- 99 (customer_id=12)
FROM null_lab_customer;
-- 예상: sum_score=748, min_score=0, max_score=99. SUM/MIN/MAX는 정수 컬럼
-- 이어도 값 자체가 정수라 AVG처럼 잘림 문제가 생기지 않는다.

-- 부서별(GROUP BY)로 나눠도 같은 원칙이 유지되는지 확인
-- (SQL Server에는 Oracle의 NULLS LAST가 없어 CASE WHEN 트릭으로 NULL을
-- 뒤로 보낸다 — 09 폴더에서 상세히 다룬다.)
SELECT dept_code,
       COUNT(*)                          AS n_all,
       COUNT(score)                      AS n_scored,
       SUM(score)                        AS sum_score,
       AVG(CAST(score AS DECIMAL(10,2))) AS avg_score,
       MIN(score)                        AS min_score,
       MAX(score)                        AS max_score
FROM null_lab_customer
GROUP BY dept_code
ORDER BY CASE WHEN dept_code IS NULL THEN 1 ELSE 0 END, dept_code;
-- 예상(자세한 수치는 expected_results.md 참고):
-- D01(1,5,9행: 85,60,NULL) → n_all=3, n_scored=2, sum=145, avg=72.50, min=60, max=85
-- D02(2,6,11행: 92,0,82)   → n_all=3, n_scored=3, sum=174, avg=58.00, min=0,  max=92
-- D03(3,7,12행: NULL,88,99)→ n_all=3, n_scored=2, sum=187, avg=93.50,min=88, max=99
-- D99(8행: 95)             → n_all=1, n_scored=1, sum=95,  avg=95.00,min=95, max=95
-- NULL(4,10행: 77,70)      → n_all=2, n_scored=2, sum=147, avg=73.50,min=70, max=77

-- =====================================================================
-- STEP 4. 그룹의 모든 값이 NULL이면 SUM/AVG 자체가 NULL이 된다
--   (COUNT(*)는 여전히 실제 행 수를 세지만, COUNT(score)는 0이 된다)
-- =====================================================================

-- (1) score가 NULL인 행만 모아 GROUP BY하면, 각 그룹의 score가 전부 NULL이라
--     SUM/AVG/MIN/MAX가 모두 NULL이 된다(COUNT(*)만 실제 행 수를 보여준다).
SELECT dept_code,
       COUNT(*)                          AS n_all,
       COUNT(score)                      AS n_scored,
       SUM(score)                        AS sum_score,
       AVG(CAST(score AS DECIMAL(10,2))) AS avg_score,
       MIN(score)                        AS min_score,
       MAX(score)                        AS max_score
FROM null_lab_customer
WHERE score IS NULL
GROUP BY dept_code;
-- 예상: D01(customer_id=9만 해당) → n_all=1, n_scored=0, sum/avg/min/max 모두 NULL.
-- D03(customer_id=3만 해당)      → n_all=1, n_scored=0, sum/avg/min/max 모두 NULL.

-- (2) WHERE 1=0으로 아예 빈 결과 집합(0행)을 만들어도 같은 원칙을 확인할 수 있다.
--     GROUP BY 없이 집계하면 "0행"이 아니라 "집계 결과 1행"이 나온다는 점에 주의.
SELECT COUNT(*)                          AS n_all,
       COUNT(score)                      AS n_scored,
       SUM(score)                        AS sum_score,
       AVG(CAST(score AS DECIMAL(10,2))) AS avg_score,
       MIN(score)                        AS min_score,
       MAX(score)                        AS max_score
FROM null_lab_customer
WHERE 1 = 0;
-- 예상: n_all=0, n_scored=0, sum_score=NULL, avg_score=NULL, min_score=NULL,
-- max_score=NULL. COUNT류만 0이 나오고 나머지 집계함수는 전부 NULL이라는
-- 것이 "집계 대상 행이 0행이면 COUNT는 0, 나머지는 NULL"이라는 SQLD 단골
-- 함정이다. Oracle과 결과 동일.
