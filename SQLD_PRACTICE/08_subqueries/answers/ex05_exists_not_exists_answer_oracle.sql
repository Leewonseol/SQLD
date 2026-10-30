-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex05_exists_not_exists | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_exists_not_exists.md
-- =====================================================================

PROMPT == [G1] 주문 없는 고객
CREATE OR REPLACE VIEW ans08_05_g1 (cust_id) AS
SELECT c.cust_id FROM cust c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.cust_id = c.cust_id);
CREATE OR REPLACE VIEW exp08_05_g1 (cust_id) AS
-- (cust_id)
SELECT 'C04' FROM dual;
EXEC lab_check('08-ex05-G1', 'ANS08_05_G1', 'EXP08_05_G1')
SELECT * FROM ans08_05_g1 ORDER BY 1;

PROMPT == [G2] SALESMAN 이 없는 (사원 있는) 부서
-- EXISTS 조건을 빼면 사원이 없는 40번도 'SALESMAN 이 없는 부서'로 나온다.
CREATE OR REPLACE VIEW ans08_05_g2 (deptno) AS
SELECT d.deptno FROM dept d WHERE EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno)
AND NOT EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno AND e.job = 'SALESMAN');
CREATE OR REPLACE VIEW exp08_05_g2 (deptno) AS
-- (deptno)
SELECT 10 FROM dual
UNION ALL SELECT 20 FROM dual;
EXEC lab_check('08-ex05-G2', 'ANS08_05_G2', 'EXP08_05_G2')
SELECT * FROM ans08_05_g2 ORDER BY 1;
