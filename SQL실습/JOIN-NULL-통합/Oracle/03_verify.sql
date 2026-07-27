-- JOIN×NULL 통합 결과 검산 (Oracle)
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
-- 핵심 결과값 재검산 - JN05 vs JN06 대조가 이 실습의 핵심이다
-- =====================================================================

-- JN05/JN06 나란히 비교: 같은 질문("주문 없는 고객은 누구인가")에 대해
-- LEFT JOIN+IS NULL은 2명을 정확히 찾고, NOT IN은 고아 주문의 NULL 때문에
-- 0명이라는 잘못된 답을 낸다.
SELECT
    (SELECT COUNT(*) FROM customers c LEFT OUTER JOIN customer_orders o
        ON c.customer_id = o.customer_id WHERE o.order_id IS NULL) AS jn05_left_join_is_null_correct,
    (SELECT COUNT(*) FROM customers c
        WHERE c.customer_id NOT IN (SELECT o.customer_id FROM customer_orders o)) AS jn06_not_in_broken
FROM dual;

-- 고아 주문(O5)이 실제로 NULL customer_id를 갖고 있는지 직접 확인
SELECT * FROM customer_orders WHERE customer_id IS NULL;

-- JN01/JN13 대조: 같은 두 테이블(CUSTOMERS, REGION_LOOKUP)로 등가조인은
-- NULL 키를 제외하고(4행), CROSS JOIN은 그대로 15행이 나오는지 확인
SELECT
    (SELECT COUNT(*) FROM customers c JOIN region_lookup r ON c.sales_region = r.sales_region) AS jn01_equi_join,
    (SELECT COUNT(*) FROM customers CROSS JOIN region_lookup) AS jn13_cross_join
FROM dual;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 Oracle 전용 -> SQLServer/03_verify.sql과 대조할 것)
-- =====================================================================
-- JN11(USING): 이 Oracle 스크립트는 USING(SALES_REGION) 문법을 그대로 썼다.
--   SQLServer/02_examples.sql은 ON customers.sales_region=region_lookup.sales_region으로
--   동일한 결과(4행)를 낸다.
-- JN14(Oracle (+)): 이 스크립트는 (+) 구문으로 "반대편 필터에 (+) 누락"
--   함정을 재현했다. SQLServer/02_examples.sql은 애초에 (+) 자체가 없으므로
--   LEFT JOIN + WHERE 형태로만 같은 함정(JN04와 동일한 2행)을 보여준다.
-- 나머지 12개 예제는 순수 ANSI 문법이라 두 DBMS 결과가 완전히 같아야 한다 -
-- 다르면 위 A-1 쿼리의 FAIL로 바로 드러난다.
