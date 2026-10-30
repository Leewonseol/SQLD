-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex01_single_row_subquery | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_single_row_subquery.md
-- =====================================================================

PROMPT == [G1] 가장 늦게 입사한 사원과 같은 부서
-- 가장 늦은 입사일(1987-05-23 ADAMS)이 동점이면 바깥 = 가 ORA-01427/Msg 512 로 실패한다. 안전하게 하려면 deptno IN (...).
CREATE OR REPLACE VIEW ans08_01_g1 (ename) AS
SELECT ename FROM emp WHERE deptno = (SELECT deptno FROM emp WHERE hiredate = (SELECT MAX(hiredate) FROM emp));
CREATE OR REPLACE VIEW exp08_01_g1 (ename) AS
-- (ename)
SELECT 'ADAMS' FROM dual
UNION ALL SELECT 'FORD' FROM dual
UNION ALL SELECT 'JONES' FROM dual
UNION ALL SELECT 'SCOTT' FROM dual
UNION ALL SELECT 'SMITH' FROM dual;
EXEC lab_check('08-ex01-G1', 'ANS08_01_G1', 'EXP08_01_G1')
SELECT * FROM ans08_01_g1 ORDER BY 1;

PROMPT == [G2] SMITH 와 같은 직무, 급여가 더 많은 사원
CREATE OR REPLACE VIEW ans08_01_g2 (ename, sal) AS
SELECT ename, sal FROM emp WHERE job = (SELECT job FROM emp WHERE ename = 'SMITH') AND sal > (SELECT sal FROM emp WHERE ename = 'SMITH');
CREATE OR REPLACE VIEW exp08_01_g2 (ename, sal) AS
-- (ename, sal)
SELECT 'ADAMS', 1100 FROM dual
UNION ALL SELECT 'JAMES', 950 FROM dual
UNION ALL SELECT 'MILLER', 1300 FROM dual;
EXEC lab_check('08-ex01-G2', 'ANS08_01_G2', 'EXP08_01_G2')
SELECT * FROM ans08_01_g2 ORDER BY 1, 2;
