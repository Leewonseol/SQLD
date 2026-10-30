-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex04_grouping_sets | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_grouping_sets.md
-- =====================================================================

PROMPT == [G1] 부서·입사연도 소계 + 총계
CREATE OR REPLACE VIEW ans10_04_g1 (deptno, hire_year, cnt) AS
SELECT deptno, EXTRACT(YEAR FROM hiredate), COUNT(*) FROM emp GROUP BY GROUPING SETS (deptno, EXTRACT(YEAR FROM hiredate), ());
CREATE OR REPLACE VIEW exp10_04_g1 (deptno, hire_year, cnt) AS
-- (deptno, hire_year, cnt)
SELECT 10, CAST(NULL AS NUMBER), 3 FROM dual
UNION ALL SELECT 20, CAST(NULL AS NUMBER), 5 FROM dual
UNION ALL SELECT 30, CAST(NULL AS NUMBER), 6 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), 1980, 1 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), 1981, 10 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), 1982, 1 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), 1987, 2 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), CAST(NULL AS NUMBER), 14 FROM dual;
EXEC lab_check('10-ex04-G1', 'ANS10_04_G1', 'EXP10_04_G1')
SELECT * FROM ans10_04_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] GROUPING SETS((deptno, job), deptno) 행 수
-- 9 + 3 = 12. ROLLUP(deptno, job) 은 총계까지 13.
CREATE OR REPLACE VIEW ans10_04_g2 (cnt) AS
SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY GROUPING SETS ((deptno, job), deptno));
CREATE OR REPLACE VIEW exp10_04_g2 (cnt) AS
-- (cnt)
SELECT 12 FROM dual;
EXEC lab_check('10-ex04-G2', 'ANS10_04_G2', 'EXP10_04_G2')
SELECT * FROM ans10_04_g2 ORDER BY 1;
