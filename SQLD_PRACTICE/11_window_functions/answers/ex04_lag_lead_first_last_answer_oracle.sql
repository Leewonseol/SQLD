-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex04_lag_lead_first_last | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_lag_lead_first_last.md
-- =====================================================================

PROMPT == [G1] 직전 입사자와 급여 차이
-- LAG 의 기본값을 sal 로 주면 첫 행 차이가 0. NVL(sal - LAG(sal) OVER (...), 0) 도 같다.
CREATE OR REPLACE VIEW ans11_04_g1 (ename, diff) AS
SELECT ename, sal - LAG(sal, 1, sal) OVER (ORDER BY hiredate) FROM emp WHERE deptno = 30;
CREATE OR REPLACE VIEW exp11_04_g1 (ename, diff) AS
-- (ename, diff)
SELECT 'ALLEN', 0 FROM dual
UNION ALL SELECT 'BLAKE', 1600 FROM dual
UNION ALL SELECT 'JAMES', -300 FROM dual
UNION ALL SELECT 'MARTIN', -250 FROM dual
UNION ALL SELECT 'TURNER', -1350 FROM dual
UNION ALL SELECT 'WARD', -350 FROM dual;
EXEC lab_check('11-ex04-G1', 'ANS11_04_G1', 'EXP11_04_G1')
SELECT * FROM ans11_04_g1 ORDER BY 1, 2;

PROMPT == [G2] 부서별 최저 급여자(LAST_VALUE)
-- 프레임을 지정하지 않으면 각 행 자기 이름이 나와 DISTINCT 후 14행 → CHECK_FAIL (PDF E-34 의 함정).
CREATE OR REPLACE VIEW ans11_04_g2 (deptno, min_name) AS
SELECT DISTINCT deptno, LAST_VALUE(ename) OVER (PARTITION BY deptno ORDER BY sal DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FROM emp;
CREATE OR REPLACE VIEW exp11_04_g2 (deptno, min_name) AS
-- (deptno, min_name)
SELECT 10, 'MILLER' FROM dual
UNION ALL SELECT 20, 'SMITH' FROM dual
UNION ALL SELECT 30, 'JAMES' FROM dual;
EXEC lab_check('11-ex04-G2', 'ANS11_04_G2', 'EXP11_04_G2')
SELECT * FROM ans11_04_g2 ORDER BY 1, 2;
