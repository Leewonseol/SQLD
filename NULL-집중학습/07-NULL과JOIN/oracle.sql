-- 07-NULL과JOIN: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(이 폴더의 핵심).

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
-- STEP 1. JOIN 키에 NULL/불일치 값이 있을 때 INNER JOIN과 LEFT JOIN의
--   결과 차이. dept_code가 NULL인 4,10행과 불일치값 'D99'인 8행이
--   INNER JOIN에서는 통째로 사라진다.
-- =====================================================================
SELECT c.customer_id, c.customer_name, c.dept_code, d.dept_name
FROM null_lab_customer c
INNER JOIN null_lab_dept d ON c.dept_code = d.dept_code
ORDER BY c.customer_id;
-- 예상: 9행(customer_id 1,2,3,5,6,7,9,11,12). 4,8,10행은 dept_code가
-- NULL(=어떤 값과 비교해도 UNKNOWN)이거나 'D99'(대응 부서 없음)라서
-- ON 조건이 TRUE가 될 수 없어 결과에서 완전히 빠진다.

SELECT c.customer_id, c.customer_name, c.dept_code, d.dept_name
FROM null_lab_customer c
LEFT JOIN null_lab_dept d ON c.dept_code = d.dept_code
ORDER BY c.customer_id;
-- 예상: 12행 전부 남는다. customer_id=4,8,10은 dept_name이 NULL로 채워진다
-- (LEFT JOIN은 왼쪽 테이블 행을 보존하고, 매칭되는 오른쪽 행이 없으면
-- 오른쪽 컬럼을 전부 NULL로 채운다).

-- =====================================================================
-- STEP 2. NULL = NULL은 여전히 UNKNOWN이다 (00/01 폴더에서 이미 확인한
--   규칙의 재확인) — JOIN의 ON 조건도 결국 = 비교이므로 이 규칙이 그대로
--   적용되어 dept_code가 둘 다 NULL인 행끼리도 서로 매칭되지 않는다.
-- =====================================================================
SELECT CASE WHEN NULL = NULL THEN 'EQUAL'
            WHEN NOT (NULL = NULL) THEN 'NOT EQUAL'
            ELSE 'UNKNOWN(=비교 규칙)'
       END AS eq_comparison_rule
FROM DUAL;
-- 예상: 'UNKNOWN(=비교 규칙)'. 이 규칙 때문에 customer_id=4와 10(둘 다
-- dept_code=NULL)을 SELF JOIN c1.dept_code = c2.dept_code로 이어붙여도
-- 서로 매칭되지 않는다 — 아래에서 직접 확인한다.
SELECT c1.customer_id AS id1, c2.customer_id AS id2
FROM null_lab_customer c1
JOIN null_lab_customer c2 ON c1.dept_code = c2.dept_code
WHERE c1.customer_id = 4 AND c2.customer_id = 10;
-- 예상: 0행. dept_code가 둘 다 NULL이지만 = 비교는 절대 TRUE가 될 수 없다.

-- =====================================================================
-- STEP 3. 반면 집합연산(UNION/INTERSECT/MINUS)은 행을 비교할 때 NULL과
--   NULL을 "같다"고 취급한다 — STEP 2의 = 비교 규칙과 정반대다.
--   dept_code가 NULL인 두 행(customer_id 4, 10)의 dept_code 값만 뽑아
--   UNION(중복 제거)하면 1행으로 합쳐진다.
-- =====================================================================
SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
UNION
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 1행(NULL). 만약 UNION의 중복 제거가 = 비교처럼 NULL을 UNKNOWN으로
-- 취급했다면 "같은지 몰라서" 중복으로 인식하지 못해 2행이 남았을 것이다.
-- 실제로는 1행으로 합쳐진다 — 집합연산은 NULL=NULL을 "같다"고 본다.

SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
UNION ALL
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 2행(NULL, NULL). UNION ALL은 애초에 중복 제거를 하지 않으므로
-- NULL 취급 규칙과 무관하게 둘 다 남는다 — UNION과의 대조를 위한 참고용.

-- =====================================================================
-- STEP 4. INTERSECT / MINUS도 UNION과 같은 규칙(NULL=NULL을 같다고 취급)
--   으로 행을 비교한다.
-- =====================================================================
SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
INTERSECT
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 1행(NULL). 두 집합 모두 {NULL} 하나뿐이고, INTERSECT가 NULL을
-- "같다"고 보므로 교집합에 NULL이 남는다.

SELECT dept_code FROM null_lab_customer WHERE customer_id = 4   -- NULL
MINUS
SELECT dept_code FROM null_lab_customer WHERE customer_id = 10; -- NULL
-- 예상: 0행. MINUS(Oracle 문법, SQL Server는 EXCEPT)도 NULL을 "같다"고
-- 보므로, 왼쪽의 NULL이 오른쪽의 NULL과 매칭되어 제거된다 — 남는 행이 없다.
-- (Oracle은 MINUS, SQL Server는 EXCEPT로 문법만 다르고 NULL 취급 규칙은
-- 동일하다.)
