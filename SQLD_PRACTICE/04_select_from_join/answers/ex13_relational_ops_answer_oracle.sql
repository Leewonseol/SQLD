-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex13_relational_ops | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex13_relational_ops.md
-- =====================================================================

PROMPT == [G1] DB 수강 학생
CREATE OR REPLACE VIEW ans04_13_g1 (student) AS
SELECT DISTINCT student FROM enroll WHERE course = 'DB';
CREATE OR REPLACE VIEW exp04_13_g1 (student) AS
-- (student)
SELECT '민수' FROM dual
UNION ALL SELECT '지영' FROM dual
UNION ALL SELECT '하늘' FROM dual;
EXEC lab_check('04-ex13-G1', 'ANS04_13_G1', 'EXP04_13_G1')
SELECT * FROM ans04_13_g1 ORDER BY 1;

PROMPT == [G2] 필수 과목 중 하나라도 빠진 학생
-- DIVIDE(이중 NOT EXISTS)에서 바깥 NOT 을 뺀 것. ENROLL 에 없는 학생(아무 과목도 안 들은 학생)은 이 방식으로 찾을 수 없다 → 학생 마스터 테이블이 필요하다.
CREATE OR REPLACE VIEW ans04_13_g2 (student) AS
SELECT DISTINCT e.student FROM enroll e
WHERE EXISTS (SELECT 1 FROM req_course r WHERE NOT EXISTS (SELECT 1 FROM enroll e2 WHERE e2.student = e.student AND e2.course = r.course));
CREATE OR REPLACE VIEW exp04_13_g2 (student) AS
-- (student)
SELECT '지영' FROM dual;
EXEC lab_check('04-ex13-G2', 'ANS04_13_G2', 'EXP04_13_G2')
SELECT * FROM ans04_13_g2 ORDER BY 1;
