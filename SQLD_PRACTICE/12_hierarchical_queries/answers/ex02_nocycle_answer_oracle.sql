-- =====================================================================
-- H. 정답 및 검증 | 12_hierarchical_queries ex02_nocycle | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex02_nocycle.md
-- =====================================================================

PROMPT == [G1] 2000 부터 전개, 순환 표시
CREATE OR REPLACE VIEW ans12_02_g1 (emp_id, lvl, is_cycle) AS
SELECT emp_id, LEVEL, CONNECT_BY_ISCYCLE FROM emp1 START WITH emp_id = 2000 CONNECT BY NOCYCLE PRIOR emp_id = mgr_id;
CREATE OR REPLACE VIEW exp12_02_g1 (emp_id, lvl, is_cycle) AS
-- (emp_id, lvl, is_cycle)
SELECT 1000, 2, 1 FROM dual
UNION ALL SELECT 2000, 1, 0 FROM dual;
EXEC lab_check('12-ex02-G1', 'ANS12_02_G1', 'EXP12_02_G1')
SELECT * FROM ans12_02_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 서로가 관리자인 쌍의 수
-- a.emp_id < b.emp_id 를 빼면 (1000,2000)·(2000,1000) 이 둘 다 세어져 2.
CREATE OR REPLACE VIEW ans12_02_g2 (pair_cnt) AS
SELECT COUNT(*) FROM emp1 a JOIN emp1 b ON a.mgr_id = b.emp_id AND b.mgr_id = a.emp_id WHERE a.emp_id < b.emp_id;
CREATE OR REPLACE VIEW exp12_02_g2 (pair_cnt) AS
-- (pair_cnt)
SELECT 1 FROM dual;
EXEC lab_check('12-ex02-G2', 'ANS12_02_G2', 'EXP12_02_G2')
SELECT * FROM ans12_02_g2 ORDER BY 1;
