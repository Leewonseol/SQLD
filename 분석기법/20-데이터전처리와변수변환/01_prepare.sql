-- 데이터 전처리 입력 준비: 중앙값/백분위수 계산 -> 결측치 대체 -> 이상치 capping -> 범주/날짜 정리
-- SQLite에는 MEDIAN/PERCENTILE_CONT가 없으므로 ROW_NUMBER() + COUNT() 윈도우함수로 직접 구현한다.
-- (Oracle: MEDIAN(x), PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x))

DROP TABLE IF EXISTS income_stats;
CREATE TABLE income_stats AS
WITH ordered AS (
    SELECT income_raw,
           ROW_NUMBER() OVER (ORDER BY income_raw) AS rn,
           COUNT(*) OVER () AS n
    FROM raw_customer_intake
    WHERE income_raw IS NOT NULL
)
SELECT
    AVG(CASE WHEN rn IN ((n+1)/2, (n+2)/2) THEN income_raw END) AS median,
    MAX(CASE WHEN rn = CAST(0.05*n AS INT)+1 THEN income_raw END) AS p05,
    MAX(CASE WHEN rn = CAST(0.95*n AS INT)+1 THEN income_raw END) AS p95
FROM ordered;

DROP TABLE IF EXISTS age_stats;
CREATE TABLE age_stats AS
WITH ordered AS (
    SELECT age_raw,
           ROW_NUMBER() OVER (ORDER BY age_raw) AS rn,
           COUNT(*) OVER () AS n
    FROM raw_customer_intake
    WHERE age_raw IS NOT NULL
)
SELECT
    AVG(CASE WHEN rn IN ((n+1)/2, (n+2)/2) THEN age_raw END) AS median,
    MAX(CASE WHEN rn = CAST(0.05*n AS INT)+1 THEN age_raw END) AS p05,
    MAX(CASE WHEN rn = CAST(0.95*n AS INT)+1 THEN age_raw END) AS p95
FROM ordered;

DROP TABLE IF EXISTS customer_clean;
CREATE TABLE customer_clean AS
SELECT
    r.customer_id,
    -- 결측치 대체(중앙값) 후 5~95백분위로 이상치 capping
    MAX(MIN(COALESCE(r.income_raw, i.median), i.p95), i.p05) AS income_clean,
    MAX(MIN(COALESCE(r.age_raw, a.median), a.p95), a.p05)    AS age_clean,
    -- 범주 표기 통일 (대소문자·약어 -> M/F/UNKNOWN)
    CASE
        WHEN UPPER(r.gender_raw) IN ('M', 'MALE')   THEN 'M'
        WHEN UPPER(r.gender_raw) IN ('F', 'FEMALE') THEN 'F'
        ELSE 'UNKNOWN'
    END AS gender_clean,
    -- 날짜 형식 통일 ('/' -> '-')
    REPLACE(r.signup_date_raw, '/', '-') AS signup_date_clean
FROM raw_customer_intake r
CROSS JOIN income_stats i
CROSS JOIN age_stats a;

-- 정제 전/후 결측치 개수 비교
SELECT
    (SELECT COUNT(*) FROM raw_customer_intake WHERE income_raw IS NULL) AS income_nulls_before,
    (SELECT COUNT(*) FROM customer_clean WHERE income_clean IS NULL)    AS income_nulls_after,
    (SELECT COUNT(*) FROM raw_customer_intake WHERE gender_raw IS NULL) AS gender_nulls_before,
    (SELECT COUNT(*) FROM customer_clean WHERE gender_clean = 'UNKNOWN') AS gender_unknown_after;
