-- 06-NULL과WHERE-CASE: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- STEP 1. WHERE에서 AND로 묶은 조건 중 하나에 NULL이 관여하면?
--   score > 80 AND dept_code = 'D01' — 12행 전체를 T/F/U로 직접 분류해서
--   "FALSE가 하나라도 있으면 무조건 FALSE"(00 폴더 진리표) 규칙 때문에
--   NULL이 있어도 F로 확정되는 행과, 진짜 U(UNKNOWN)라서 빠지는 행을 구분한다.
-- =====================================================================
SELECT customer_id, score, dept_code
FROM null_lab_customer
WHERE score > 80 AND dept_code = 'D01';
-- 예상: customer_id=1 (score=85, dept_code='D01') 딱 1행만 반환.
-- customer_id=9는 dept_code='D01'로 조건 절반은 TRUE지만 score가 NULL이라
-- 전체가 UNKNOWN이 되어 빠진다 — "dept_code는 D01인데 왜 안 나오지?"가
-- SQLD에서 자주 나오는 함정이다.

SELECT customer_id, score, dept_code,
       CASE WHEN score > 80 THEN 'T' WHEN NOT (score > 80) THEN 'F' ELSE 'U' END AS score_gt80,
       CASE WHEN dept_code = 'D01' THEN 'T' WHEN NOT (dept_code = 'D01') THEN 'F' ELSE 'U' END AS dept_eq_d01,
       CASE WHEN (score > 80 AND dept_code = 'D01') THEN 'PASS(T)'
            WHEN NOT (score > 80 AND dept_code = 'D01') THEN 'FAIL(F)'
            ELSE 'FAIL(U)' END AS and_result
FROM null_lab_customer
ORDER BY customer_id;
-- 핵심 관찰: customer_id=3,4,10은 두 조건 중 하나가 U(UNKNOWN)이지만 다른
-- 쪽이 확정적으로 F라서 and_result가 'FAIL(F)'로 확정된다(00 폴더의
-- "FALSE AND UNKNOWN = FALSE" 단축평가). customer_id=9만 유일하게 두 조건이
-- U/T 조합이라 and_result='FAIL(U)'로, "몰라서" 빠진 진짜 UNKNOWN 케이스다.
-- WHERE 결과만 보면 3,4,9,10 모두 그냥 "안 나온 행"이지만 빠진 이유는 서로 다르다.

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
-- 예상: customer_id=1,4,8,10 전부 'ELSE로 떨어짐'. dept_code가 실제 NULL인
-- 4,10행조차 'NULL부서' 분기를 절대 타지 못한다 — Simple CASE로는 NULL을
-- 잡을 수 없다는 것이 이 폴더의 핵심 함정.

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
-- Searched CASE(CASE WHEN 조건 THEN ...)는 IS NULL 술어를 조건으로 직접
-- 쓸 수 있어 STEP 2의 함정을 피한다.

-- =====================================================================
-- STEP 4. CASE 표현식 자체가 NULL을 반환하면 WHERE에서도 그 행이 빠진다.
--   ELSE가 없는 CASE는 어떤 WHEN에도 안 걸리면 NULL을 반환하고, 이 NULL이
--   다시 WHERE 비교에 들어가면 UNKNOWN이 되어 행이 배제된다.
-- =====================================================================
SELECT customer_id, score FROM null_lab_customer WHERE score > 80;
-- (비교 기준) 예상: customer_id 1,2,7,8,11,12 (6행) — score>80인 행만.

SELECT customer_id, score
FROM null_lab_customer
WHERE (CASE WHEN score > 80 THEN 'Y' END) = 'Y';
-- 예상: 위와 완전히 같은 6행. score<=80인 행(예: id=4, score=77)은 CASE에
-- ELSE가 없어 NULL을 반환하고, NULL = 'Y'가 다시 UNKNOWN이 되어 배제된다.
-- score가 원래 NULL인 행(3,9)도 CASE 조건 자체가 UNKNOWN이라 CASE 결과가
-- NULL이 되어 마찬가지로 배제된다 — "조건이 FALSE라서 빠진 행"과 "CASE가
-- NULL을 반환해서 빠진 행"이 WHERE 결과만 봐서는 구분되지 않는다는 것이
-- 이 STEP의 핵심 함정이다.
-- 참고: CHECK 제약조건은 WHERE/CASE와 달리 UNKNOWN을 "통과"시킨다(즉 값이
-- 저장된다) — 이 차이는 11-NULL과제약조건 폴더에서 상세히 다룬다.
