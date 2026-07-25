-- 02-NULL치환함수: 공통 데이터셋(00과 동일, 자기완결 실행을 위해 복사)
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
-- 있어 예상과 다르게 0행이 된다 — 08 폴더 핵심 실습(이 폴더에서는 안 씀).

-- =====================================================================
-- STEP 1. 기본 치환 — ISNULL / COALESCE 비교
--   purchase_amt(DECIMAL)은 customer_id 5, 11행이 NULL.
--   nickname(VARCHAR)은 customer_id 2, 8행이 NULL(3행은 SQL Server에서
--   ''으로 남아 있어 NULL이 아니다 — Oracle과 정반대, 01 폴더 참고).
-- =====================================================================
SELECT customer_id,
       purchase_amt,
       ISNULL(purchase_amt, 0)       AS isnull_purchase_amt,
       COALESCE(purchase_amt, 0)     AS coalesce_purchase_amt
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: 5, 11행만 0으로 치환되고 나머지는 원래 값 그대로. ISNULL과 COALESCE
-- 결과는 이 경우 완전히 같다.

SELECT customer_id,
       nickname,
       ISNULL(nickname, '별명없음')      AS isnull_nickname,
       COALESCE(nickname, '별명없음')    AS coalesce_nickname
FROM null_lab_customer
ORDER BY customer_id;
-- 예상(SQL Server): customer_id 2, 8행만 '별명없음'으로 치환된다. 3행은
-- nickname=''(빈 문자열, NULL 아님)이라 그대로 ''로 남는다 — Oracle과
-- 정반대(Oracle 버전에서는 3행도 치환됨, oracle.sql STEP 1 참고).

-- =====================================================================
-- STEP 2. SQL Server에는 NVL2가 없다 — CASE WHEN으로 직접 구현한다.
--   (Oracle의 oracle.sql STEP 2와 로직·예상 결과 동일)
-- =====================================================================
SELECT customer_id,
       score,
       CASE WHEN score IS NOT NULL THEN 'SCORE_있음' ELSE 'SCORE_없음' END AS nvl2_style_score_status,
       CASE WHEN score IS NOT NULL THEN score * 10 ELSE -1 END            AS nvl2_style_score_scaled
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: score가 NULL인 3, 9행만 'SCORE_없음'/-1, 나머지는 'SCORE_있음'/(score*10).
-- Oracle의 NVL2(score, score*10, -1)와 결과가 완전히 같다.

-- =====================================================================
-- STEP 3. CASE WHEN으로 ISNULL을 직접 구현 — 결과가 완전히 같음을 확인
-- =====================================================================
SELECT customer_id,
       purchase_amt,
       ISNULL(purchase_amt, 0) AS isnull_result,
       CASE WHEN purchase_amt IS NULL THEN 0 ELSE purchase_amt END AS case_when_result
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: isnull_result와 case_when_result가 모든 행에서 완전히 같다.

-- =====================================================================
-- STEP 4. NULLIF(expr1, expr2) — expr1 = expr2이면 NULL, 아니면 expr1 반환.
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
-- STEP 5. 짧은 VARCHAR 컬럼 + 긴 대체 문자열
--   membership_code는 VARCHAR(5)이며 이 데이터셋에는 실제 NULL 행이 없으므로,
--   "membership_code가 NULL이었다면"을 CAST(NULL AS VARCHAR(5))로 시뮬레이션한다.
--   SELECT 목록에서는 COALESCE 결과 타입이 자동으로 넓어져(VARCHAR(5) →
--   VARCHAR(N)) 에러 없이 긴 문자열이 그대로 나오지만, 그 결과를 VARCHAR(5)
--   컬럼에 INSERT하려고 하면 에러가 난다.
-- =====================================================================
SELECT customer_id,
       COALESCE(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)') AS memo_demo,
       LEN(COALESCE(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')) AS memo_len
FROM null_lab_customer
WHERE customer_id = 5;
-- 예상: memo_demo='정보없음(장기미접속)', memo_len=11(문자 수 기준) — SELECT는 에러 없이 성공.

IF OBJECT_ID('null_lab_memo_staging', 'U') IS NOT NULL DROP TABLE null_lab_memo_staging;

CREATE TABLE null_lab_memo_staging (
    customer_id INT,
    memo        VARCHAR(5)   -- membership_code와 동일한 폭
);

-- *** 아래 INSERT는 실행하면 에러 발생 예상:
--     String or binary data would be truncated in table
--     'null_lab_memo_staging', column 'memo'. Truncated value: '정보없...' ***
INSERT INTO null_lab_memo_staging (customer_id, memo)
SELECT customer_id, COALESCE(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')
FROM null_lab_customer
WHERE customer_id = 5;

-- =====================================================================
-- STEP 6. 정수 컬럼 + 소수 리터럴 혼합 — 결과 자료형 승격
--   score는 INT로 선언되어 있어(00/01 폴더와 동일 스키마) Oracle의 NUMBER와
--   달리 정수/소수 구분이 뚜렷하다. COALESCE(score, 0.5)에 소수 리터럴이
--   섞이면 SQL Server는 데이터 타입 우선순위 규칙에 따라 결과 전체를
--   decimal로 승격한다 — INT였다면 나눗셈에서 소수부가 잘렸을 값이 승격 후엔
--   그대로 살아남는다.
-- =====================================================================
SELECT customer_id,
       score,
       score / 2                       AS raw_int_div2,          -- 승격 전: 정수 나눗셈(소수부 버림)
       COALESCE(score, 0.5)            AS coalesced_score,
       COALESCE(score, 0.5) / 2        AS coalesced_score_div2   -- 승격 후: decimal 나눗셈
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=1(score=85) → raw_int_div2=42(정수 나눗셈, 소수부 버림),
-- coalesced_score_div2=42.500000(decimal로 승격되어 소수부가 살아남음).
-- score가 NULL인 3, 9행 → raw_int_div2=NULL, coalesced_score=0.50,
-- coalesced_score_div2=0.250000. Oracle에서는 NUMBER가 원래 정수/소수
-- 구분이 없어 이 대비가 나타나지 않는다(oracle.sql STEP 6 주석 참고).

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
-- 예상: customer_id=5만 membership_code='0'이 INT 0으로 변환되어
-- coalesced_age=0. 나머지는 원래 age. SQL Server 데이터 타입 우선순위에서
-- int가 varchar보다 높기 때문에 COALESCE(int, varchar)의 결과 타입은 int로
-- 고정되고, membership_code를 int로 암시적 변환하려 시도한 것 — 여기서는
-- '0'이 변환 가능해서 에러가 나지 않았을 뿐이다.

--   (2) 같은 패턴을 dept_code로 바꾸면 실제 에러가 난다 — customer_id=5의
--       dept_code='D01'은 int로 변환할 수 없는 값이기 때문이다.
-- *** 아래 SELECT는 실행하면 에러 발생 예상:
--     Conversion failed when converting the varchar value 'D01' to data type int. ***
SELECT customer_id,
       age,
       dept_code,
       COALESCE(age, dept_code) AS coalesced_age_deptcode
FROM null_lab_customer
ORDER BY customer_id;

-- =====================================================================
-- STEP 8. 날짜 컬럼 + 문자열 리터럴 혼합
--   join_date(DATE)가 NULL인 customer_id=3, 11행에 문자열 '정보없음'을
--   그대로 COALESCE하면 SQL Server가 '정보없음'을 DATE로 변환하려다 실패한다.
-- =====================================================================
-- *** 아래 SELECT는 실행하면 에러 발생 예상:
--     Conversion failed when converting date and/or time from character string. ***
SELECT customer_id,
       join_date,
       COALESCE(join_date, '정보없음') AS wrong_coalesced_date
FROM null_lab_customer
ORDER BY customer_id;

-- 올바른 방법: 날짜를 먼저 문자열로 변환(CONVERT ... 스타일 120 = ODBC 표준,
-- 'YYYY-MM-DD')한 뒤 COALESCE한다.
SELECT customer_id,
       join_date,
       COALESCE(CONVERT(VARCHAR(10), join_date, 120), '정보없음') AS correct_coalesced_date
FROM null_lab_customer
ORDER BY customer_id;
-- 예상: customer_id=3, 11행만 '정보없음', 나머지는 'YYYY-MM-DD' 형식 문자열.

-- =====================================================================
-- STEP 9. ISNULL의 반환형은 "첫 번째 인수 기준으로 고정"된다(공식 문서 근거).
--   COALESCE는 인수들 중 데이터 타입 우선순위가 가장 높은 것으로 승격되는
--   반면, ISNULL(expr, replacement)의 결과 타입/길이는 expr(첫 번째 인수)을
--   그대로 따른다 — 그래서 replacement가 더 길어도 잘릴 수 있다.
-- =====================================================================
SELECT
    ISNULL(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')    AS isnull_truncated,
    LEN(ISNULL(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')) AS isnull_truncated_len,
    COALESCE(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')   AS coalesce_widened,
    LEN(COALESCE(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')) AS coalesce_widened_len;
-- 예상: isnull_truncated는 첫 인수 VARCHAR(5) 폭에 맞춰 앞 5글자 '정보없음('로
-- 조용히 잘리고 isnull_truncated_len=5. coalesce_widened는 자르지 않고
-- '정보없음(장기미접속)' 전체(11자)가 그대로 나와 coalesce_widened_len=11.
-- 에러 없이 "조용히 잘린다"는 점이 COALESCE와의 결정적 차이이자 SQLD 함정이다.
