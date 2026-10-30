-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex07_regex | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex07_regex.md
-- =====================================================================

PROMPT == [G1] 모음 2개 이상 이름
-- SQL Server: TRANSLATE 로 모음을 # 으로 바꾸고, # 을 지운 길이와의 차이로 모음 수를 센다.
CREATE OR REPLACE VIEW ans07_07_g1 (ename) AS
SELECT ename FROM emp WHERE REGEXP_COUNT(ename, '[AEIOU]') >= 2;
CREATE OR REPLACE VIEW exp07_07_g1 (ename) AS
-- (ename)
SELECT 'ADAMS' FROM dual
UNION ALL SELECT 'ALLEN' FROM dual
UNION ALL SELECT 'BLAKE' FROM dual
UNION ALL SELECT 'JAMES' FROM dual
UNION ALL SELECT 'JONES' FROM dual
UNION ALL SELECT 'MARTIN' FROM dual
UNION ALL SELECT 'MILLER' FROM dual
UNION ALL SELECT 'TURNER' FROM dual;
EXEC lab_check('07-ex07-G1', 'ANS07_07_G1', 'EXP07_07_G1')
SELECT * FROM ans07_07_g1 ORDER BY 1;

PROMPT == [G2] 전화번호 가운데 덩어리
CREATE OR REPLACE VIEW ans07_07_g2 (mid) AS
SELECT REGEXP_SUBSTR('010-1234-5678', '[0-9]+', 1, 2) FROM dual;
CREATE OR REPLACE VIEW exp07_07_g2 (mid) AS
-- (mid)
SELECT '1234' FROM dual;
EXEC lab_check('07-ex07-G2', 'ANS07_07_G2', 'EXP07_07_G2')
SELECT * FROM ans07_07_g2 ORDER BY 1;
