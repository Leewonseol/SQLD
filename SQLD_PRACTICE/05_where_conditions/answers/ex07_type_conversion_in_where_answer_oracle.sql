-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex07_type_conversion_in_where | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_type_conversion_in_where.md
-- =====================================================================

PROMPT == [G1] code = '10'
CREATE OR REPLACE VIEW ans05_07_g1 (id, code) AS
SELECT id, code FROM w_code WHERE code = '10';
CREATE OR REPLACE VIEW exp05_07_g1 (id, code) AS
-- (id, code)
SELECT 4, '10' FROM dual;
EXEC lab_check('05-ex07-G1', 'ANS05_07_G1', 'EXP05_07_G1')
SELECT * FROM ans05_07_g1 ORDER BY 1, 2;

PROMPT == [G2] 숫자 1 로 해석되는 code 수(오류 없이)
-- Oracle: TO_NUMBER(... DEFAULT NULL ON CONVERSION ERROR) 는 12.2 이상(19c 포함). VALIDATE_CONVERSION(code AS NUMBER) = 1 로 판별도 가능.
-- SQL Server: TRY_CAST / TRY_CONVERT 는 2012 이상. 변환 실패 시 NULL.
CREATE OR REPLACE VIEW ans05_07_g2 (cnt) AS
SELECT COUNT(*) FROM w_code WHERE TO_NUMBER(code DEFAULT NULL ON CONVERSION ERROR) = 1;
CREATE OR REPLACE VIEW exp05_07_g2 (cnt) AS
-- (cnt)
SELECT 3 FROM dual;
EXEC lab_check('05-ex07-G2', 'ANS05_07_G2', 'EXP05_07_G2')
SELECT * FROM ans05_07_g2 ORDER BY 1;
