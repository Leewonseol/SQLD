# ex04 EQUI JOIN과 테이블 별칭 규칙

> 근거: PDF추출본 E-09, E-14 · 데이터: 학습용 가상 데이터(PLAYER 6행, TEAM 3행. PDF 쿼리 구조만 따름) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을 하는가**: 두 테이블에서 `=` 조건을 만족하는 행 쌍만 결합한다(INNER). 보통 PK–FK를 기준으로 하지만 PDF 말처럼 "반드시 PK–FK 관계일 필요는 없다". 값이 같으면 어떤 컬럼끼리도 EQUI JOIN 할 수 있다.
* **작성 방식 두 가지**: Oracle 전통 방식은 조인 조건을 WHERE에, ANSI 방식은 `INNER JOIN ... ON`에 쓴다. 두 DBMS 모두 두 방식을 지원한다. ANSI 방식에서 INNER는 생략할 수 있다(`JOIN`).
* **별칭 규칙**: FROM에서 테이블 별칭을 주면, 그 쿼리의 다른 절에서는 원래 테이블명으로 참조할 수 없다. 두 테이블에 같은 컬럼명이 있으면 반드시 접두사를 붙인다.

## B. 입력 데이터 (학습용 가상 데이터)
* TEAM(team_id PK, team_name, region_name, stadium_id FK→STADIUM): K01 하늘FC 서울 / K02 바다유나이티드 부산 / K03 숲시티 대전(stadium NULL)
* PLAYER(player_id PK, player_name, position, back_no, team_id FK→TEAM): 강감찬 GK K01, 을지문 DF K01, 이순신 GK K02, 권율 FW K02, 김유신 GK K03, **연개소 MF NULL**

## C. 실행 SQL
[Oracle](ex04_equi_join_oracle.sql) · [SQL Server](ex04_equi_join_sqlserver.sql)

## D. 결과 예측 문제
1. Q1과 Q2는 몇 행이고, 등번호 순서는 어떻게 되는가?
2. Q3에서 빠지는 선수는 누구이고, 이유는 무엇인가?
3. Q4·Q5·Q6은 각각 어떤 이유로 실패하는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_equi_join_oracle.sql -->
```text
== [Q1] Oracle 방식: 조인 조건을 WHERE 에 (골키퍼만)

선수명|등번호|팀명
강감찬|1|하늘FC
이순신|21|바다유나이티드
김유신|31|숲시티

3 rows selected.

== [Q2] ANSI 방식: 조인 조건은 ON, 일반 조건은 WHERE

선수명|등번호|팀명
강감찬|1|하늘FC
이순신|21|바다유나이티드
김유신|31|숲시티

3 rows selected.

== [Q3] 전체 선수-팀 EQUI JOIN: team_id 가 NULL 인 선수(연개소)는 빠진다

PLAYER_NAME|TEAM_ID|TEAM_NAME|REGION_NAME
강감찬|K01|하늘FC|서울
을지문|K01|하늘FC|서울
이순신|K02|바다유나이티드|부산
권율|K02|바다유나이티드|부산
김유신|K03|숲시티|대전

5 rows selected.

== [Q4] 테이블 별칭을 준 뒤 원래 테이블명으로 참조 -> 오류 (PDF E-09)
SELECT player.player_name, t.team_name FROM player p, team t WHERE p.team_id = t.team_id
       *
ERROR at line 1:
ORA-00904: "PLAYER"."PLAYER_NAME": invalid identifier

== [Q5] 양쪽에 같은 이름 컬럼(team_id)을 접두사 없이 SELECT -> 모호성 오류
SELECT team_id FROM player p JOIN team t ON p.team_id = t.team_id
       *
ERROR at line 1:
ORA-00918: column ambiguously defined

== [Q6] INNER JOIN 에서 ON/USING 생략 -> 오류 (PDF E-14 "ANSI 표준에서는 USING/ON 필수")
SELECT p.player_name FROM player p INNER JOIN team t
                                                   *
ERROR at line 1:
ORA-00905: missing keyword
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_equi_join_sqlserver.sql -->
```text
== [Q1] WHERE 절 조인 (SQL Server 도 지원)
선수명|등번호|팀명
---|---|--
강감찬|1|하늘FC
이순신|21|바다유나이티드
김유신|31|숲시티

(3 rows affected)
== [Q2] ANSI INNER JOIN ... ON
선수명|등번호|팀명
---|---|--
강감찬|1|하늘FC
이순신|21|바다유나이티드
김유신|31|숲시티

(3 rows affected)
== [Q3] 전체 선수-팀
player_name|team_id|team_name|region_name
-----------|-------|---------|-----------
강감찬|K01|하늘FC|서울
을지문|K01|하늘FC|서울
이순신|K02|바다유나이티드|부산
권율|K02|바다유나이티드|부산
김유신|K03|숲시티|대전

(5 rows affected)
== [Q4] 별칭을 준 뒤 원래 테이블명 참조 -> 오류
Msg 4104, Level 16, State 1, Server a70f428a7f8a, Line 2
The multi-part identifier "player.player_name" could not be bound.
== [Q5] 모호한 컬럼명 -> 오류
Msg 209, Level 16, State 1, Server a70f428a7f8a, Line 2
Ambiguous column name 'team_id'.
== [Q6] INNER JOIN 에서 ON 생략 -> 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near ';'.
```
<!-- /RESULT -->

**이유**
* Q1 = Q2: GK 3명(강감찬 1, 이순신 21, 김유신 31). 작성 방식만 다르고 의미는 같다.
* Q3: 연개소는 team_id가 NULL이다. `NULL = 'K01'`은 TRUE가 아니라 UNKNOWN이므로 짝이 없다 → 5행.
* Q4: 별칭 `p`를 준 뒤 `player.player_name` → Oracle ORA-00904, SQL Server Msg 4104.
* Q5: `team_id`가 양쪽에 있다 → Oracle ORA-00918, SQL Server Msg 209.
* Q6: ANSI INNER JOIN에 ON·USING이 없다 → Oracle ORA-00905, SQL Server Msg 102.

## F. 변형 문제
1. Q3을 LEFT JOIN으로 바꾸면 몇 행인가? 연개소의 team_name은?
2. Q1의 `p.position = 'GK'`를 ON 안으로 옮기면(INNER JOIN) 결과가 달라지는가? (INNER에서는 같다. OUTER에서는 다르다 → ex11)
3. PK–FK가 아닌 `region_name`으로 두 팀 테이블을 셀프 EQUI JOIN 하면 어떤 결과가 나오는가?

G: [exercises/ex04_equi_join.md](../exercises/ex04_equi_join.md)
