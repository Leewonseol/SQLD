-- JOIN×NULL 통합 결과 검산 (SQL Server)
-- 실행 상태: 이 세션에는 SQL Server 실행 환경이 없어 실제 실행 미검증(README 참고).
-- 순서: 01_prepare.sql -> 02_examples.sql -> 02_validate.py -> 이 파일.
-- 쿼리 구조는 Oracle/03_verify.sql과 동일하다(NVL -> ISNULL, DUAL 없음 정도만 차이).

-- =====================================================================
-- A-1) SQL 자체 PASS/FAIL/NO_RESULT 재계산
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
             AND ISNULL(r.actual_text_value, '~~NULL~~') <> e.expected_text_value THEN 'FAIL'
        ELSE 'PASS'
    END AS sql_side_status
FROM sql_example_expectation e
LEFT JOIN sql_example_result r ON e.example_id = r.example_id
ORDER BY e.example_id;

-- =====================================================================
-- A-2) SQL 자체 PASS/FAIL/NO_RESULT 집계
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
                 AND ISNULL(r.actual_text_value, '~~NULL~~') <> e.expected_text_value THEN 'FAIL'
            ELSE 'PASS'
        END AS status
    FROM sql_example_expectation e
    LEFT JOIN sql_example_result r ON e.example_id = r.example_id
) t;

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
-- C) 메타모픽 검증 (Oracle/03_verify.sql C1~C8과 동일한 관계, SQL Server 실제값으로 재확인)
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

-- C3) ON 필터 행수(JN03A) > WHERE 필터 행수(JN03B)
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

-- C5) SQL Server ON(JN10) 결과 - Oracle USING(JN10) 결과와 사람이 나란히 비교
SELECT example_id, actual_numeric_value AS sqlserver_jn10_on_result
FROM sql_example_result WHERE example_id = 'JN10';

-- C6) SQL Server ANSI LEFT JOIN+WHERE 함정(JN14) = JN03B(같은 SQL, 당연히 동일)
SELECT
    n14.actual_numeric_value AS jn14_ansi_trap,
    n03b.actual_numeric_value AS jn03b_where_trap,
    CASE WHEN n14.actual_numeric_value = n03b.actual_numeric_value THEN 'PASS' ELSE 'FAIL' END AS metamorphic_status
FROM sql_example_result n14, sql_example_result n03b
WHERE n14.example_id = 'JN14' AND n03b.example_id = 'JN03B';

-- C7) NULL 키 등가조인(JN01A) < CROSS JOIN(JN13)
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
-- D) 원천 데이터 직접 확인
-- =====================================================================
SELECT * FROM orders WHERE customer_id IS NULL;
SELECT * FROM orders WHERE customer_id IS NULL AND order_date IS NULL;
SELECT * FROM order_events WHERE customer_id IS NULL AND event_date IS NULL;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 SQL Server 전용 -> Oracle/03_verify.sql과 대조할 것)
-- =====================================================================
-- JN10(USING 대응): Oracle은 USING(sales_region), 이 스크립트는 ON으로
--   같은 결과(5행)를 낸다.
-- JN14((+) 대응): Oracle은 (+) 구문으로 "반대편 필터 (+) 누락" 함정을 재현했고,
--   이 스크립트는 애초에 (+)가 없으므로 LEFT JOIN+WHERE만으로 같은 함정
--   (JN03B와 동일한 2행)을 보여준다.
