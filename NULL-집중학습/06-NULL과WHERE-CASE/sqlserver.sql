-- 06-NULL과WHERE-CASE: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- STEP 1. WHERE에서 AND로 묶은 조건 중 하나에 NULL이 관여하면?
--   score > 80 AND dept_code = 'D01' — 12행 전체를 T/F/U로 직접 분류해서
--   "FALSE가 하나라도 있으면 무조건 FALSE"(00 폴더 진리표) 규칙 때문에
--   NULL이 있어도 F로 확정되는 행과, 진짜 U(UNKNOWN)라서 빠지는 행을 구분한다.
-- =====================================================================
SELECT customer_id, score, dept_code
FROM null_lab_customer
WHERE score > 80 AND dept_code = 'D01';
-- 예상: customer_id=1 (score=85, dept_code='D01') 딱 1행만 반환. Oracle과 동일.

SELECT customer_id, score, dept_code,
       CASE WHEN score > 80 THEN 'T' WHEN NOT (score > 80) THEN 'F' ELSE 'U' END AS score_gt80,
       CASE WHEN dept_code = 'D01' THEN 'T' WHEN NOT (dept_code = 'D01') THEN 'F' ELSE 'U' END AS dept_eq_d01,
       CASE WHEN (score > 80 AND dept_code = 'D01') THEN 'PASS(T)'
            WHEN NOT (score > 80 AND dept_code = 'D01') THEN 'FAIL(F)'
            ELSE 'FAIL(U)' END AS and_result
FROM null_lab_customer
ORDER BY customer_id;
-- 결과는 Oracle과 완전히 동일하다(3값 논리는 표준 SQL 공통 규칙). customer_id=
-- 3,4,10은 'FAIL(F)'로 확정, customer_id=9만 'FAIL(U)'로 진짜 UNKNOWN 케이스다.

-- =====================================================================
-- STEP 2. Simple CASE의 함정 — CASE dept_code WHEN NULL THEN ... 은
--   내부적으로 dept_code = NULL과 동치라서 절대 TRUE가 될 수 없다.
--   dept_code가 실제로 NULL인 행(4,10)도 항상 ELSE로 떨어진다.
-- =====================================================================
SELECT customer_id, dept_code,
       CASE dept_code
            WHEN NULL THEN 'NULL부서(절대 여기로 안 옴)'
            ELSE 'ELSE로 떨어짐'
       END AS simple_case_result
FROM null_lab_customer
WHERE customer_id IN (1, 4, 8, 10);
-- 예상: customer_id=1,4,8,10 전부 'ELSE로 떨어짐'. SQL Server도 Oracle과
-- 동일하게 Simple CASE로는 NULL을 절대 못 잡는다 — ANSI_NULLS 설정과
-- 무관하게 CASE의 내부 비교 규칙은 표준을 따른다.

-- =====================================================================
-- STEP 3. Searched CASE로 올바르게 NULL 판정하기
-- =====================================================================
SELECT customer_id, dept_code,
       CASE WHEN dept_code IS NULL THEN 'NULL부서(정상 판정)'
            ELSE '부서 있음'
       END AS searched_case_result
FROM null_lab_customer
WHERE customer_id IN (1, 4, 8, 10);
-- 예상: customer_id=1,8 → '부서 있음'. customer_id=4,10 → 'NULL부서(정상 판정)'.

-- =====================================================================
-- STEP 4. CASE 표현식 자체가 NULL을 반환하면 WHERE에서도 그 행이 빠진다.
-- =====================================================================
SELECT customer_id, score FROM null_lab_customer WHERE score > 80;
-- (비교 기준) 예상: customer_id 1,2,7,8,11,12 (6행).

SELECT customer_id, score
FROM null_lab_customer
WHERE (CASE WHEN score > 80 THEN 'Y' END) = 'Y';
-- 예상: 위와 완전히 같은 6행. Oracle과 동일한 이유 — ELSE 없는 CASE가 NULL을
-- 반환하는 행은 WHERE에서 조건이 FALSE였던 행과 구분 없이 함께 배제된다.
-- 참고: CHECK 제약조건은 WHERE/CASE와 달리 UNKNOWN을 "통과"시킨다(즉 값이
-- 저장된다) — 이 차이는 11-NULL과제약조건 폴더에서 상세히 다룬다.
