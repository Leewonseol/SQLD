-- NULL 결과 검산 (SQL Server)
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
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
) t;

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
-- 핵심 결과값 재검산
-- =====================================================================

-- N19: 0행 집계에서도 COUNT(*)/COUNT(열)은 0, SUM/AVG/MAX/MIN은 NULL인지 직접 확인
SELECT COUNT(*) AS cnt_star, COUNT(total_spent) AS cnt_col,
       SUM(total_spent) AS sum_val, AVG(total_spent) AS avg_val,
       MAX(total_spent) AS max_val, MIN(total_spent) AS min_val
FROM customer_order_summary WHERE total_spent > 1000;

-- N22: 서브쿼리 NOT IN 함정 재현
SELECT b.flag_val,
       (SELECT COUNT(*) FROM customer_flag_exclude x WHERE x.flag_val = b.flag_val) AS matched_non_null,
       (SELECT COUNT(*) FROM customer_flag_exclude x WHERE x.flag_val IS NULL) AS null_in_list
FROM customer_flag_check b
ORDER BY b.flag_val;

-- N35: UNIQUE + NULL - 실제로 CODE가 NULL인 행이 몇 개 저장됐는지 확인(1개만 허용됨)
SELECT COUNT(*) AS null_code_rows FROM customer_code WHERE code IS NULL;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 SQL Server 전용 -> Oracle/03_verify.sql과 대조할 것)
-- =====================================================================
-- N01,N02: SQL Server는 ''와 NULL을 구분하므로 IS NULL count=1(id2만),
--   TXT=''는 id3에서 TRUE가 되어 1건. Oracle은 각각 2건, 0건이었다.
-- N03,N03B: SQL Server는 LEN(' ')=0(뒤쪽 공백 제거)과 DATALENGTH(' ')=1
--   (실제 바이트)로 나뉜다. Oracle은 LENGTH(' ')=1 하나로 통일돼 있었다.
-- N24,N25: SQL Server는 ISNULL만 있고 NVL이 없다. Oracle은 정반대다 -
--   두 예제 모두 "미지원 함수 대신 자기 DBMS 함수로 동일 기능 구현"을 확인.
-- N32,N32B: SQL Server ASC 기본은 NULL 처음(N32=1), DESC 기본은 NULL
--   마지막(N32B=3) - Oracle과 정반대 순서다.
-- N35: SQL Server는 UNIQUE 컬럼에 NULL을 1개만 허용(2행). Oracle은 여러 개
--   허용(3행) - expected_row_count 자체가 다르다.
