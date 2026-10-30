-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex05_non_equi_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex05_non_equi_join.md
-- =====================================================================

PROMPT == [G1] 등급 4 이상 사원
CREATE OR REPLACE VIEW ans04_05_g1 (ename, sal, grade) AS
SELECT e.ename, e.sal, s.grade FROM emp e JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal WHERE s.grade >= 4;
CREATE OR REPLACE VIEW exp04_05_g1 (ename, sal, grade) AS
-- (ename, sal, grade)
SELECT 'BLAKE', 2850, 4 FROM dual
UNION ALL SELECT 'CLARK', 2450, 4 FROM dual
UNION ALL SELECT 'FORD', 3000, 4 FROM dual
UNION ALL SELECT 'JONES', 2975, 4 FROM dual
UNION ALL SELECT 'KING', 5000, 5 FROM dual
UNION ALL SELECT 'SCOTT', 3000, 4 FROM dual;
EXEC lab_check('04-ex05-G1', 'ANS04_05_G1', 'EXP04_05_G1')
SELECT * FROM ans04_05_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 등급별 사원 수
-- 합계 3+3+2+5+1 = 14 = EMP 전체 행 수. 구간에 틈·겹침이 없다는 뜻이다.
CREATE OR REPLACE VIEW ans04_05_g2 (grade, cnt) AS
SELECT s.grade, COUNT(*) FROM emp e, salgrade s WHERE e.sal BETWEEN s.losal AND s.hisal GROUP BY s.grade;
CREATE OR REPLACE VIEW exp04_05_g2 (grade, cnt) AS
-- (grade, cnt)
SELECT 1, 3 FROM dual
UNION ALL SELECT 2, 3 FROM dual
UNION ALL SELECT 3, 2 FROM dual
UNION ALL SELECT 4, 5 FROM dual
UNION ALL SELECT 5, 1 FROM dual;
EXEC lab_check('04-ex05-G2', 'ANS04_05_G2', 'EXP04_05_G2')
SELECT * FROM ans04_05_g2 ORDER BY 1, 2;
