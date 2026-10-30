-- ex05 NULL 과 3값 논리 (PDF E-06 "NULL은 ''로 조회가 불가능, IS NULL / IS NOT NULL")  | Oracle
PROMPT == [Q1] = NULL 은 항상 UNKNOWN -> 0행
SELECT COUNT(*) AS eq_null FROM emp WHERE comm = NULL;

PROMPT == [Q2] IS NULL / IS NOT NULL
SELECT (SELECT COUNT(*) FROM emp WHERE comm IS NULL) AS is_null,
       (SELECT COUNT(*) FROM emp WHERE comm IS NOT NULL) AS is_not_null FROM dual;

PROMPT == [Q3] 부정 조건도 NULL 행을 돌려주지 않는다: comm > 0 (3) + NOT (comm > 0) (1) = 4 ≠ 14
SELECT (SELECT COUNT(*) FROM emp WHERE comm > 0) AS gt0,
       (SELECT COUNT(*) FROM emp WHERE NOT (comm > 0)) AS not_gt0 FROM dual;

PROMPT == [Q4] 진리표: UNKNOWN 과 AND/OR/NOT
-- Oracle 19c/21c SQL 에는 BOOLEAN 컬럼이 없어(23ai 부터 지원) 비교식 x = 1 로 TRUE/FALSE/UNKNOWN 을 만든다
SELECT t.a, t.b,
       CASE WHEN (t.x = 1 AND t.y = 1) THEN 'TRUE' WHEN NOT (t.x = 1 AND t.y = 1) THEN 'FALSE' ELSE 'UNKNOWN' END AS a_and_b,
       CASE WHEN (t.x = 1 OR  t.y = 1) THEN 'TRUE' WHEN NOT (t.x = 1 OR  t.y = 1) THEN 'FALSE' ELSE 'UNKNOWN' END AS a_or_b,
       CASE WHEN NOT (t.x = 1) THEN 'TRUE' WHEN (t.x = 1) THEN 'FALSE' ELSE 'UNKNOWN' END AS not_a
FROM (SELECT 'TRUE' a, 'UNKNOWN' b, 1 x, NULL y FROM dual UNION ALL
      SELECT 'FALSE', 'UNKNOWN', 0, NULL FROM dual UNION ALL
      SELECT 'UNKNOWN', 'UNKNOWN', NULL, NULL FROM dual) t;

PROMPT == [Q5] Oracle 에서 빈 문자열 '' 은 NULL 이다 -> = '' 도 0행, '' IS NULL 은 참
SELECT (SELECT COUNT(*) FROM w_like WHERE txt = '') AS eq_empty,
       CASE WHEN '' IS NULL THEN 'EMPTY_IS_NULL' ELSE 'EMPTY_IS_NOT_NULL' END AS empty_string FROM dual;
