-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex01_char_functions | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_char_functions.md
-- =====================================================================

PROMPT == [G1] 10번 부서 이름 첫 글자 대문자·길이
-- Oracle 의 INITCAP 은 공백·기호 뒤 글자도 대문자로 만든다('sql developer' → 'Sql Developer'). SQL Server 식은 첫 글자만 처리한다.
CREATE OR REPLACE VIEW ans07_01_g1 (name_cap, name_len) AS
SELECT INITCAP(ename), LENGTH(ename) FROM emp WHERE deptno = 10;
CREATE OR REPLACE VIEW exp07_01_g1 (name_cap, name_len) AS
-- (name_cap, name_len)
SELECT 'Clark', 5 FROM dual
UNION ALL SELECT 'King', 4 FROM dual
UNION ALL SELECT 'Miller', 6 FROM dual;
EXEC lab_check('07-ex01-G1', 'ANS07_01_G1', 'EXP07_01_G1')
SELECT * FROM ans07_01_g1 ORDER BY 1, 2;

PROMPT == [G2] 20번 부서 이름의 A 위치
-- CHARINDEX(찾을값, 대상) — INSTR(대상, 찾을값) 과 인수 순서가 반대다. 순서를 바꾸면 모두 0.
CREATE OR REPLACE VIEW ans07_01_g2 (ename, pos_a) AS
SELECT ename, INSTR(ename, 'A') FROM emp WHERE deptno = 20;
CREATE OR REPLACE VIEW exp07_01_g2 (ename, pos_a) AS
-- (ename, pos_a)
SELECT 'ADAMS', 1 FROM dual
UNION ALL SELECT 'FORD', 0 FROM dual
UNION ALL SELECT 'JONES', 0 FROM dual
UNION ALL SELECT 'SCOTT', 0 FROM dual
UNION ALL SELECT 'SMITH', 0 FROM dual;
EXEC lab_check('07-ex01-G2', 'ANS07_01_G2', 'EXP07_01_G2')
SELECT * FROM ans07_01_g2 ORDER BY 1, 2;
