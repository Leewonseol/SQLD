-- =====================================================================
-- H. 정답 및 검증 | 06_group_having ex03_having | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex03_having.md
-- =====================================================================

PROMPT == [G1] 평균 2000 이상·3명 이상 부서
CREATE OR REPLACE VIEW ans06_03_g1 (deptno, avg_sal) AS
SELECT deptno, ROUND(AVG(sal), 1) FROM emp GROUP BY deptno HAVING AVG(sal) >= 2000 AND COUNT(*) >= 3;
CREATE OR REPLACE VIEW exp06_03_g1 (deptno, avg_sal) AS
-- (deptno, avg_sal)
SELECT 10, 2916.7 FROM dual
UNION ALL SELECT 20, 2175 FROM dual;
EXEC lab_check('06-ex03-G1', 'ANS06_03_G1', 'EXP06_03_G1')
SELECT * FROM ans06_03_g1 ORDER BY 1, 2;

PROMPT == [G2] 커미션이 모두 NULL 인 부서
-- COUNT(comm) 은 NULL 을 세지 않으므로 0 이면 모두 NULL. MAX(comm) IS NULL 도 같은 뜻.
CREATE OR REPLACE VIEW ans06_03_g2 (deptno) AS
SELECT deptno FROM emp GROUP BY deptno HAVING COUNT(comm) = 0;
CREATE OR REPLACE VIEW exp06_03_g2 (deptno) AS
-- (deptno)
SELECT 10 FROM dual
UNION ALL SELECT 20 FROM dual;
EXEC lab_check('06-ex03-G2', 'ANS06_03_G2', 'EXP06_03_G2')
SELECT * FROM ans06_03_g2 ORDER BY 1;
