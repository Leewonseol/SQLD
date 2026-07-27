-- JOIN·표준 JOIN 결과 검산 (Oracle)
-- 실행 상태: 이 세션에는 Oracle 실행 환경이 없어 실제 실행 미검증(README 참고).
-- 순서: 01_prepare.sql -> 02_examples.sql -> 02_validate.py -> 이 파일.
--
-- 이 파일은 두 가지를 한다.
--   A) sql_example_expectation과 sql_example_result를 SQL 자체로 다시 조인해
--      Python 없이도 PASS/FAIL을 재현할 수 있게 한다(검산의 이중화).
--   B) 02_validate.py가 이미 sql_example_validation에 적재한 결과를 집계·조회한다.

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

-- J09: 중복값 조인 - 값별 매칭 횟수를 직접 풀어서 재확인(합계가 3이어야 함)
SELECT t1.col1,
       (SELECT COUNT(*) FROM dup_t2 t2 WHERE t2.col1 = t1.col1) AS matched_in_t2
FROM dup_t1 t1
ORDER BY t1.col1;

-- J18: Oracle (+) - DEPT 40이 EMP 없이도 보존되는지 직접 확인(1행 나와야 함)
SELECT deptno, dname
FROM dept
WHERE deptno NOT IN (SELECT deptno FROM emp);

-- J21/J21B: COUNT(*) 4 vs COUNT(우측열) 3 차이가 실제로 NULL 1건 때문인지 확인
SELECT m.memberid, c.memberid AS contact_memberid
FROM member m LEFT OUTER JOIN contact c ON m.memberid = c.memberid
WHERE c.memberid IS NULL;

-- =====================================================================
-- DBMS별 차이 확인 (이 파일은 Oracle 전용 -> SQLServer/03_verify.sql과 대조할 것)
-- =====================================================================
-- J15(USING), J16(NATURAL JOIN): 이 Oracle 스크립트는 문법을 직접 사용했다.
--   SQLServer/02_examples.sql은 같은 결과를 ON으로 재현하며, USING/NATURAL
--   JOIN 구문 자체는 SQL Server에 존재하지 않는다.
-- J18(Oracle (+)): 이 Oracle 스크립트는 (+) 구문을 그대로 썼다.
--   SQLServer/02_examples.sql은 LEFT JOIN으로 동일 결과(9행)를 만든다.
-- 두 DBMS 스크립트 모두 sql_example_expectation의 expected_row_count /
-- expected_numeric_value 값은 동일해야 한다(문법만 다르고 결과는 같아야 하는
-- 개념이므로) - 값이 다르면 위 A-1 쿼리의 FAIL로 바로 드러난다.
