-- =====================================================================
-- H. 정답 및 검증 | 04_select_from_join ex04_equi_join | Oracle
-- 사용법: ans 뷰 본문을 자기 답으로 바꿔 실행하면 lab_check 가 CHECK_PASS / CHECK_FAIL 을 출력한다.
-- 이 파일은 tools/gen_answers.py 가 tools/answer_specs 에서 생성했다. 문제 원문은 ../exercises/ex04_equi_join.md
-- =====================================================================

PROMPT == [G1] 부산 팀 선수
CREATE OR REPLACE VIEW ans04_04_g1 (player_name, team_name) AS
SELECT p.player_name, t.team_name FROM player p JOIN team t ON p.team_id = t.team_id WHERE t.region_name = '부산';
CREATE OR REPLACE VIEW exp04_04_g1 (player_name, team_name) AS
-- (player_name, team_name)
SELECT '권율', '바다유나이티드' FROM dual
UNION ALL SELECT '이순신', '바다유나이티드' FROM dual;
EXEC lab_check('04-ex04-G1', 'ANS04_04_G1', 'EXP04_04_G1')
SELECT * FROM ans04_04_g1 ORDER BY 1, 2;

PROMPT == [G2] GK 가 아닌 팀 소속 선수
-- 연개소(MF)는 팀이 없어 EQUI JOIN 에서 빠진다.
CREATE OR REPLACE VIEW ans04_04_g2 (player_name, position, team_name) AS
SELECT p.player_name, p.position, t.team_name FROM player p, team t WHERE p.team_id = t.team_id AND p.position <> 'GK';
CREATE OR REPLACE VIEW exp04_04_g2 (player_name, position, team_name) AS
-- (player_name, position, team_name)
SELECT '권율', 'FW', '바다유나이티드' FROM dual
UNION ALL SELECT '을지문', 'DF', '하늘FC' FROM dual;
EXEC lab_check('04-ex04-G2', 'ANS04_04_G2', 'EXP04_04_G2')
SELECT * FROM ans04_04_g2 ORDER BY 1, 2, 3;
