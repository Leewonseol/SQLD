-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex08_having_update_subquery | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex08_having_update_subquery.md
-- =====================================================================

PROMPT == [G1] 30번 부서 comm 갱신 미리보기
-- 실제 UPDATE: UPDATE emp e SET comm = NVL((SELECT ...), 0) WHERE deptno = 30. 갱신 전에 같은 식을 SELECT 로 확인하는 습관.
CREATE OR REPLACE VIEW ans08_08_g1 (ename, new_comm) AS
SELECT e.ename, NVL((SELECT b.amt FROM bonus b WHERE b.empno = e.empno), 0) FROM emp e WHERE e.deptno = 30;
CREATE OR REPLACE VIEW exp08_08_g1 (ename, new_comm) AS
-- (ename, new_comm)
SELECT 'ALLEN', 200 FROM dual
UNION ALL SELECT 'BLAKE', 0 FROM dual
UNION ALL SELECT 'JAMES', 0 FROM dual
UNION ALL SELECT 'MARTIN', 0 FROM dual
UNION ALL SELECT 'TURNER', 0 FROM dual
UNION ALL SELECT 'WARD', 0 FROM dual;
EXEC lab_check('08-ex08-G1', 'ANS08_08_G1', 'EXP08_08_G1')
SELECT * FROM ans08_08_g1 ORDER BY 1, 2;

PROMPT == [G2] 평균 급여가 20번 부서보다 낮은 부서
CREATE OR REPLACE VIEW ans08_08_g2 (deptno) AS
SELECT deptno FROM emp GROUP BY deptno HAVING AVG(sal) < (SELECT AVG(sal) FROM emp WHERE deptno = 20);
CREATE OR REPLACE VIEW exp08_08_g2 (deptno) AS
-- (deptno)
SELECT 30 FROM dual;
EXEC lab_check('08-ex08-G2', 'ANS08_08_G2', 'EXP08_08_G2')
SELECT * FROM ans08_08_g2 ORDER BY 1;
