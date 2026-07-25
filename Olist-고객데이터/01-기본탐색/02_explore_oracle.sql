-- Olist 고객 데이터 기본 탐색 (Oracle)
-- 실행 상태: 실제 Oracle 검증 필요 (이 세션에는 Oracle 실행 환경이 없음)
-- 원본: olist_customers_dataset.csv (99,441행, 00-데이터사전/README.md 근거)

-- ── 1) CSV 적재 이후의 테이블 DDL ──────────────────────────────────────────
-- customer_id/customer_unique_id는 32자리 16진수 해시 문자열, zip은 5자리
-- 숫자'처럼 보이는' 문자열이지만 지역 식별 코드이므로 반드시 문자형으로 선언한다.
DROP TABLE customers_raw;

CREATE TABLE customers_raw (
    customer_id               VARCHAR2(32),
    customer_unique_id        VARCHAR2(32),
    customer_zip_code_prefix  VARCHAR2(5),
    customer_city             VARCHAR2(60),
    customer_state            VARCHAR2(2)
);

-- 실제 CSV 적재 방법(문법 예시 - 이 세션에서 실행하지 않음, 실제 Oracle 서버 필요):
--   SQL*Loader 제어파일(customers.ctl) 예시
--   LOAD DATA
--   INFILE 'olist_customers_dataset.csv'
--   INTO TABLE customers_raw
--   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--   TRAILING NULLCOLS
--   (customer_id, customer_unique_id, customer_zip_code_prefix CHAR,
--    customer_city, customer_state)
--   -- 실행: sqlldr userid=.../... control=customers.ctl skip=1
-- 또는 외부 테이블(ORACLE_LOADER) 방식도 가능하나 여기서는 문법 참고용으로만 남긴다.

-- ── 2) 고객 ID / 고유 고객 ID 자료형과 유일성 ─────────────────────────────
SELECT
    COUNT(*)                           AS total_rows,
    COUNT(DISTINCT customer_id)        AS unique_customer_id,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_id
FROM customers_raw;

-- ── 3) 우편번호 접두사의 문자형 보존 확인 ─────────────────────────────────
-- 선행 0으로 시작하는 zip이 있는지, 있다면 문자형 유지가 왜 필수인지 직접 확인
SELECT
    COUNT(*) AS total_zip,
    SUM(CASE WHEN customer_zip_code_prefix LIKE '0%' THEN 1 ELSE 0 END) AS starts_with_zero
FROM customers_raw;
-- 정수로 캐스팅했다가 되돌리면 자릿수가 사라지는 것을 직접 보여주는 쿼리
SELECT customer_zip_code_prefix,
       TO_CHAR(TO_NUMBER(customer_zip_code_prefix)) AS after_number_roundtrip
FROM customers_raw
WHERE customer_zip_code_prefix LIKE '0%'
FETCH FIRST 5 ROWS ONLY;

-- ── 4) 도시·주별 고객 수 ───────────────────────────────────────────────
SELECT customer_state, COUNT(*) AS n_customers
FROM customers_raw
GROUP BY customer_state
ORDER BY n_customers DESC
FETCH FIRST 10 ROWS ONLY;

-- ── 5) 중복 고객(재구매) 탐색: customer_unique_id 반복분포 ────────────────
SELECT n_customer_id_per_unique, COUNT(*) AS n_unique_customers
FROM (
    SELECT customer_unique_id, COUNT(*) AS n_customer_id_per_unique
    FROM customers_raw
    GROUP BY customer_unique_id
)
GROUP BY n_customer_id_per_unique
ORDER BY n_customer_id_per_unique;
