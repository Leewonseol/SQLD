-- 02-NULL치환함수: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 안 씀).

-- =====================================================================
-- STEP 1. 기본 치환 — NVL / COALESCE 비교
--   purchase_amt(NUMBER)은 customer_id 5, 11행이 NULL.
--   nickname(VARCHAR2)은 customer_id 2, 3(저장 시 NULL로 변환됨), 8행이 NULL.
-- =====================================================================
SELECT customer_id,
       purchase_amt,
       NVL(purchase_amt, 0)          AS nvl_purchase_amt,
       COALESCE(purchase_amt, 0)     AS coalesce_purchase_amt
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: 5, 11행만 0으로 치환되고 나머지는 원래 값 그대로. NVL과 COALESCE
-- 결과는 이 경우 완전히 같다 — NVL은 인수가 딱 2개인 COALESCE의 특수형이다.

SELECT customer_id,
       nickname,
       NVL(nickname, '별명없음')      AS nvl_nickname,
       COALESCE(nickname, '별명없음') AS coalesce_nickname
FROM null_lab_customer
ORDER BY customer_id;
-- 예상(Oracle): customer_id 2, 3, 8행이 '별명없음'으로 치환된다(3행은 ''이
-- Oracle에서 이미 NULL로 저장되었기 때문 — 01 폴더 참고).

-- =====================================================================
-- STEP 2. NVL2 (Oracle 전용) — expr이 NULL이 아니면 두 번째 인수,
--   NULL이면 세 번째 인수를 반환한다. NVL과 달리 "NULL 여부에 따라
--   완전히 다른 두 값"을 지정할 수 있다.
-- =====================================================================
SELECT customer_id,
       score,
       NVL2(score, 'SCORE_있음', 'SCORE_없음') AS nvl2_score_status,
       NVL2(score, score * 10, -1)             AS nvl2_score_scaled
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: score가 NULL인 3, 9행만 'SCORE_없음'/-1, 나머지는 'SCORE_있음'/(score*10).
-- SQL Server에는 NVL2가 없어 CASE WHEN으로 직접 구현해야 한다(sqlserver.sql STEP 2 참고).

-- =====================================================================
-- STEP 3. CASE WHEN으로 NVL을 직접 구현 — 결과가 완전히 같음을 확인
--   (SQLD에서 "NVL/COALESCE는 CASE WHEN의 축약형"이라는 것을 자주 묻는다)
-- =====================================================================
SELECT customer_id,
       purchase_amt,
       NVL(purchase_amt, 0) AS nvl_result,
       CASE WHEN purchase_amt IS NULL THEN 0 ELSE purchase_amt END AS case_when_result
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: nvl_result와 case_when_result가 모든 행에서 완전히 같다.

-- =====================================================================
-- STEP 4. NULLIF(expr1, expr2) — expr1 = expr2이면 NULL, 아니면 expr1 반환.
--   age=0인 4행, score=0인 6행으로 확인. "0을 결측 취급하고 싶을 때" 자주 쓰인다.
-- =====================================================================
SELECT customer_id,
       age,
       NULLIF(age, 0) AS nullif_age
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=4(age=0)만 NULL로 바뀌고 나머지는 원래 age 그대로
-- (customer_id=5는 원래부터 age가 NULL이라 NULLIF를 거쳐도 그대로 NULL).

SELECT customer_id,
       score,
       NULLIF(score, 0) AS nullif_score
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=6(score=0)만 NULL로 바뀐다.

-- =====================================================================
-- STEP 5. 짧은 VARCHAR2 컬럼 + 긴 대체 문자열
--   membership_code는 VARCHAR2(5)이며 이 데이터셋에는 실제 NULL 행이 없으므로,
--   "membership_code가 NULL이었다면"을 CAST(NULL AS VARCHAR2(5))로 시뮬레이션한다.
--   SELECT 목록에서 COALESCE 결과 컬럼은 폭 제한이 없어 긴 문자열도 그대로
--   반환되지만, 그 결과를 VARCHAR2(5) 컬럼에 INSERT하려고 하면 에러가 난다.
-- =====================================================================
SELECT customer_id,
       COALESCE(CAST(NULL AS VARCHAR2(5)), '정보없음(장기미접속)') AS memo_demo,
       LENGTH(COALESCE(CAST(NULL AS VARCHAR2(5)), '정보없음(장기미접속)')) AS memo_len
FROM null_lab_customer
WHERE customer_id = 5;
-- 예상: memo_demo='정보없음(장기미접속)', memo_len=11(문자 수 기준) — SELECT는 에러 없이 성공.

DROP TABLE null_lab_memo_staging;

CREATE TABLE null_lab_memo_staging (
    customer_id NUMBER,
    memo        VARCHAR2(5)   -- membership_code와 동일한 폭
);

-- *** 아래 INSERT는 실행하면 에러 발생 예상: ORA-12899: value too large for
--     column "null_lab_memo_staging"."MEMO" (actual: <문자 수 11보다 큰 바이트 수>,
--     maximum: 5) — VARCHAR2(5)는 기본적으로 바이트 단위 길이이고 한글은
--     멀티바이트(AL32UTF8 기준 글자당 3바이트)라 실제 바이트 수는 문자 수보다
--     훨씬 크게 잡힌다. ***
INSERT INTO null_lab_memo_staging (customer_id, memo)
SELECT customer_id, COALESCE(CAST(NULL AS VARCHAR2(5)), '정보없음(장기미접속)')
FROM null_lab_customer
WHERE customer_id = 5;

-- =====================================================================
-- STEP 6. 정수 컬럼 + 소수 리터럴 혼합 — 결과 자료형 승격
--   score는 NUMBER(정밀도 지정 없음)라 Oracle에서는 원래도 소수를 담을 수
--   있다. 그래서 승격이 "보이지" 않는다 — COALESCE(score,0.5)/2로 나눗셈
--   결과를 보면 Oracle NUMBER는 애초에 정수/소수 구분이 없다는 것 자체가
--   SQL Server(정수 INT 컬럼)와의 핵심 차이임을 확인할 수 있다(7절 참고).
-- =====================================================================
SELECT customer_id,
       score,
       COALESCE(score, 0.5)       AS coalesced_score,
       COALESCE(score, 0.5) / 2   AS coalesced_score_div2
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: score=85인 1행 → coalesced_score_div2=42.5(Oracle NUMBER는 항상
-- 소수 나눗셈). score가 NULL인 3, 9행 → coalesced_score=0.5, div2=0.25.

-- =====================================================================
-- STEP 7. 숫자 컬럼 + 문자열 컬럼 혼합 — 암시적 변환
--   (1) COALESCE(age, membership_code): age가 NULL인 행은 customer_id=5뿐이고
--       그 행의 membership_code는 '0'(숫자로 변환 가능)이라 이 데이터셋에서는
--       우연히 에러 없이 성공한다.
-- =====================================================================
SELECT customer_id,
       age,
       membership_code,
       COALESCE(age, membership_code) AS coalesced_age
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=5만 membership_code='0'이 NUMBER 0으로 변환되어
-- coalesced_age=0. 나머지는 원래 age. Oracle이 COALESCE(NUMBER, VARCHAR2)의
-- 반환형을 NUMBER로 고정하기 때문에(NUMBER가 VARCHAR2보다 데이터 타입
-- 우선순위가 높음) membership_code를 NUMBER로 암시적 변환하려 시도한 것 —
-- 여기서는 '0'이 변환 가능해서 에러가 나지 않았을 뿐이다.

--   (2) 같은 패턴을 dept_code로 바꾸면 실제 에러가 난다 — customer_id=5의
--       dept_code='D01'은 NUMBER로 변환할 수 없는 값이기 때문이다.
-- *** 아래 SELECT는 실행하면 에러 발생 예상: ORA-01722: invalid number ***
SELECT customer_id,
       age,
       dept_code,
       COALESCE(age, dept_code) AS coalesced_age_deptcode
FROM null_lab_customer
ORDER BY customer_id;

-- =====================================================================
-- STEP 8. 날짜 컬럼 + 문자열 리터럴 혼합
--   join_date(DATE)가 NULL인 customer_id=3, 11행에 문자열 '정보없음'을
--   그대로 COALESCE하면 Oracle이 '정보없음'을 DATE로 변환하려다 실패한다.
-- =====================================================================
-- *** 아래 SELECT는 실행하면 에러 발생 예상:
--     ORA-01858 또는 ORA-01861(literal does not match format string) ***
SELECT customer_id,
       join_date,
       COALESCE(join_date, '정보없음') AS wrong_coalesced_date
FROM null_lab_customer
ORDER BY customer_id;

-- 올바른 방법: 날짜를 먼저 문자열로 변환(TO_CHAR)한 뒤 COALESCE한다.
SELECT customer_id,
       join_date,
       COALESCE(TO_CHAR(join_date, 'YYYY-MM-DD'), '정보없음') AS correct_coalesced_date
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=3, 11행만 '정보없음', 나머지는 'YYYY-MM-DD' 형식 문자열.

-- =====================================================================
-- STEP 9. Oracle에는 ISNULL이 없다 — 참고용으로 NVL로 동일 로직을 재확인.
--   (ISNULL의 반환형이 "첫 번째 인수 기준으로 고정"되는 SQL Server 고유
--   특성은 sqlserver.sql STEP 9에서 직접 확인한다.)
-- =====================================================================
SELECT customer_id,
       membership_code,
       NVL(membership_code, '정보없음(장기미접속)') AS nvl_membership_demo
FROM null_lab_customer
WHERE customer_id = 5;
-- 참고: membership_code는 이 행에서 NULL이 아니라 '0'이므로 결과는 그대로 '0'.
-- Oracle의 NVL도 COALESCE와 마찬가지로 반환형이 인수들의 데이터 타입 우선순위로
-- 결정되며(VARCHAR2끼리라 문제 없음), SQL Server ISNULL처럼 "1번째 인수의
-- 폭에 맞춰 자른다"는 개념 자체가 Oracle에는 없다.
