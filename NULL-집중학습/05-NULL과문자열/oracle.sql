-- 05-NULL과문자열: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- STEP 1. || 연산자 — NULL을 빈 문자열처럼 건너뛰고 나머지를 이어붙인다.
--   customer_id=2,8(nickname NULL), 3(Oracle에서 저장 시 NULL로 바뀜)에서도
--   결과 문자열 전체가 NULL이 되지 않고 nickname 자리만 빠진 채 이어진다.
-- =====================================================================
SELECT customer_id, customer_name, nickname,
       customer_name || '(' || nickname || ')' AS concat_pipe
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8);
-- 예상: customer_id=2,3,8 → '이서연()', '박지훈()', '임수아()' (nickname 자리가
-- 빈 문자열처럼 취급되어 괄호만 남고 전체 문자열은 NULL이 되지 않는다).
-- 이는 03/04 폴더의 "산술연산은 NULL이 하나만 섞여도 결과 전체가 NULL이
-- 된다"는 규칙과 정반대다 — Oracle의 || 는 문자열 결합에서만큼은 NULL을
-- 빈 문자열처럼 특별 취급한다.

-- =====================================================================
-- STEP 2. Oracle 내장 CONCAT(a,b)은 딱 2개 인수만 받는다.
--   ||는 인수 개수 제한이 없어 여러 개를 한 번에 이어붙일 수 있지만,
--   CONCAT 함수로 3개 이상을 이으려면 중첩 호출이 필요하다.
-- =====================================================================
SELECT customer_id,
       CONCAT(customer_name, nickname) AS concat_func_2args
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8);
-- CONCAT(customer_name, nickname)도 || 와 마찬가지로 nickname이 NULL이면
-- 그 부분만 빈 문자열 취급되어 customer_name만 남는다(전체가 NULL이 되지 않음).

SELECT customer_id,
       CONCAT(CONCAT(customer_name, '-'), nickname) AS concat_nested_3args
FROM null_lab_customer
WHERE customer_id IN (1, 2, 4, 8);
-- CONCAT(customer_name, '-', nickname)처럼 인수 3개를 한 번에 넘기면
-- ORA-00909(인수 개수 부적합) 오류가 난다 — 그래서 CONCAT(CONCAT(a,b),c)
-- 형태로 중첩해야 한다. (아래는 실행하면 에러가 나는 것을 보여주기 위한
-- 참고용 주석이며, 실제로 실행하지 않는다.)
-- SELECT CONCAT(customer_name, '-', nickname) FROM null_lab_customer; -- ORA-00909

-- =====================================================================
-- STEP 3. LENGTH — NULL, 빈 문자열(Oracle에서는 NULL과 동일), 공백,
--   일반 문자열, 앞뒤 공백이 섞인 리터럴까지 폭넓게 비교한다.
-- =====================================================================
SELECT customer_id, nickname,
       LENGTH(nickname)              AS len_nickname,
       LENGTH('  hello  ')           AS len_literal_padded,   -- 9 (앞2+hello5+뒤2)
       LENGTH(RTRIM(' '))            AS len_rtrim_space,       -- NULL (RTRIM(' ')='' → Oracle에서 NULL 취급)
       LENGTH('a')                   AS len_single_char        -- 1
FROM null_lab_customer
WHERE customer_id IN (1, 2, 3, 4, 8)
ORDER BY customer_id;
-- 예상: customer_id=2,3,8 → len_nickname = NULL (2,8은 원래 NULL, 3은 ''이
-- Oracle 저장 시 NULL로 바뀌었으므로). customer_id=4(공백 ' ') → len_nickname=1.
-- len_literal_padded/len_rtrim_space/len_single_char는 행과 무관하게 항상 같은 값 —
-- LENGTH 자체의 동작을 보여주기 위한 상수 표현식이다.

-- =====================================================================
-- STEP 4. TRIM / LTRIM / RTRIM과 NULL — TRIM(NULL)은 NULL이고, Oracle에서
--   TRIM(' ')처럼 공백만 남는 트림 결과는 빈 문자열이 되어 다시 NULL 취급된다.
-- =====================================================================
SELECT customer_id, nickname,
       TRIM(nickname)  AS trim_nickname,
       LTRIM(nickname) AS ltrim_nickname,
       RTRIM(nickname) AS rtrim_nickname
FROM null_lab_customer
WHERE customer_id IN (2, 3, 4, 8)
ORDER BY customer_id;
-- 예상: customer_id=2,3,8 → 세 컬럼 모두 NULL(TRIM(NULL)=NULL).
-- customer_id=4(nickname=' ') → TRIM/LTRIM/RTRIM 모두 공백을 제거한 결과가
-- ''이 되고, Oracle은 이 ''도 저장 여부와 무관하게 표현식 결과에서 NULL로
-- 취급한다 — 그래서 4행도 세 컬럼 모두 NULL로 나온다. "공백 한 칸은 트림하면
-- NULL이 아니라 빈 문자열이 남을 것"이라는 착각이 Oracle에서는 틀린다.
