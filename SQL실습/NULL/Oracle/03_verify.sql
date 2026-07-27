-- NULL 결과 검산 (Oracle)
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
-- 순서: 01_prepare.sql -> 02_examples.sql -> 02_validate.py -> 이 파일.

-- =====================================================================
-- A-1) SQL 자체 PASS/FAIL 재계산 (Python 없이도 확인 가능)
-- =====================================================================
SELECT
    e.example_id,
    e.concept,
    e.expected_row_count,
    r.actual_row_count,
    e.expected_numeric_value,
    r.actual_numeric_value,
    CASE
        WHEN r.example_id IS NULL THEN 'NO_RESULT'
        WHEN e.expected_row_count IS NOT NULL AND r.actual_row_count <> e.expected_row_count THEN 'FAIL'
        WHEN e.expected_numeric_value IS NOT NULL
             AND (r.actual_numeric_value IS NULL
                  OR ABS(r.actual_numeric_value - e.expected_numeric_value) > 0.000001) THEN 'FAIL'
        ELSE 'PASS'
    END AS sql_side_status
FROM sql_example_expectation e
LEFT JOIN sql_example_result r ON e.example_id = r.example_id
ORDER BY e.example_id;

-- =====================================================================
-- A-2) SQL 자체 PASS/FAIL 집계
-- =====================================================================
SELECT
    SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END) AS pass_count,
    SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END) AS fail_count,
    COUNT(*) AS total_count
FROM (
    SELECT
        CASE
            WHEN r.example_id IS NULL THEN 'NO_RESULT'
            WHEN e.expected_row_count IS NOT NULL AND r.actual_row_count <> e.expected_row_count THEN 'FAIL'
            WHEN e.expected_numeric_value IS NOT NULL
                 AND (r.actual_numeric_value IS NULL
                      OR ABS(r.actual_numeric_value - e.expected_numeric_value) > 0.000001) THEN 'FAIL'
            ELSE 'PASS'
        END AS status
    FROM sql_example_expectation e
    LEFT JOIN sql_example_result r ON e.example_id = r.example_id
);

-- =====================================================================
-- B-1) 02_validate.py(Python)가 적재한 PASS/FAIL 집계
-- =====================================================================
SELECT status, COUNT(*) AS cnt
FROM sql_example_validation
GROUP BY status
ORDER BY status;

-- =====================================================================
-- B-2) 실패 예제만 조회 (있다면)
-- =====================================================================
SELECT example_id, status, expected_value, actual_value, validation_message
FROM sql_example_validation
WHERE status = 'FAIL'
ORDER BY example_id;

-- =====================================================================
-- 핵심 결과값 재검산 (필기 개념과 직접 대조)
-- =====================================================================

-- N19: 0행 집계에서도 COUNT(*)/COUNT(열)은 0, SUM/AVG/MAX/MIN은 NULL인지 직접 확인
SELECT COUNT(*) AS cnt_star, COUNT(total_spent) AS cnt_col,
       SUM(total_spent) AS sum_val, AVG(total_spent) AS avg_val,
       MAX(total_spent) AS max_val, MIN(total_spent) AS min_val
FROM customer_order_summary WHERE total_spent > 1000;

-- N22: 서브쿼리 NOT IN 함정 - CUSTOMER_FLAG_EXCLUDE에 NULL이 있는지,
-- CUSTOMER_FLAG_CHECK 각 값이 왜 하나도 안 나오는지 직접 재현
SELECT b.flag_val,
       (SELECT COUNT(*) FROM customer_flag_exclude x WHERE x.flag_val = b.flag_val) AS matched_non_null,
       (SELECT COUNT(*) FROM customer_flag_exclude x WHERE x.flag_val IS NULL) AS null_in_list
FROM customer_flag_check b
ORDER BY b.flag_val;

-- N35: UNIQUE + NULL - 실제로 CODE가 NULL인 행이 몇 개 저장됐는지 확인
SELECT COUNT(*) AS null_code_rows FROM customer_code WHERE code IS NULL;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 Oracle 전용 -> SQLServer/03_verify.sql과 대조할 것)
-- =====================================================================
-- N01,N02: Oracle은 빈 문자열을 NULL로 저장하므로 IS NULL count가
--   SQL Server보다 1 많다(2 vs 1). N02(TXT='')도 Oracle은 항상 0건.
-- N03,N03B: Oracle LENGTH(' ')=1. SQL Server는 LEN(' ')=0(트레일링 공백 제거),
--   DATALENGTH(' ')=1로 나뉜다 - Oracle에는 그 구분 자체가 없다.
-- N24,N25: Oracle은 NVL만 있고 ISNULL이 없다. SQL Server는 ISNULL만 있고
--   NVL이 없다 - N24/N25 두 예제 모두 "미지원 함수는 쓰지 않고 동일 기능의
--   자기 DBMS 함수로 대체"했다는 점을 확인할 것.
-- N32,N32B: Oracle ASC 기본은 NULL 마지막(N32=3), DESC 기본은 NULL 처음(N32B=1).
--   SQL Server는 정반대(ASC=1, DESC=3) - 03_verify.sql이 아니라
--   02_examples.sql의 실제 순위 값 자체가 다르다.
-- N35: Oracle은 UNIQUE 컬럼에 NULL을 여러 개 허용(3행). SQL Server는 NULL을
--   1개만 허용(2행) - expected_row_count 자체가 DBMS마다 다르다.
