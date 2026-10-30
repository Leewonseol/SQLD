-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex02_multi_row_any_all | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_multi_row_any_all.md
-- =====================================================================

PROMPT == [G1] 30번 부서 모두보다 적은 급여
-- 30번 부서 최저 950 미만. < ANY 로 쓰면 '최고 2850 미만' 이라 11명.
CREATE OR REPLACE VIEW ans08_02_g1 (ename, sal) AS
SELECT ename, sal FROM emp WHERE sal < ALL (SELECT sal FROM emp WHERE deptno = 30);
CREATE OR REPLACE VIEW exp08_02_g1 (ename, sal) AS
-- (ename, sal)
SELECT 'SMITH', 800 FROM dual;
EXEC lab_check('08-ex02-G1', 'ANS08_02_G1', 'EXP08_02_G1')
SELECT * FROM ans08_02_g1 ORDER BY 1, 2;

PROMPT == [G2] 최고 급여자(>= ALL)
-- sal 에 NULL 이 있으면 >= ALL 은 0행이 된다(UNKNOWN). 그 경우 WHERE sal IS NOT NULL 을 서브쿼리에 추가.
CREATE OR REPLACE VIEW ans08_02_g2 (ename) AS
SELECT ename FROM emp WHERE sal >= ALL (SELECT sal FROM emp);
CREATE OR REPLACE VIEW exp08_02_g2 (ename) AS
-- (ename)
SELECT 'KING' FROM dual;
EXEC lab_check('08-ex02-G2', 'ANS08_02_G2', 'EXP08_02_G2')
SELECT * FROM ans08_02_g2 ORDER BY 1;
