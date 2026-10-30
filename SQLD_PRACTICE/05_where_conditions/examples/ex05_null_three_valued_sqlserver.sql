-- ex05 NULL 과 3값 논리  | SQL Server
PRINT N'== [Q1] = NULL (ANSI_NULLS ON 기본)';
SELECT COUNT(*) AS eq_null FROM emp WHERE comm = NULL;
PRINT N'== [Q2] IS NULL / IS NOT NULL';
SELECT (SELECT COUNT(*) FROM emp WHERE comm IS NULL) AS is_null,
       (SELECT COUNT(*) FROM emp WHERE comm IS NOT NULL) AS is_not_null;
PRINT N'== [Q3] 부정 조건과 NULL';
SELECT (SELECT COUNT(*) FROM emp WHERE comm > 0) AS gt0,
       (SELECT COUNT(*) FROM emp WHERE NOT (comm > 0)) AS not_gt0;
PRINT N'== [Q4] 진리표';
SELECT t.a, t.b,
       CASE WHEN (t.x = 1 AND t.y = 1) THEN 'TRUE' WHEN NOT (t.x = 1 AND t.y = 1) THEN 'FALSE' ELSE 'UNKNOWN' END AS a_and_b,
       CASE WHEN (t.x = 1 OR  t.y = 1) THEN 'TRUE' WHEN NOT (t.x = 1 OR  t.y = 1) THEN 'FALSE' ELSE 'UNKNOWN' END AS a_or_b,
       CASE WHEN NOT (t.x = 1) THEN 'TRUE' WHEN (t.x = 1) THEN 'FALSE' ELSE 'UNKNOWN' END AS not_a
FROM (VALUES ('TRUE', 'UNKNOWN', 1, CAST(NULL AS INT)), ('FALSE', 'UNKNOWN', 0, NULL), ('UNKNOWN', 'UNKNOWN', NULL, NULL)) t(a, b, x, y);
PRINT N'== [Q5] SQL Server 에서 빈 문자열은 NULL 이 아니다';
INSERT INTO w_like VALUES (8, '');
SELECT (SELECT COUNT(*) FROM w_like WHERE txt = '') AS eq_empty,
       CASE WHEN '' IS NULL THEN 'EMPTY_IS_NULL' ELSE 'EMPTY_IS_NOT_NULL' END AS empty_string;
DELETE FROM w_like WHERE id = 8;
GO
PRINT N'== [Q6] (참고·비권장) SET ANSI_NULLS OFF 이면 = NULL 이 참이 된다. 향후 버전에서 제거 예정 기능';
SET ANSI_NULLS OFF;
SELECT COUNT(*) AS eq_null_ansi_off FROM emp WHERE comm = NULL;
SET ANSI_NULLS ON;
GO
