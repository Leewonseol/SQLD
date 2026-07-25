-- 09-NULL정렬과윈도우함수: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
-- =====================================================================
-- NULL-집중학습 공통 테스트 데이터 (SQL Server)
-- null_lab_customer / null_lab_dept / null_lab_excluded_codes
--
-- Olist 원자료(olist_customers_dataset.csv)와 무관한, 이 학습 모듈 전용의
-- 작은 합성(synthetic) 데이터다. Olist 원자료에는 실제 결측이 없다.
--
-- *** SQL Server 대조 포인트: nickname에 넣은 ''(빈 문자열)는 SQL Server에서
-- NULL로 바뀌지 않고 그대로 ''로 저장된다(Oracle과 정반대). ***
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
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 쓰지 않음).

-- =====================================================================
-- STEP 1. NULL 정렬 순서 — SQL Server 기본값(Oracle과 반대!)
--   SQL Server는 NULL을 항상 "가장 작은 값"으로 취급한다. 그래서
--   ORDER BY ... ASC(오름차순, 작은 값부터)이면 NULL이 맨 앞에 오고,
--   ORDER BY ... DESC(내림차순, 큰 값부터)이면 NULL이 맨 뒤에 온다 —
--   Oracle 기본값(ASC=NULL 맨 뒤, DESC=NULL 맨 앞)과 정확히 반대다.
--   SQL Server에는 Oracle의 NULLS FIRST/LAST 절 자체가 없다.
-- =====================================================================
SELECT customer_id, score
FROM null_lab_customer
ORDER BY score ASC, customer_id;
-- 예상: 3,9(NULL)가 맨 앞 → 이후 6,5,10,4,11,1,7,2,8,12 순으로 score 오름차순
-- (Oracle의 ORDER BY score ASC NULLS FIRST와 같은 순서)

SELECT customer_id, score
FROM null_lab_customer
ORDER BY score DESC, customer_id;
-- 예상: 12,8,2,7,1,11,4,10,5,6 순으로 score 내림차순 → 마지막에 3,9(NULL)
-- (Oracle의 ORDER BY score DESC NULLS LAST와 같은 순서)

-- STEP 1b. NULLS FIRST/LAST가 없는 SQL Server에서 Oracle 기본값(ASC=NULL
-- 맨 뒤)을 흉내내려면 CASE WHEN 트릭을 쓴다.
SELECT customer_id, score
FROM null_lab_customer
ORDER BY CASE WHEN score IS NULL THEN 1 ELSE 0 END, score ASC, customer_id;
-- 예상: score 오름차순 먼저 → 3,9(NULL)가 맨 뒤 (Oracle ASC 기본값과 동일)

SELECT customer_id, score
FROM null_lab_customer
ORDER BY CASE WHEN score IS NULL THEN 0 ELSE 1 END, score DESC, customer_id;
-- 예상: 3,9(NULL)가 맨 앞 → 이후 score 내림차순 (Oracle DESC 기본값과 동일)

-- =====================================================================
-- STEP 2. ROW_NUMBER, RANK, DENSE_RANK와 NULL — purchase_amt 기준
--   purchase_amt가 NULL인 행은 customer_id 5, 11. SQL Server 기본(ASC는
--   NULL이 맨 앞)이므로 이 두 행은 정렬 순서상 맨 앞에 위치하고, 서로는
--   "같다"고 취급되어 RANK/DENSE_RANK가 동일한 순위로 묶인다 — NULL이
--   맨 앞/뒤 어디에 있든 "NULL끼리는 동순위"라는 원리 자체는 Oracle과 같다.
-- =====================================================================
SELECT customer_id, purchase_amt,
       ROW_NUMBER() OVER (ORDER BY purchase_amt ASC, customer_id) AS rn,
       RANK()       OVER (ORDER BY purchase_amt ASC) AS rnk,
       DENSE_RANK() OVER (ORDER BY purchase_amt ASC) AS drnk
FROM null_lab_customer
ORDER BY CASE WHEN purchase_amt IS NULL THEN 0 ELSE 1 END, purchase_amt ASC, customer_id;
-- 예상: NULL인 5,11이 맨 앞 → rn=1,2, rnk=1,1, drnk=1,1
-- 이후 값 오름차순 4,6,7,9,2,1,10,3,8,12 → rn 3~12 순차 부여,
-- rnk는 3,4,5,6,7,8,9,10,11,12(모두 서로 다른 값이라 RANK도 순차 증가),
-- drnk는 2,3,4,5,6,7,8,9,10,11
-- (Oracle 버전과 rn/rnk/drnk "값"은 같은 원리로 매겨지지만 NULL이 맨
-- 앞이냐 맨 뒤냐에 따라 어떤 customer_id에 어떤 번호가 붙는지는 달라진다.)

-- =====================================================================
-- STEP 3. PARTITION BY dept_code — NULL도 하나의 파티션으로 묶인다
--   dept_code가 NULL인 customer_id 4, 10은 같은 파티션으로 묶여 그
--   안에서만 ROW_NUMBER가 1, 2로 매겨진다. GROUP BY가 NULL을 하나의
--   그룹으로 묶는 것(04 폴더)과 같은 원리이며, PARTITION BY도 동일하게
--   동작한다는 것이 이 STEP의 핵심 — 정렬 방향(ASC/DESC 기본값)이 달라도
--   "NULL은 하나의 파티션"이라는 원리 자체는 Oracle과 SQL Server가 같다.
-- =====================================================================
SELECT customer_id, dept_code, score,
       ROW_NUMBER() OVER (PARTITION BY dept_code ORDER BY customer_id) AS rn_in_dept
FROM null_lab_customer
ORDER BY CASE WHEN dept_code IS NULL THEN 1 ELSE 0 END, dept_code, customer_id;
-- 예상 파티션: D01={1,5,9}, D02={2,6,11}, D03={3,7,12}, D99={8},
-- NULL={4,10} → NULL 파티션 안에서 4번(rn_in_dept=1), 10번(rn_in_dept=2)
