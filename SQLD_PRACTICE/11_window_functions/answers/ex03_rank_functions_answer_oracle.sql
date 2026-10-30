-- =====================================================================
-- H. 정답 및 검증 | 11_window_functions ex03_rank_functions | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_rank_functions.md
-- =====================================================================

PROMPT == [G1] 부서별 DENSE_RANK 2위
-- RANK 로 쓰면 20번 부서는 SCOTT·FORD 공동 1위 다음이 3위라 2위가 없다 → 20번 행이 빠져 CHECK_FAIL.
CREATE OR REPLACE VIEW ans11_03_g1 (deptno, ename, sal) AS
SELECT deptno, ename, sal FROM (SELECT deptno, ename, sal, DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) dr FROM emp) WHERE dr = 2;
CREATE OR REPLACE VIEW exp11_03_g1 (deptno, ename, sal) AS
-- (deptno, ename, sal)
SELECT 10, 'CLARK', 2450 FROM dual
UNION ALL SELECT 20, 'JONES', 2975 FROM dual
UNION ALL SELECT 30, 'ALLEN', 1600 FROM dual;
EXEC lab_check('11-ex03-G1', 'ANS11_03_G1', 'EXP11_03_G1')
SELECT * FROM ans11_03_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 전체 4~6위(ROW_NUMBER)
CREATE OR REPLACE VIEW ans11_03_g2 (rn, ename) AS
SELECT rn, ename FROM (SELECT ename, ROW_NUMBER() OVER (ORDER BY sal DESC, empno) rn FROM emp) WHERE rn BETWEEN 4 AND 6;
CREATE OR REPLACE VIEW exp11_03_g2 (rn, ename) AS
-- (rn, ename)
SELECT 4, 'JONES' FROM dual
UNION ALL SELECT 5, 'BLAKE' FROM dual
UNION ALL SELECT 6, 'CLARK' FROM dual;
EXEC lab_check('11-ex03-G2', 'ANS11_03_G2', 'EXP11_03_G2')
SELECT * FROM ans11_03_g2 ORDER BY 1, 2;
