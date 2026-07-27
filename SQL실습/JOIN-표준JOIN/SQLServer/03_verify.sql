-- JOIN·표준 JOIN 결과 검산 (SQL Server)
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

-- J09: 중복값 조인 - 값별 매칭 횟수를 직접 풀어서 재확인(합계가 3이어야 함)
SELECT t1.col1,
       (SELECT COUNT(*) FROM dup_t2 t2 WHERE t2.col1 = t1.col1) AS matched_in_t2
FROM dup_t1 t1
ORDER BY t1.col1;

-- J18 동등 표현: DEPT 40이 EMP 없이도 보존되는지 직접 확인(1행 나와야 함)
SELECT deptno, dname
FROM dept
WHERE deptno NOT IN (SELECT deptno FROM emp);

-- J21/J21B: COUNT(*) 4 vs COUNT(우측열) 3 차이가 실제로 NULL 1건 때문인지 확인
SELECT m.memberid, c.memberid AS contact_memberid
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.memberid IS NULL;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 SQL Server 전용 -> Oracle/03_verify.sql과 대조할 것)
-- =====================================================================
-- J15(USING), J16(NATURAL JOIN): SQL Server는 이 두 문법을 지원하지 않는다.
--   이 스크립트는 ON STUDENT.STUNO = SCORE.STUNO로 동일한 결과(2행)를 냈다.
--   Oracle/02_examples.sql은 실제 USING(STUNO), NATURAL JOIN 문법을 그대로 썼다.
-- J18(Oracle (+) 동등 표현): 이 스크립트는 LEFT JOIN으로 9행을 만들었다.
--   Oracle/02_examples.sql은 (+) 구문으로 같은 9행을 만든다.
-- sql_example_expectation의 expected_row_count / expected_numeric_value는
-- Oracle과 SQL Server 두 파일에서 J01~J23 전부 값이 같아야 한다(문법만 다르고
-- 결과는 같은 개념들이므로) - 값이 다르면 위 A-1 쿼리의 FAIL로 바로 드러난다.
