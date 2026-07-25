-- Olist 고객 데이터 기본 탐색 (SQL Server)
-- 실행 상태: 실제 SQL Server 검증 필요 (이 세션에는 SQL Server 실행 환경이 없음)
-- 원본: olist_customers_dataset.csv (99,441행, 00-데이터사전/README.md 근거)

-- ── 1) CSV 적재 이후의 테이블 DDL ──────────────────────────────────────────
IF OBJECT_ID('customers_raw', 'U') IS NOT NULL DROP TABLE customers_raw;

CREATE TABLE customers_raw (
    customer_id               VARCHAR(32),
    customer_unique_id        VARCHAR(32),
    customer_zip_code_prefix  VARCHAR(5),   -- 반드시 문자형: 선행 0 보존
    customer_city              VARCHAR(60),
    customer_state              VARCHAR(2)
);

-- 실제 CSV 적재 방법(문법 예시 - 이 세션에서 실행하지 않음, 실제 SQL Server 서버 필요):
--   BULK INSERT customers_raw
--   FROM 'C:\data\olist_customers_dataset.csv'
--   WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n');
-- zip 컬럼을 반드시 VARCHAR로 선언한 뒤 적재해야 한다 - INT로 선언하면 BULK INSERT
-- 단계에서 이미 선행 0이 사라진다(Oracle SQL*Loader도 동일한 주의가 필요).

-- ── 2) 고객 ID / 고유 고객 ID 자료형과 유일성 ─────────────────────────────
SELECT
    COUNT(*)                            AS total_rows,
    COUNT(DISTINCT customer_id)         AS unique_customer_id,
    COUNT(DISTINCT customer_unique_id)  AS unique_customer_unique_id
FROM customers_raw;

-- ── 3) 우편번호 접두사의 문자형 보존 확인 ─────────────────────────────────
SELECT
    COUNT(*) AS total_zip,
    SUM(CASE WHEN customer_zip_code_prefix LIKE '0%' THEN 1 ELSE 0 END) AS starts_with_zero
FROM customers_raw;
-- 정수로 캐스팅했다가 되돌리면 자릿수가 사라지는 것을 직접 보여주는 쿼리
SELECT TOP 5
       customer_zip_code_prefix,
       CAST(CAST(customer_zip_code_prefix AS INT) AS VARCHAR) AS after_int_roundtrip
FROM customers_raw
WHERE customer_zip_code_prefix LIKE '0%';

-- ── 4) 도시·주별 고객 수 ───────────────────────────────────────────────
SELECT TOP 10 customer_state, COUNT(*) AS n_customers
FROM customers_raw
GROUP BY customer_state
ORDER BY n_customers DESC;

-- ── 5) 중복 고객(재구매) 탐색: customer_unique_id 반복분포 ────────────────
SELECT n_customer_id_per_unique, COUNT(*) AS n_unique_customers
FROM (
    SELECT customer_unique_id, COUNT(*) AS n_customer_id_per_unique
    FROM customers_raw
    GROUP BY customer_unique_id
) t
GROUP BY n_customer_id_per_unique
ORDER BY n_customer_id_per_unique;
