-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex07_self_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_self_join.md
-- =====================================================================

PROMPT == [G1] 관리자보다 급여가 많은 사원
CREATE OR REPLACE VIEW ans04_07_g1 (ename, sal, mgr_name, mgr_sal) AS
SELECT e.ename, e.sal, m.ename, m.sal FROM emp e JOIN emp m ON e.mgr = m.empno WHERE e.sal > m.sal;
CREATE OR REPLACE VIEW exp04_07_g1 (ename, sal, mgr_name, mgr_sal) AS
-- (ename, sal, mgr_name, mgr_sal)
SELECT 'FORD', 3000, 'JONES', 2975 FROM dual
UNION ALL SELECT 'SCOTT', 3000, 'JONES', 2975 FROM dual;
EXEC lab_check('04-ex07-G1', 'ANS04_07_G1', 'EXP04_07_G1')
SELECT * FROM ans04_07_g1 ORDER BY 1, 2, 3, 4;

PROMPT == [G2] 부하가 없는 직원
-- 조인 방향: a 를 '상사 후보'로 두고 a 의 부하 b 를 붙인다. 짝이 없는 a 가 리프다.
-- NOT IN (SELECT boss_id FROM staff) 로 쓰면 boss_id 에 NULL(나사장)이 있어 결과가 0행이 된다 → 08단원 ex05.
CREATE OR REPLACE VIEW ans04_07_g2 (name) AS
SELECT a.name FROM staff a LEFT JOIN staff b ON b.boss_id = a.staff_id WHERE b.staff_id IS NULL;
CREATE OR REPLACE VIEW exp04_07_g2 (name) AS
-- (name)
SELECT '박현석' FROM dual
UNION ALL SELECT '황수지' FROM dual;
EXEC lab_check('04-ex07-G2', 'ANS04_07_G2', 'EXP04_07_G2')
SELECT * FROM ans04_07_g2 ORDER BY 1;
