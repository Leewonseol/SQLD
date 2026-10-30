-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex01_rollup | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_rollup.md
-- =====================================================================

PROMPT == [G1] 부서·직무 인원 ROLLUP
CREATE OR REPLACE VIEW ans10_01_g1 (deptno, job, cnt) AS
SELECT deptno, job, COUNT(*) FROM emp GROUP BY ROLLUP (deptno, job);
CREATE OR REPLACE VIEW exp10_01_g1 (deptno, job, cnt) AS
-- (deptno, job, cnt)
SELECT 10, 'CLERK', 1 FROM dual
UNION ALL SELECT 10, 'MANAGER', 1 FROM dual
UNION ALL SELECT 10, 'PRESIDENT', 1 FROM dual
UNION ALL SELECT 10, CAST(NULL AS VARCHAR2(100)), 3 FROM dual
UNION ALL SELECT 20, 'ANALYST', 2 FROM dual
UNION ALL SELECT 20, 'CLERK', 2 FROM dual
UNION ALL SELECT 20, 'MANAGER', 1 FROM dual
UNION ALL SELECT 20, CAST(NULL AS VARCHAR2(100)), 5 FROM dual
UNION ALL SELECT 30, 'CLERK', 1 FROM dual
UNION ALL SELECT 30, 'MANAGER', 1 FROM dual
UNION ALL SELECT 30, 'SALESMAN', 4 FROM dual
UNION ALL SELECT 30, CAST(NULL AS VARCHAR2(100)), 6 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), CAST(NULL AS VARCHAR2(100)), 14 FROM dual;
EXEC lab_check('10-ex01-G1', 'ANS10_01_G1', 'EXP10_01_G1')
SELECT * FROM ans10_01_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 입사 연도별 급여 합계 + 총계
CREATE OR REPLACE VIEW ans10_01_g2 (hire_year, total) AS
SELECT EXTRACT(YEAR FROM hiredate), SUM(sal) FROM emp GROUP BY ROLLUP (EXTRACT(YEAR FROM hiredate));
CREATE OR REPLACE VIEW exp10_01_g2 (hire_year, total) AS
-- (hire_year, total)
SELECT 1980, 800 FROM dual
UNION ALL SELECT 1981, 22825 FROM dual
UNION ALL SELECT 1982, 1300 FROM dual
UNION ALL SELECT 1987, 4100 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), 29025 FROM dual;
EXEC lab_check('10-ex01-G2', 'ANS10_01_G2', 'EXP10_01_G2')
SELECT * FROM ans10_01_g2 ORDER BY 1, 2;
