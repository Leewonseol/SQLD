-- 07-NULL과JOIN: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(이 폴더의 핵심).

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
-- STEP 1. JOIN 키에 NULL/불일치 값이 있을 때 INNER JOIN과 LEFT JOIN의
--   결과 차이. dept_code가 NULL인 4,10행과 불일치값 'D99'인 8행이
--   INNER JOIN에서는 통째로 사라진다.
-- =====================================================================
SELECT c.customer_id, c.customer_name, c.dept_code, d.dept_name
FROM null_lab_customer c
INNER JOIN null_lab_dept d ON c.dept_code = d.dept_code
ORDER BY c.customer_id;
-- 예상: 9행(customer_id 1,2,3,5,6,7,9,11,12). Oracle과 동일한 결과 — JOIN
-- 키 NULL 처리 규칙은 DBMS와 무관한 표준 동작이다.

SELECT c.customer_id, c.customer_name, c.dept_code, d.dept_name
FROM null_lab_customer c
LEFT JOIN null_lab_dept d ON c.dept_code = d.dept_code
ORDER BY c.customer_id;
-- 예상: 12행 전부. customer_id=4,8,10은 dept_name이 NULL.

-- =====================================================================
-- STEP 2. NULL = NULL은 여전히 UNKNOWN이다 — JOIN의 ON 조건도 결국 =
--   비교이므로 dept_code가 둘 다 NULL인 행끼리도 서로 매칭되지 않는다.
-- =====================================================================
SELECT CASE WHEN NULL = NULL THEN 'EQUAL'
            WHEN NOT (NULL = NULL) THEN 'NOT EQUAL'
            ELSE 'UNKNOWN(=비교 규칙)'
       END AS eq_comparison_rule;
-- 예상: 'UNKNOWN(=비교 규칙)'. (ANSI_NULLS ON 기본값 기준 — 00 폴더 참고)

SELECT c1.customer_id AS id1, c2.customer_id AS id2
FROM null_lab_customer c1
JOIN null_lab_customer c2 ON c1.dept_code = c2.dept_code
WHERE c1.customer_id = 4 AND c2.customer_id = 10;
-- 예상: 0행. dept_code가 둘 다 NULL이지만 = 비교는 절대 TRUE가 될 수 없다.

-- =====================================================================
-- STEP 3. 반면 집합연산(UNION/INTERSECT/EXCEPT)은 행을 비교할 때 NULL과
--   NULL을 "같다"고 취급한다 — STEP 2의 = 비교 규칙과 정반대다.
-- =====================================================================
SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
UNION
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 1행(NULL). Oracle과 동일 — UNION은 NULL=NULL을 "같다"고 본다.

SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
UNION ALL
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 2행(NULL, NULL). UNION ALL은 중복 제거를 하지 않는다.

-- =====================================================================
-- STEP 4. INTERSECT / EXCEPT도 UNION과 같은 규칙(NULL=NULL을 같다고 취급)
--   으로 행을 비교한다. SQL Server는 Oracle의 MINUS 대신 EXCEPT를 쓴다
--   (문법만 다르고 NULL 취급 규칙은 동일).
-- =====================================================================
SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
INTERSECT
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 1행(NULL).

SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
EXCEPT
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 0행. EXCEPT(SQL Server 문법, Oracle은 MINUS)도 NULL을 "같다"고
-- 보므로 왼쪽의 NULL이 오른쪽의 NULL과 매칭되어 제거된다.
