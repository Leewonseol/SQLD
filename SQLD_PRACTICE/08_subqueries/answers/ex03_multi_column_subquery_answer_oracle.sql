-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex03_multi_column_subquery | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_multi_column_subquery.md
-- =====================================================================

PROMPT == [G1] 직무별 최저 급여자
CREATE OR REPLACE VIEW ans08_03_g1 (ename, job, sal) AS
SELECT ename, job, sal FROM emp WHERE (job, sal) IN (SELECT job, MIN(sal) FROM emp GROUP BY job);
CREATE OR REPLACE VIEW exp08_03_g1 (ename, job, sal) AS
-- (ename, job, sal)
SELECT 'CLARK', 'MANAGER', 2450 FROM dual
UNION ALL SELECT 'FORD', 'ANALYST', 3000 FROM dual
UNION ALL SELECT 'KING', 'PRESIDENT', 5000 FROM dual
UNION ALL SELECT 'MARTIN', 'SALESMAN', 1250 FROM dual
UNION ALL SELECT 'SCOTT', 'ANALYST', 3000 FROM dual
UNION ALL SELECT 'SMITH', 'CLERK', 800 FROM dual
UNION ALL SELECT 'WARD', 'SALESMAN', 1250 FROM dual;
EXEC lab_check('08-ex03-G1', 'ANS08_03_G1', 'EXP08_03_G1')
SELECT * FROM ans08_03_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 부서별 최초 입사자
CREATE OR REPLACE VIEW ans08_03_g2 (deptno, ename) AS
SELECT deptno, ename FROM emp WHERE (deptno, hiredate) IN (SELECT deptno, MIN(hiredate) FROM emp GROUP BY deptno);
CREATE OR REPLACE VIEW exp08_03_g2 (deptno, ename) AS
-- (deptno, ename)
SELECT 10, 'CLARK' FROM dual
UNION ALL SELECT 20, 'SMITH' FROM dual
UNION ALL SELECT 30, 'ALLEN' FROM dual;
EXEC lab_check('08-ex03-G2', 'ANS08_03_G2', 'EXP08_03_G2')
SELECT * FROM ans08_03_g2 ORDER BY 1, 2;
