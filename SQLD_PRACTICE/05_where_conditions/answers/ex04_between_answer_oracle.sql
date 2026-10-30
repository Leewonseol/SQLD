-- =====================================================================
-- H. 정답 및 검증 | 05_where_conditions ex04_between | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_between.md
-- =====================================================================

PROMPT == [G1] 1981-01-01 ~ 1981-06-30 입사
-- hiredate 에 시각이 없으므로 BETWEEN 으로 충분하다. 시각이 있다면 hiredate < DATE '1981-07-01'.
CREATE OR REPLACE VIEW ans05_04_g1 (ename, hire_ymd) AS
SELECT ename, TO_CHAR(hiredate, 'YYYY-MM-DD') FROM emp WHERE hiredate BETWEEN DATE '1981-01-01' AND DATE '1981-06-30';
CREATE OR REPLACE VIEW exp05_04_g1 (ename, hire_ymd) AS
-- (ename, hire_ymd)
SELECT 'ALLEN', '1981-02-20' FROM dual
UNION ALL SELECT 'BLAKE', '1981-05-01' FROM dual
UNION ALL SELECT 'CLARK', '1981-06-09' FROM dual
UNION ALL SELECT 'JONES', '1981-04-02' FROM dual
UNION ALL SELECT 'WARD', '1981-02-22' FROM dual;
EXEC lab_check('05-ex04-G1', 'ANS05_04_G1', 'EXP05_04_G1')
SELECT * FROM ans05_04_g1 ORDER BY 1, 2;

PROMPT == [G2] 2024-03-31 하루 전체
-- ts = DATE '2024-03-31' 로 쓰면 00:00 인 id 3 만 나온다.
CREATE OR REPLACE VIEW ans05_04_g2 (id) AS
SELECT id FROM w_ts WHERE ts >= DATE '2024-03-31' AND ts < DATE '2024-04-01';
CREATE OR REPLACE VIEW exp05_04_g2 (id) AS
-- (id)
SELECT 3 FROM dual
UNION ALL SELECT 4 FROM dual;
EXEC lab_check('05-ex04-G2', 'ANS05_04_G2', 'EXP05_04_G2')
SELECT * FROM ans05_04_g2 ORDER BY 1;
