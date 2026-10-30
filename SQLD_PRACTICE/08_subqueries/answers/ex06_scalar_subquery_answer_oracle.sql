-- =====================================================================
-- H. 정답 및 검증 | 08_subqueries ex06_scalar_subquery | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_scalar_subquery.md
-- =====================================================================

PROMPT == [G1] 10번 부서 사원별 부서 평균
CREATE OR REPLACE VIEW ans08_06_g1 (ename, dept_avg) AS
SELECT e.ename, ROUND((SELECT AVG(x.sal) FROM emp x WHERE x.deptno = e.deptno), 2) FROM emp e WHERE e.deptno = 10;
CREATE OR REPLACE VIEW exp08_06_g1 (ename, dept_avg) AS
-- (ename, dept_avg)
SELECT 'CLARK', 2916.67 FROM dual
UNION ALL SELECT 'KING', 2916.67 FROM dual
UNION ALL SELECT 'MILLER', 2916.67 FROM dual;
EXEC lab_check('08-ex06-G1', 'ANS08_06_G1', 'EXP08_06_G1')
SELECT * FROM ans08_06_g1 ORDER BY 1, 2;

PROMPT == [G2] 작가별 작품 수
-- 스칼라 서브쿼리의 COUNT(*) 는 짝이 없어도 0 을 돌려준다(빈 집합 집계 → 1행). LEFT JOIN + COUNT(p.id) 와 같은 결과.
CREATE OR REPLACE VIEW ans08_06_g2 (name, cnt) AS
SELECT a.name, (SELECT COUNT(*) FROM paintings p WHERE p.artist_id = a.id) FROM artists a;
CREATE OR REPLACE VIEW exp08_06_g2 (name, cnt) AS
-- (name, cnt)
SELECT '박성진', 1 FROM dual
UNION ALL SELECT '백에서', 1 FROM dual
UNION ALL SELECT '이지현', 2 FROM dual
UNION ALL SELECT '정하나', 2 FROM dual
UNION ALL SELECT '황현석', 1 FROM dual;
EXEC lab_check('08-ex06-G2', 'ANS08_06_G2', 'EXP08_06_G2')
SELECT * FROM ans08_06_g2 ORDER BY 1, 2;
