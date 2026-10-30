-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex06_top_n | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_top_n.md
-- =====================================================================

PROMPT == [G1] 가장 먼저 입사한 3명
-- SELECT ... WHERE ROWNUM <= 3 ORDER BY hiredate 는 '먼저 읽힌 3행'을 정렬할 뿐이라 우연히 맞을 수 있어도 틀린 답이다.
CREATE OR REPLACE VIEW ans06_06_g1 (ename, hire_ymd) AS
SELECT ename, TO_CHAR(hiredate, 'YYYY-MM-DD') FROM (SELECT ename, hiredate FROM emp ORDER BY hiredate) WHERE ROWNUM <= 3;
CREATE OR REPLACE VIEW exp06_06_g1 (ename, hire_ymd) AS
-- (ename, hire_ymd)
SELECT 'ALLEN', '1981-02-20' FROM dual
UNION ALL SELECT 'SMITH', '1980-12-17' FROM dual
UNION ALL SELECT 'WARD', '1981-02-22' FROM dual;
EXEC lab_check('06-ex06-G1', 'ANS06_06_G1', 'EXP06_06_G1')
SELECT * FROM ans06_06_g1 ORDER BY 1, 2;

PROMPT == [G2] 상위 2개 급여 값의 사원(동점 포함)
-- FETCH FIRST 2 ROWS WITH TIES / TOP 2 WITH TIES 는 '2번째 행과 같은 값까지'라 이 데이터에서는 결과가 같다.
-- 하지만 1위가 동점 3명이면 WITH TIES 는 1위 3명만 돌려준다. 값 기준 2위까지는 DENSE_RANK() <= 2 (11단원 ex03).
CREATE OR REPLACE VIEW ans06_06_g2 (ename, sal) AS
SELECT ename, sal FROM emp WHERE sal IN (SELECT DISTINCT sal FROM emp ORDER BY sal DESC FETCH FIRST 2 ROWS ONLY);
CREATE OR REPLACE VIEW exp06_06_g2 (ename, sal) AS
-- (ename, sal)
SELECT 'FORD', 3000 FROM dual
UNION ALL SELECT 'KING', 5000 FROM dual
UNION ALL SELECT 'SCOTT', 3000 FROM dual;
EXEC lab_check('06-ex06-G2', 'ANS06_06_G2', 'EXP06_06_G2')
SELECT * FROM ans06_06_g2 ORDER BY 1, 2;
