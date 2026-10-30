-- =====================================================================
-- H. 정답 및 검증 | 09_set_operations ex03_set_vs_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_set_vs_join.md
-- =====================================================================

PROMPT == [G1] NULL 을 같게 보는 NOT EXISTS
CREATE OR REPLACE VIEW ans09_03_g1 (v) AS
SELECT DISTINCT a.v FROM s_a a WHERE NOT EXISTS (SELECT 1 FROM s_b b WHERE b.v = a.v OR (b.v IS NULL AND a.v IS NULL));
CREATE OR REPLACE VIEW exp09_03_g1 (v) AS
-- (v)
SELECT 1 FROM dual;
EXEC lab_check('09-ex03-G1', 'ANS09_03_G1', 'EXP09_03_G1')
SELECT * FROM ans09_03_g1 ORDER BY 1;

PROMPT == [G2] 공통 값 INNER JOIN
-- INTERSECT 는 {2, NULL}. JOIN 은 NULL 을 짝짓지 못해 {2}.
CREATE OR REPLACE VIEW ans09_03_g2 (v) AS
SELECT DISTINCT a.v FROM s_a a JOIN s_b b ON a.v = b.v;
CREATE OR REPLACE VIEW exp09_03_g2 (v) AS
-- (v)
SELECT 2 FROM dual;
EXEC lab_check('09-ex03-G2', 'ANS09_03_G2', 'EXP09_03_G2')
SELECT * FROM ans09_03_g2 ORDER BY 1;
