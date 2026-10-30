-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex02_group_by_rules | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_group_by_rules.md
-- =====================================================================

PROMPT == [G1] 입사 연도별 인원·최고 급여
CREATE OR REPLACE VIEW ans06_02_g1 (hire_year, cnt, max_sal) AS
SELECT EXTRACT(YEAR FROM hiredate), COUNT(*), MAX(sal) FROM emp GROUP BY EXTRACT(YEAR FROM hiredate);
CREATE OR REPLACE VIEW exp06_02_g1 (hire_year, cnt, max_sal) AS
-- (hire_year, cnt, max_sal)
SELECT 1980, 1, 800 FROM dual
UNION ALL SELECT 1981, 10, 5000 FROM dual
UNION ALL SELECT 1982, 1, 1300 FROM dual
UNION ALL SELECT 1987, 2, 3000 FROM dual;
EXEC lab_check('06-ex02-G1', 'ANS06_02_G1', 'EXP06_02_G1')
SELECT * FROM ans06_02_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 관리자별 부하 수(NULL 그룹 포함)
-- COUNT(mgr) 로 세면 NULL 그룹이 0 이 된다 → CHECK_FAIL.
CREATE OR REPLACE VIEW ans06_02_g2 (mgr, cnt) AS
SELECT mgr, COUNT(*) FROM emp GROUP BY mgr;
CREATE OR REPLACE VIEW exp06_02_g2 (mgr, cnt) AS
-- (mgr, cnt)
SELECT 7566, 2 FROM dual
UNION ALL SELECT 7698, 5 FROM dual
UNION ALL SELECT 7782, 1 FROM dual
UNION ALL SELECT 7788, 1 FROM dual
UNION ALL SELECT 7839, 3 FROM dual
UNION ALL SELECT 7902, 1 FROM dual
UNION ALL SELECT CAST(NULL AS NUMBER), 1 FROM dual;
EXEC lab_check('06-ex02-G2', 'ANS06_02_G2', 'EXP06_02_G2')
SELECT * FROM ans06_02_g2 ORDER BY 1, 2;
