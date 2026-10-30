-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex04_correlated_subquery | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_correlated_subquery.md
-- =====================================================================

PROMPT == [G1] 자기 직무 평균보다 적은 급여
CREATE OR REPLACE VIEW ans08_04_g1 (ename, job, sal) AS
SELECT e.ename, e.job, e.sal FROM emp e WHERE e.sal < (SELECT AVG(x.sal) FROM emp x WHERE x.job = e.job);
CREATE OR REPLACE VIEW exp08_04_g1 (ename, job, sal) AS
-- (ename, job, sal)
SELECT 'CLARK', 'MANAGER', 2450 FROM dual
UNION ALL SELECT 'JAMES', 'CLERK', 950 FROM dual
UNION ALL SELECT 'MARTIN', 'SALESMAN', 1250 FROM dual
UNION ALL SELECT 'SMITH', 'CLERK', 800 FROM dual
UNION ALL SELECT 'WARD', 'SALESMAN', 1250 FROM dual;
EXEC lab_check('08-ex04-G1', 'ANS08_04_G1', 'EXP08_04_G1')
SELECT * FROM ans08_04_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 부서별 상위 2명(연관 서브쿼리)
-- 20번 부서: SCOTT·FORD 동점 3000 은 '더 높은 사람 0명'. JONES 2975 는 2명이라 빠진다. RANK() <= 2 와 같은 결과(11단원).
CREATE OR REPLACE VIEW ans08_04_g2 (deptno, ename) AS
SELECT e.deptno, e.ename FROM emp e WHERE (SELECT COUNT(*) FROM emp x WHERE x.deptno = e.deptno AND x.sal > e.sal) < 2;
CREATE OR REPLACE VIEW exp08_04_g2 (deptno, ename) AS
-- (deptno, ename)
SELECT 10, 'CLARK' FROM dual
UNION ALL SELECT 10, 'KING' FROM dual
UNION ALL SELECT 20, 'FORD' FROM dual
UNION ALL SELECT 20, 'SCOTT' FROM dual
UNION ALL SELECT 30, 'ALLEN' FROM dual
UNION ALL SELECT 30, 'BLAKE' FROM dual;
EXEC lab_check('08-ex04-G2', 'ANS08_04_G2', 'EXP08_04_G2')
SELECT * FROM ans08_04_g2 ORDER BY 1, 2;
