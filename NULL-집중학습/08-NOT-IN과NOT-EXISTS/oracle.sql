-- 08-NOT-IN과NOT-EXISTS: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 대응하는 부서가 없다 — JOIN 키 NULL/불일치 실습용(07 폴더), 이 폴더(08)의
-- NOT IN/NOT EXISTS 비교에서도 그대로 활용한다.

DROP TABLE null_lab_excluded_codes;

CREATE TABLE null_lab_excluded_codes (
    dept_code VARCHAR2(5)
);

INSERT INTO null_lab_excluded_codes VALUES ('D02');
INSERT INTO null_lab_excluded_codes VALUES ('D03');
INSERT INTO null_lab_excluded_codes VALUES (NULL);

COMMIT;
-- 이 폴더(08)의 핵심 실습 테이블 — NOT IN 서브쿼리 결과에 NULL이 섞이는
-- 고전적 함정을 시연하기 위해 일부러 NULL 한 행을 포함시켰다.

-- =====================================================================
-- STEP 1. NOT IN 함정 — 서브쿼리 결과에 NULL이 하나라도 섞이면 NOT IN은
--   예상과 달리 "0행"을 반환한다.
--
--   dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)는
--   내부적으로 다음과 같이 풀린다.
--     dept_code <> 'D02' AND dept_code <> 'D03' AND dept_code <> NULL
--   마지막 항 "dept_code <> NULL"은 dept_code가 무엇이든 항상 UNKNOWN이다
--   (00 폴더 3값 논리). AND 체인에서 어느 한 항이라도 UNKNOWN이고 나머지가
--   전부 TRUE라면 전체 결과는 UNKNOWN이 된다(TRUE AND TRUE AND UNKNOWN =
--   UNKNOWN) — WHERE는 TRUE인 행만 통과시키므로 UNKNOWN인 행은 전부
--   버려진다. 그 결과 어떤 dept_code 값이 와도 이 조건을 절대 만족할 수
--   없어 0행이 나온다.
-- =====================================================================
SELECT customer_id, customer_name, dept_code
FROM null_lab_customer
WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes);
-- 예상: 0행 (12행 중 어느 것도 나오지 않는다 — 함정)

-- =====================================================================
-- STEP 2. NOT EXISTS — 같은 의도를 상관 서브쿼리로 바꾸면 정상 동작한다.
--   NOT EXISTS는 "매칭되는 행이 존재하는가"만 확인하는 술어라서 EXISTS/
--   NOT EXISTS 자체는 절대 UNKNOWN이 되지 않고 TRUE/FALSE만 반환한다.
--   서브쿼리 안에 NULL이 섞여 있어도, 그 NULL은 어떤 dept_code와도 매칭될
--   수 없을 뿐(= 비교가 UNKNOWN이라 WHERE를 통과 못함) 전체 EXISTS 판정을
--   더럽히지 않는다.
-- =====================================================================
SELECT c.customer_id, c.customer_name, c.dept_code
FROM null_lab_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM null_lab_excluded_codes e
    WHERE e.dept_code = c.dept_code
)
ORDER BY c.customer_id;
-- 예상: dept_code가 'D02'/'D03'이 아닌 행 + dept_code가 NULL인 행 =
-- customer_id 1(D01), 4(NULL), 5(D01), 8(D99), 9(D01), 10(NULL) → 6행

-- =====================================================================
-- STEP 3. 안전한 대안 ① — NOT IN 서브쿼리에 IS NOT NULL을 추가해 NULL을
--   미리 제거한다. 이러면 서브쿼리는 {'D02','D03'}만 반환하므로 NOT IN이
--   다시 정상적으로 "TRUE/FALSE"로만 평가된다.
--
--   단, 이 방식에는 남은 함정이 하나 있다 — 서브쿼리가 깨끗해져도 "바깥쪽"
--   dept_code 자체가 NULL인 행(4, 10)은 여전히 걸러진다.
--   dept_code <> 'D02' AND dept_code <> 'D03'에서 dept_code가 NULL이면
--   양쪽 항 모두 UNKNOWN이라 AND 결과도 UNKNOWN이기 때문이다. 즉 "서브쿼리의
--   NULL"과 "바깥 컬럼의 NULL"은 별개의 함정이라는 것을 이 STEP이 보여준다.
-- =====================================================================
SELECT customer_id, customer_name, dept_code
FROM null_lab_customer
WHERE dept_code NOT IN (
    SELECT dept_code FROM null_lab_excluded_codes WHERE dept_code IS NOT NULL
)
ORDER BY customer_id;
-- 예상: customer_id 1(D01), 5(D01), 8(D99), 9(D01) → 4행
-- (STEP 2의 NOT EXISTS 결과 6행과 다르다 — 4, 10행(dept_code NULL)이
-- 여기서는 빠진다. NOT IN은 "바깥 컬럼이 NULL이 아닌" 행에만 안전하다.)

-- =====================================================================
-- STEP 4. 세 방식의 결과 건수를 한 번에 비교 — 0행 vs 6행 vs 4행
-- =====================================================================
SELECT 'NOT IN (원본, NULL 포함 서브쿼리)' AS approach, COUNT(*) AS row_count
FROM null_lab_customer
WHERE dept_code NOT IN (SELECT dept_code FROM null_lab_excluded_codes)
UNION ALL
SELECT 'NOT EXISTS', COUNT(*)
FROM null_lab_customer c
WHERE NOT EXISTS (SELECT 1 FROM null_lab_excluded_codes e WHERE e.dept_code = c.dept_code)
UNION ALL
SELECT 'NOT IN (서브쿼리에 IS NOT NULL 추가)', COUNT(*)
FROM null_lab_customer
WHERE dept_code NOT IN (
    SELECT dept_code FROM null_lab_excluded_codes WHERE dept_code IS NOT NULL
);
-- 예상: 0, 6, 4 — 세 방식이 모두 다른 값을 낸다. "NOT IN 서브쿼리를 쓸 때는
-- 항상 NULL 가능성부터 점검하라"가 SQLD/실무 공통의 정석이다.
