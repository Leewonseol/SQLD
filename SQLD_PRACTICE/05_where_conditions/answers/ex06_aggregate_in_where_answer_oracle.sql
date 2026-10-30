-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex06_aggregate_in_where | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_aggregate_in_where.md
-- =====================================================================

PROMPT == [G1] 4명 이상 직무
CREATE OR REPLACE VIEW ans05_06_g1 (job, cnt) AS
SELECT job, COUNT(*) FROM emp GROUP BY job HAVING COUNT(*) >= 4;
CREATE OR REPLACE VIEW exp05_06_g1 (job, cnt) AS
-- (job, cnt)
SELECT 'CLERK', 4 FROM dual
UNION ALL SELECT 'SALESMAN', 4 FROM dual;
EXEC lab_check('05-ex06-G1', 'ANS05_06_G1', 'EXP05_06_G1')
SELECT * FROM ans05_06_g1 ORDER BY 1, 2;

PROMPT == [G2] 최고 급여자
-- WHERE sal = MAX(sal) → ORA-00934 / Msg 147.
CREATE OR REPLACE VIEW ans05_06_g2 (ename, sal) AS
SELECT ename, sal FROM emp WHERE sal = (SELECT MAX(sal) FROM emp);
CREATE OR REPLACE VIEW exp05_06_g2 (ename, sal) AS
-- (ename, sal)
SELECT 'KING', 5000 FROM dual;
EXEC lab_check('05-ex06-G2', 'ANS05_06_G2', 'EXP05_06_G2')
SELECT * FROM ans05_06_g2 ORDER BY 1, 2;
