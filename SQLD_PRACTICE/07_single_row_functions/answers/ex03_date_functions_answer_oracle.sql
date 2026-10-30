-- =====================================================================
-- H. 정답 및 검증 | 07_single_row_functions ex03_date_functions | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_date_functions.md
-- =====================================================================

PROMPT == [G1] 10번 부서 근속 개월 수(2024-03-31 기준)
-- DATEDIFF(MONTH) 는 '월 경계를 넘은 횟수'다. 기준일(31일)이 입사일의 일(9·17·23일)보다 크거나 같아서 보정 없이도 값이 같다.
-- 기준일이 2024-03-05 였다면 DATEDIFF 만 쓴 값이 1 크다. 그래서 CASE 로 보정했다.
CREATE OR REPLACE VIEW ans07_03_g1 (ename, months) AS
SELECT ename, TRUNC(MONTHS_BETWEEN(DATE '2024-03-31', hiredate)) FROM emp WHERE deptno = 10;
CREATE OR REPLACE VIEW exp07_03_g1 (ename, months) AS
-- (ename, months)
SELECT 'CLARK', 513 FROM dual
UNION ALL SELECT 'KING', 508 FROM dual
UNION ALL SELECT 'MILLER', 506 FROM dual;
EXEC lab_check('07-ex03-G1', 'ANS07_03_G1', 'EXP07_03_G1')
SELECT * FROM ans07_03_g1 ORDER BY 1, 2;

PROMPT == [G2] 2024년 2월 말일과 다음 날
CREATE OR REPLACE VIEW ans07_03_g2 (last_day, next_day) AS
SELECT TO_CHAR(LAST_DAY(DATE '2024-02-01'), 'YYYY-MM-DD'), TO_CHAR(LAST_DAY(DATE '2024-02-01') + 1, 'YYYY-MM-DD') FROM dual;
CREATE OR REPLACE VIEW exp07_03_g2 (last_day, next_day) AS
-- (last_day, next_day)
SELECT '2024-02-29', '2024-03-01' FROM dual;
EXEC lab_check('07-ex03-G2', 'ANS07_03_G2', 'EXP07_03_G2')
SELECT * FROM ans07_03_g2 ORDER BY 1, 2;
