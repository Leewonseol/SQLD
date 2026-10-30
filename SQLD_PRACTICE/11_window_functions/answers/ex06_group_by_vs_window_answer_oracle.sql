-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex06_group_by_vs_window | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_group_by_vs_window.md
-- =====================================================================

PROMPT == [G1] 부서 평균보다 많은 급여(윈도우)
CREATE OR REPLACE VIEW ans11_06_g1 (deptno, ename, sal) AS
SELECT deptno, ename, sal FROM (SELECT deptno, ename, sal, AVG(sal) OVER (PARTITION BY deptno) a FROM emp) WHERE sal > a;
CREATE OR REPLACE VIEW exp11_06_g1 (deptno, ename, sal) AS
-- (deptno, ename, sal)
SELECT 10, 'KING', 5000 FROM dual
UNION ALL SELECT 20, 'FORD', 3000 FROM dual
UNION ALL SELECT 20, 'JONES', 2975 FROM dual
UNION ALL SELECT 20, 'SCOTT', 3000 FROM dual
UNION ALL SELECT 30, 'ALLEN', 1600 FROM dual
UNION ALL SELECT 30, 'BLAKE', 2850 FROM dual;
EXEC lab_check('11-ex06-G1', 'ANS11_06_G1', 'EXP11_06_G1')
SELECT * FROM ans11_06_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 부서 합계와 전체 대비 비율
CREATE OR REPLACE VIEW ans11_06_g2 (deptno, dept_sum, pct) AS
SELECT deptno, SUM(sal), ROUND(SUM(sal) * 100 / SUM(SUM(sal)) OVER (), 1) FROM emp GROUP BY deptno;
CREATE OR REPLACE VIEW exp11_06_g2 (deptno, dept_sum, pct) AS
-- (deptno, dept_sum, pct)
SELECT 10, 8750, 30.1 FROM dual
UNION ALL SELECT 20, 10875, 37.5 FROM dual
UNION ALL SELECT 30, 9400, 32.4 FROM dual;
EXEC lab_check('11-ex06-G2', 'ANS11_06_G2', 'EXP11_06_G2')
SELECT * FROM ans11_06_g2 ORDER BY 1, 2, 3;
