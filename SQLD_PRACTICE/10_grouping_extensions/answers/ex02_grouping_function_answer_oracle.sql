-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex02_grouping_function | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_grouping_function.md
-- =====================================================================

PROMPT == [G1] 부서 소계 행만
-- GROUPING(deptno) = 0 을 빼면 총계 행(NULL, 14)도 남는다.
CREATE OR REPLACE VIEW ans10_02_g1 (deptno, cnt) AS
SELECT deptno, COUNT(*) FROM emp GROUP BY ROLLUP (deptno, job) HAVING GROUPING(job) = 1 AND GROUPING(deptno) = 0;
CREATE OR REPLACE VIEW exp10_02_g1 (deptno, cnt) AS
-- (deptno, cnt)
SELECT 10, 3 FROM dual
UNION ALL SELECT 20, 5 FROM dual
UNION ALL SELECT 30, 6 FROM dual;
EXEC lab_check('10-ex02-G1', 'ANS10_02_G1', 'EXP10_02_G1')
SELECT * FROM ans10_02_g1 ORDER BY 1, 2;

PROMPT == [G2] 소계·총계·실제 NULL 라벨
-- SQL Server 에서 ISNULL(breed, N'NULL값') 으로 쓰면 VARCHAR(5) 로 바뀌어 '??' 가 된다 → CHECK_FAIL. CAST 로 형을 먼저 넓힌다.
CREATE OR REPLACE VIEW ans10_02_g2 (species, label, s) AS
SELECT species, CASE WHEN GROUPING(species) = 1 THEN '총계' WHEN GROUPING(breed) = 1 THEN '소계' ELSE NVL(breed, 'NULL값') END, SUM(cnt)
FROM ah_null GROUP BY ROLLUP (species, breed);
CREATE OR REPLACE VIEW exp10_02_g2 (species, label, s) AS
-- (species, label, s)
SELECT 'A', 'x', 1 FROM dual
UNION ALL SELECT 'A', 'NULL값', 3 FROM dual
UNION ALL SELECT 'A', '소계', 4 FROM dual
UNION ALL SELECT 'B', 'y', 5 FROM dual
UNION ALL SELECT 'B', '소계', 5 FROM dual
UNION ALL SELECT CAST(NULL AS VARCHAR2(100)), '총계', 9 FROM dual;
EXEC lab_check('10-ex02-G2', 'ANS10_02_G2', 'EXP10_02_G2')
SELECT * FROM ans10_02_g2 ORDER BY 1, 2, 3;
