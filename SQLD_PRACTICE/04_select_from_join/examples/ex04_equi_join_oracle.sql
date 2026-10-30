-- ex04 EQUI JOIN (PDF E-09, E-14)  | Oracle   데이터: [가상] PLAYER·TEAM
PROMPT == [Q1] Oracle 방식: 조인 조건을 WHERE 에 (골키퍼만)
SELECT p.player_name 선수명, p.back_no 등번호, t.team_name 팀명
FROM player p, team t
WHERE p.team_id = t.team_id
  AND p.position = 'GK'
ORDER BY p.back_no;

PROMPT == [Q2] ANSI 방식: 조인 조건은 ON, 일반 조건은 WHERE
SELECT p.player_name 선수명, p.back_no 등번호, t.team_name 팀명
FROM player p
INNER JOIN team t ON p.team_id = t.team_id
WHERE p.position = 'GK'
ORDER BY p.back_no;

PROMPT == [Q3] 전체 선수-팀 EQUI JOIN: team_id 가 NULL 인 선수(연개소)는 빠진다
SELECT p.player_name, p.team_id, t.team_name, t.region_name
FROM player p JOIN team t ON p.team_id = t.team_id
ORDER BY p.player_id;

PROMPT == [Q4] 테이블 별칭을 준 뒤 원래 테이블명으로 참조 -> 오류 (PDF E-09)
-- @expect-error: ORA-00904
SELECT player.player_name, t.team_name FROM player p, team t WHERE p.team_id = t.team_id;

PROMPT == [Q5] 양쪽에 같은 이름 컬럼(team_id)을 접두사 없이 SELECT -> 모호성 오류
-- @expect-error: ORA-00918
SELECT team_id FROM player p JOIN team t ON p.team_id = t.team_id;

PROMPT == [Q6] INNER JOIN 에서 ON/USING 생략 -> 오류 (PDF E-14 "ANSI 표준에서는 USING/ON 필수")
-- @expect-error: ORA-00905
SELECT p.player_name FROM player p INNER JOIN team t;
