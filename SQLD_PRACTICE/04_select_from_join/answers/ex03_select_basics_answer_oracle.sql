-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex03_select_basics | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_select_basics.md
-- =====================================================================

PROMPT == [G1] 30번 부서 총수령액
-- sal + comm 만 쓰면 BLAKE·JAMES 가 NULL 이 되어 CHECK_FAIL.
CREATE OR REPLACE VIEW ans04_03_g1 (ename, total_pay) AS
SELECT ename, sal + NVL(comm, 0) FROM emp WHERE deptno = 30;
CREATE OR REPLACE VIEW exp04_03_g1 (ename, total_pay) AS
-- (ename, total_pay)
SELECT 'ALLEN', 1900 FROM dual
UNION ALL SELECT 'BLAKE', 2850 FROM dual
UNION ALL SELECT 'JAMES', 950 FROM dual
UNION ALL SELECT 'MARTIN', 2650 FROM dual
UNION ALL SELECT 'TURNER', 1500 FROM dual
UNION ALL SELECT 'WARD', 1750 FROM dual;
EXEC lab_check('04-ex03-G1', 'ANS04_03_G1', 'EXP04_03_G1')
SELECT * FROM ans04_03_g1 ORDER BY 1, 2;

PROMPT == [G2] (부서, 직무) 조합 수
-- COUNT(DISTINCT deptno, job) 은 두 DBMS 모두 오류(인수 1개만). Oracle 은 COUNT(DISTINCT deptno || job) 로도 가능하지만 값이 이어 붙어 우연히 같아질 위험이 있다.
CREATE OR REPLACE VIEW ans04_03_g2 (combo_cnt) AS
SELECT COUNT(*) FROM (SELECT DISTINCT deptno, job FROM emp);
CREATE OR REPLACE VIEW exp04_03_g2 (combo_cnt) AS
-- (combo_cnt)
SELECT 9 FROM dual;
EXEC lab_check('04-ex03-G2', 'ANS04_03_G2', 'EXP04_03_G2')
SELECT * FROM ans04_03_g2 ORDER BY 1;
