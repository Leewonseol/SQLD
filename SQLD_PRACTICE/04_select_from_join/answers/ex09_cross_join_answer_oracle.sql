-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex09_cross_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex09_cross_join.md
-- =====================================================================

PROMPT == [G1] DEPT x SALGRADE 행 수
CREATE OR REPLACE VIEW ans04_09_g1 (cnt) AS
SELECT COUNT(*) FROM dept CROSS JOIN salgrade;
CREATE OR REPLACE VIEW exp04_09_g1 (cnt) AS
-- (cnt)
SELECT 20 FROM dual;
EXEC lab_check('04-ex09-G1', 'ANS04_09_G1', 'EXP04_09_G1')
SELECT * FROM ans04_09_g1 ORDER BY 1;

PROMPT == [G2] 부서 x 직무 중 사원이 없는 조합
-- 4 x 5 = 20 조합 - 실제 존재 조합 9 = 11행. CROSS JOIN 으로 '가능한 모든 경우'를 만든 뒤 NOT EXISTS 로 '실제 있는 것'을 뺀다.
CREATE OR REPLACE VIEW ans04_09_g2 (deptno, job) AS
SELECT d.deptno, j.job
FROM dept d CROSS JOIN (SELECT DISTINCT job FROM emp) j
WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno AND e.job = j.job);
CREATE OR REPLACE VIEW exp04_09_g2 (deptno, job) AS
-- (deptno, job)
SELECT 10, 'ANALYST' FROM dual
UNION ALL SELECT 10, 'SALESMAN' FROM dual
UNION ALL SELECT 20, 'PRESIDENT' FROM dual
UNION ALL SELECT 20, 'SALESMAN' FROM dual
UNION ALL SELECT 30, 'ANALYST' FROM dual
UNION ALL SELECT 30, 'PRESIDENT' FROM dual
UNION ALL SELECT 40, 'ANALYST' FROM dual
UNION ALL SELECT 40, 'CLERK' FROM dual
UNION ALL SELECT 40, 'MANAGER' FROM dual
UNION ALL SELECT 40, 'PRESIDENT' FROM dual
UNION ALL SELECT 40, 'SALESMAN' FROM dual;
EXEC lab_check('04-ex09-G2', 'ANS04_09_G2', 'EXP04_09_G2')
SELECT * FROM ans04_09_g2 ORDER BY 1, 2;
