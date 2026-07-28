-- JOIN×NULL 통합 결과 검산 (Oracle)
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
-- 순서: 01_prepare.sql -> 02_examples.sql -> 02_validate.py -> 이 파일.

-- =====================================================================
-- A-1) SQL 자체 PASS/FAIL/NO_RESULT 재계산 (Python 없이도 확인 가능)
--   NO_RESULT: sql_example_expectation에는 있지만 sql_example_result에
--   해당 example_id 행이 없는 경우(02_examples.sql 미실행 등). 집계에서
--   PASS/FAIL 어느 쪽에도 넣지 않고 별도로 센다.
-- =====================================================================
SELECT
    e.example_id,
    e.concept,
    e.expected_numeric_value,
    r.actual_numeric_value,
    e.expected_text_value,
    r.actual_text_value,
    CASE
        WHEN r.example_id IS NULL THEN 'NO_RESULT'
        WHEN e.expected_numeric_value IS NOT NULL
             AND (r.actual_numeric_value IS NULL
                  OR ABS(r.actual_numeric_value - e.expected_numeric_value) > 0.000001) THEN 'FAIL'
        WHEN e.expected_text_value IS NOT NULL
             AND NVL(r.actual_text_value, '~~NULL~~') <> e.expected_text_value THEN 'FAIL'
        ELSE 'PASS'
    END AS sql_side_status
FROM sql_example_expectation e
LEFT JOIN sql_example_result r ON e.example_id = r.example_id
ORDER BY e.example_id;

-- =====================================================================
-- A-2) SQL 자체 PASS/FAIL/NO_RESULT 집계 (섹션 8 규칙: NO_RESULT를 반드시
--   별도 카운트로 노출한다 - 전체 개수에는 포함되지만 PASS/FAIL 어느 쪽에도
--   들어가지 않는 상태를 방치하지 않는다)
-- =====================================================================
SELECT
    SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END) AS pass_count,
    SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END) AS fail_count,
    SUM(CASE WHEN status = 'NO_RESULT' THEN 1 ELSE 0 END) AS no_result_count,
    COUNT(*) AS total_count
FROM (
    SELECT
        CASE
            WHEN r.example_id IS NULL THEN 'NO_RESULT'
            WHEN e.expected_numeric_value IS NOT NULL
                 AND (r.actual_numeric_value IS NULL
                      OR ABS(r.actual_numeric_value - e.expected_numeric_value) > 0.000001) THEN 'FAIL'
            WHEN e.expected_text_value IS NOT NULL
                 AND NVL(r.actual_text_value, '~~NULL~~') <> e.expected_text_value THEN 'FAIL'
            ELSE 'PASS'
        END AS status
    FROM sql_example_expectation e
    LEFT JOIN sql_example_result r ON e.example_id = r.example_id
);

-- =====================================================================
-- B-1) 02_validate.py(Python)가 적재한 PASS/FAIL/NO_RESULT 집계
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
-- C) 메타모픽 검증 (섹션 8) - 개별 예제의 절대값이 아니라 "예제 사이의
--   관계"가 지켜지는지를 재확인한다. sql_example_result에 이미 적재된
--   actual_numeric_value끼리 비교하므로 02_examples.sql 실행 후에만 의미가 있다.
-- =====================================================================

-- C1) LEFT JOIN+IS NULL(JN05A) = NOT EXISTS(JN05B)
SELECT
    a.actual_numeric_value AS jn05a_left_join_is_null,
    b.actual_numeric_value AS jn05b_not_exists,
    CASE WHEN a.actual_numeric_value = b.actual_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result a, sql_example_result b
WHERE a.example_id = 'JN05A' AND b.example_id = 'JN05B';

-- C2) 위 두 결과 <> NULL이 포함된 NOT IN(JN05C) 결과
SELECT
    a.actual_numeric_value AS jn05a_correct,
    c.actual_numeric_value AS jn05c_not_in_broken,
    CASE WHEN a.actual_numeric_value <> c.actual_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result a, sql_example_result c
WHERE a.example_id = 'JN05A' AND c.example_id = 'JN05C';

-- C3) ON 필터 결과 행수(JN03A) > WHERE 필터 결과 행수(JN03B)
SELECT
    on_r.actual_numeric_value AS jn03a_on_filter,
    where_r.actual_numeric_value AS jn03b_where_filter,
    CASE WHEN on_r.actual_numeric_value > where_r.actual_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result on_r, sql_example_result where_r
WHERE on_r.example_id = 'JN03A' AND where_r.example_id = 'JN03B';

-- C4) COUNT(*)(JN04A) >= COUNT(우측 NOT NULL 키)(JN04B) >= COUNT(nullable 일반열)(JN04C)
SELECT
    star.actual_numeric_value AS jn04a_count_star,
    keycol.actual_numeric_value AS jn04b_count_key,
    genericcol.actual_numeric_value AS jn04c_count_generic,
    CASE WHEN star.actual_numeric_value >= keycol.actual_numeric_value
          AND keycol.actual_numeric_value >= genericcol.actual_numeric_value
         THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result star, sql_example_result keycol, sql_example_result genericcol
WHERE star.example_id = 'JN04A' AND keycol.example_id = 'JN04B' AND genericcol.example_id = 'JN04C';

-- C5) Oracle USING(JN10) 결과 = SQL Server 대응 ON 결과
--   (같은 example_id 'JN10'을 SQLServer/03_verify.sql에서도 조회해 값을 비교한다.
--   이 Oracle 세션 안에서는 자기 자신 값만 보여준다 - 두 DBMS 값을 실제로 맞대어
--   보려면 두 실행 결과를 사람이 나란히 놓고 비교해야 한다.)
SELECT example_id, actual_numeric_value AS oracle_jn10_using_result
FROM sql_example_result WHERE example_id = 'JN10';

-- C6) Oracle (+) 함정(JN14) 결과 = ANSI LEFT JOIN+WHERE 함정(JN03B) 결과
SELECT
    n14.actual_numeric_value AS jn14_oracle_plus_trap,
    n03b.actual_numeric_value AS jn03b_where_trap,
    CASE WHEN n14.actual_numeric_value = n03b.actual_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result n14, sql_example_result n03b
WHERE n14.example_id = 'JN14' AND n03b.example_id = 'JN03B';

-- C7) NULL 키 등가조인(JN01A) 결과 < CROSS JOIN(JN13) 결과
SELECT
    equi.actual_numeric_value AS jn01a_equi_join,
    cross_j.actual_numeric_value AS jn13_cross_join,
    CASE WHEN equi.actual_numeric_value < cross_j.actual_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result equi, sql_example_result cross_j
WHERE equi.example_id = 'JN01A' AND cross_j.example_id = 'JN13';

-- C8) FULL OUTER JOIN 통합 키 NULL 개수(JN09B) = 기대값(3)
SELECT
    r.actual_numeric_value AS jn09b_unified_key_null_count,
    e.expected_numeric_value AS expected_value,
    CASE WHEN r.actual_numeric_value = e.expected_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result r JOIN sql_example_expectation e ON r.example_id = e.example_id
WHERE r.example_id = 'JN09B';

-- =====================================================================
-- D) 원천 데이터 직접 확인 - 위 판정을 눈으로도 다시 확인할 수 있도록 원본을 조회
-- =====================================================================

-- 고아 주문(customer_id가 NULL) 직접 확인 - JN05C가 왜 깨지는지의 근거
SELECT * FROM orders WHERE customer_id IS NULL;

-- 복합키 양쪽 다 NULL인 행(O8) 직접 확인 - JN12에서 매칭 안 되는 이유의 근거
SELECT * FROM orders WHERE customer_id IS NULL AND order_date IS NULL;
SELECT * FROM order_events WHERE customer_id IS NULL AND event_date IS NULL;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 Oracle 전용 -> SQLServer/03_verify.sql과 대조할 것)
-- =====================================================================
-- JN10(USING): 이 Oracle 스크립트는 USING(sales_region) 문법을 그대로 썼다.
--   SQLServer/02_examples.sql은 ON customers.sales_region=regions.sales_region으로
--   동일한 결과(5행)를 낸다.
-- JN14(Oracle (+)): 이 스크립트는 (+) 구문으로 "반대편 필터에 (+) 누락" 함정을
--   재현했다. SQLServer/02_examples.sql은 애초에 (+) 자체가 없으므로
--   LEFT JOIN + WHERE 형태로만 같은 함정(JN03B와 동일한 2행)을 보여준다.
-- 나머지 예제는 순수 ANSI 문법이라 두 DBMS 결과가 완전히 같아야 한다 -
-- 다르면 위 A-1 쿼리의 FAIL로 바로 드러난다.
