-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex01_aggregates | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex01_aggregates.md
-- =====================================================================

PROMPT == [G1] 사원 수·커미션 수·커미션 평균(NULL=0)
-- AVG(comm) 이면 2200/4 = 550 → CHECK_FAIL. 문제는 'NULL 을 0 으로' 이므로 분모가 14.
CREATE OR REPLACE VIEW ans06_01_g1 (emp_cnt, comm_cnt, avg_comm) AS
SELECT COUNT(*), COUNT(comm), ROUND(AVG(NVL(comm, 0)), 2) FROM emp;
CREATE OR REPLACE VIEW exp06_01_g1 (emp_cnt, comm_cnt, avg_comm) AS
-- (emp_cnt, comm_cnt, avg_comm)
SELECT 14, 4, 157.14 FROM dual;
EXEC lab_check('06-ex01-G1', 'ANS06_01_G1', 'EXP06_01_G1')
SELECT * FROM ans06_01_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 40번 부서 인원·합계(0)
-- GROUP BY deptno 를 붙이면 그룹이 없어 0행 → CHECK_FAIL. SUM(NVL(sal,0)) 은 대상 행이 없어 여전히 NULL.
CREATE OR REPLACE VIEW ans06_01_g2 (cnt, total) AS
SELECT COUNT(*), NVL(SUM(sal), 0) FROM emp WHERE deptno = 40;
CREATE OR REPLACE VIEW exp06_01_g2 (cnt, total) AS
-- (cnt, total)
SELECT 0, 0 FROM dual;
EXEC lab_check('06-ex01-G2', 'ANS06_01_G2', 'EXP06_01_G2')
SELECT * FROM ans06_01_g2 ORDER BY 1, 2;
