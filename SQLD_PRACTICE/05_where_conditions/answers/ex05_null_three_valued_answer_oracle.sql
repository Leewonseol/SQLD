-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex05_null_three_valued | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_null_three_valued.md
-- =====================================================================

PROMPT == [G1] 커미션 500 미만 또는 NULL
-- comm < 500 만 쓰면 2(ALLEN 300, TURNER 0).
CREATE OR REPLACE VIEW ans05_05_g1 (cnt) AS
SELECT COUNT(*) FROM emp WHERE comm < 500 OR comm IS NULL;
CREATE OR REPLACE VIEW exp05_05_g1 (cnt) AS
-- (cnt)
SELECT 12 FROM dual;
EXEC lab_check('05-ex05-G1', 'ANS05_05_G1', 'EXP05_05_G1')
SELECT * FROM ans05_05_g1 ORDER BY 1;

PROMPT == [G2] 관리자 7698 아님: NULL 제외/포함
CREATE OR REPLACE VIEW ans05_05_g2 (excl_null, incl_null) AS
SELECT (SELECT COUNT(*) FROM emp WHERE mgr <> 7698), (SELECT COUNT(*) FROM emp WHERE mgr <> 7698 OR mgr IS NULL) FROM dual;
CREATE OR REPLACE VIEW exp05_05_g2 (excl_null, incl_null) AS
-- (excl_null, incl_null)
SELECT 8, 9 FROM dual;
EXEC lab_check('05-ex05-G2', 'ANS05_05_G2', 'EXP05_05_G2')
SELECT * FROM ans05_05_g2 ORDER BY 1, 2;
