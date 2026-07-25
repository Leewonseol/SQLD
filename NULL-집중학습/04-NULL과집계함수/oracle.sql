-- 04-NULL과집계함수: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더, 이 폴더에서는 안 씀).

DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR2(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);

COMMIT;
-- NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는 NULL이 섞여
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 안 씀).

-- =====================================================================
-- STEP 1. COUNT(*) vs COUNT(컬럼) — NULL 포함 여부의 차이
--   score는 customer_id 3, 9행이 NULL(12행 중 2행).
-- =====================================================================
SELECT COUNT(*)      AS count_star,      -- 전체 행 수(NULL 여부 무관)
       COUNT(score)  AS count_score      -- score가 NULL이 아닌 행 수
FROM null_lab_customer;
-- 예상: count_star=12, count_score=10.

-- =====================================================================
-- STEP 2. AVG(score) vs AVG(COALESCE(score, 0)) — 서로 다른 평균값
--   score 값: 85,92,NULL,77,60,0,88,95,NULL,70,82,99
-- =====================================================================
SELECT AVG(score)                AS avg_ignore_null,   -- NULL 2개를 제외한 10개 평균
       AVG(COALESCE(score, 0))   AS avg_null_as_zero,   -- NULL을 0으로 치환한 12개 평균
       SUM(score)                AS sum_score,
       COUNT(score)              AS n_ignore_null,
       COUNT(*)                  AS n_all
FROM null_lab_customer;
-- 예상: sum_score=748(NULL 제외 10개 합), n_ignore_null=10.
-- avg_ignore_null = 748/10 = 74.8.
-- avg_null_as_zero = 748/12 = 62.333...(반올림 표시는 클라이언트/자리수 설정에 따라 다름).
-- 두 평균이 12.4666...만큼 차이난다는 것 — "NULL을 무시할지, 0으로 볼지"가
-- 결과에 실질적 영향을 준다는 것을 수치로 확인하는 것이 이 STEP의 핵심.

-- =====================================================================
-- STEP 3. SUM/MIN/MAX도 기본적으로 NULL을 무시하고 계산한다
--   (COUNT/AVG/SUM/MIN/MAX 모두 "NULL은 집계 대상에서 제외"라는 공통 원칙)
-- =====================================================================
SELECT SUM(score) AS sum_score,   -- 748 (NULL 2개는 계산에서 제외, 0으로 치환되는 게 아님)
       MIN(score) AS min_score,   -- 0 (customer_id=6, 실제 숫자 0 — NULL이 아니라서 포함됨)
       MAX(score) AS max_score    -- 99 (customer_id=12)
FROM null_lab_customer;
-- 예상: sum_score=748, min_score=0, max_score=99.
-- min_score가 0인 것과 score가 NULL인 행은 전혀 다른 개념이라는 것에 주의
-- (숫자 0은 엄연히 "알고 있는 값"이라 집계 대상에 정상 포함된다).

-- 부서별(GROUP BY)로 나눠도 같은 원칙이 유지되는지 확인
SELECT dept_code,
       COUNT(*)     AS n_all,
       COUNT(score) AS n_scored,
       SUM(score)   AS sum_score,
       AVG(score)   AS avg_score,
       MIN(score)   AS min_score,
       MAX(score)   AS max_score
FROM null_lab_customer
GROUP BY dept_code
ORDER BY dept_code NULLS LAST;
-- 예상(자세한 수치는 expected_results.md 참고):
-- D01(1,5,9행: 85,60,NULL) → n_all=3, n_scored=2, sum=145, avg=72.5, min=60, max=85
-- D02(2,6,11행: 92,0,82)   → n_all=3, n_scored=3, sum=174, avg=58,   min=0,  max=92
-- D03(3,7,12행: NULL,88,99)→ n_all=3, n_scored=2, sum=187, avg=93.5,min=88, max=99
-- D99(8행: 95)             → n_all=1, n_scored=1, sum=95,  avg=95,  min=95, max=95
-- NULL(4,10행: 77,70)      → n_all=2, n_scored=2, sum=147, avg=73.5,min=70, max=77

-- =====================================================================
-- STEP 4. 그룹의 모든 값이 NULL이면 SUM/AVG 자체가 NULL이 된다
--   (COUNT(*)는 여전히 실제 행 수를 세지만, COUNT(score)는 0이 된다)
-- =====================================================================

-- (1) score가 NULL인 행만 모아 GROUP BY하면, 각 그룹의 score가 전부 NULL이라
--     SUM/AVG/MIN/MAX가 모두 NULL이 된다(COUNT(*)만 실제 행 수를 보여준다).
SELECT dept_code,
       COUNT(*)     AS n_all,
       COUNT(score) AS n_scored,
       SUM(score)   AS sum_score,
       AVG(score)   AS avg_score,
       MIN(score)   AS min_score,
       MAX(score)   AS max_score
FROM null_lab_customer
WHERE score IS NULL
GROUP BY dept_code;
-- 예상: D01(customer_id=9만 해당) → n_all=1, n_scored=0, sum/avg/min/max 모두 NULL.
-- D03(customer_id=3만 해당)      → n_all=1, n_scored=0, sum/avg/min/max 모두 NULL.

-- (2) WHERE 1=0으로 아예 빈 결과 집합(0행)을 만들어도 같은 원칙을 확인할 수 있다.
--     GROUP BY 없이 집계하면 "0행"이 아니라 "집계 결과 1행"이 나온다는 점에 주의.
SELECT COUNT(*)     AS n_all,
       COUNT(score) AS n_scored,
       SUM(score)   AS sum_score,
       AVG(score)   AS avg_score,
       MIN(score)   AS min_score,
       MAX(score)   AS max_score
FROM null_lab_customer
WHERE 1 = 0;
-- 예상: n_all=0, n_scored=0, sum_score=NULL, avg_score=NULL, min_score=NULL,
-- max_score=NULL. COUNT류만 0이 나오고 나머지 집계함수는 전부 NULL이라는
-- 것이 "집계 대상 행이 0행이면 COUNT는 0, 나머지는 NULL"이라는 SQLD 단골
-- 함정이다.
