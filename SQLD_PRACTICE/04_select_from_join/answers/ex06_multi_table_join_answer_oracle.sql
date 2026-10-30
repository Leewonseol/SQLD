-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex06_multi_table_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex06_multi_table_join.md
-- =====================================================================

PROMPT == [G1] 팀별 경기장·선수 수
-- 경기장이 없는 숲시티를 남기려면 stadium 쪽도 LEFT JOIN. COUNT(*) 를 쓰면 선수 0명 팀이 1로 세어진다(이 데이터에는 0명 팀이 없다).
CREATE OR REPLACE VIEW ans04_06_g1 (team_name, stadium_name, player_cnt) AS
SELECT t.team_name, s.stadium_name, COUNT(p.player_id)
FROM team t LEFT JOIN stadium s ON t.stadium_id = s.stadium_id
            LEFT JOIN player p ON p.team_id = t.team_id
GROUP BY t.team_name, s.stadium_name;
CREATE OR REPLACE VIEW exp04_06_g1 (team_name, stadium_name, player_cnt) AS
-- (team_name, stadium_name, player_cnt)
SELECT '바다유나이티드', '바다경기장', 2 FROM dual
UNION ALL SELECT '숲시티', CAST(NULL AS VARCHAR2(100)), 1 FROM dual
UNION ALL SELECT '하늘FC', '하늘경기장', 2 FROM dual;
EXEC lab_check('04-ex06-G1', 'ANS04_06_G1', 'EXP04_06_G1')
SELECT * FROM ans04_06_g1 ORDER BY 1, 2, 3;

PROMPT == [G2] 10번 부서 부서명·사원·등급
-- EQUI 조건 1개 + NON EQUI 조건 1개 = 조인 조건 2개(테이블 3개).
CREATE OR REPLACE VIEW ans04_06_g2 (dname, ename, grade) AS
SELECT d.dname, e.ename, s.grade FROM emp e, dept d, salgrade s
WHERE e.deptno = d.deptno AND e.sal BETWEEN s.losal AND s.hisal AND e.deptno = 10;
CREATE OR REPLACE VIEW exp04_06_g2 (dname, ename, grade) AS
-- (dname, ename, grade)
SELECT 'ACCOUNTING', 'CLARK', 4 FROM dual
UNION ALL SELECT 'ACCOUNTING', 'KING', 5 FROM dual
UNION ALL SELECT 'ACCOUNTING', 'MILLER', 2 FROM dual;
EXEC lab_check('04-ex06-G2', 'ANS04_06_G2', 'EXP04_06_G2')
SELECT * FROM ans04_06_g2 ORDER BY 1, 2, 3;
