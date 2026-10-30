-- =====================================================================
-- H. 정답 및 검증 | 10_grouping_extensions ex03_cube | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_cube.md
-- =====================================================================

PROMPT == [G1] CUBE 의 직무 소계만
CREATE OR REPLACE VIEW ans10_03_g1 (job, cnt) AS
SELECT job, COUNT(*) FROM emp GROUP BY CUBE (deptno, job) HAVING GROUPING(deptno) = 1 AND GROUPING(job) = 0;
CREATE OR REPLACE VIEW exp10_03_g1 (job, cnt) AS
-- (job, cnt)
SELECT 'ANALYST', 2 FROM dual
UNION ALL SELECT 'CLERK', 4 FROM dual
UNION ALL SELECT 'MANAGER', 3 FROM dual
UNION ALL SELECT 'PRESIDENT', 1 FROM dual
UNION ALL SELECT 'SALESMAN', 4 FROM dual;
EXEC lab_check('10-ex03-G1', 'ANS10_03_G1', 'EXP10_03_G1')
SELECT * FROM ans10_03_g1 ORDER BY 1, 2;

PROMPT == [G2] CUBE(deptno, job) 행 수
CREATE OR REPLACE VIEW ans10_03_g2 (cnt) AS
SELECT COUNT(*) FROM (SELECT deptno, job FROM emp GROUP BY CUBE (deptno, job));
CREATE OR REPLACE VIEW exp10_03_g2 (cnt) AS
-- (cnt)
SELECT 18 FROM dual;
EXEC lab_check('10-ex03-G2', 'ANS10_03_G2', 'EXP10_03_G2')
SELECT * FROM ans10_03_g2 ORDER BY 1;
