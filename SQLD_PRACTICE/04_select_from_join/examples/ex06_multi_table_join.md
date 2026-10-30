# ex06 3개 이상 테이블 조인

> 근거: PDF추출본 E-11 · 데이터: 학습용 가상 데이터(PLAYER·TEAM·STADIUM) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을 하는가**: 여러 테이블을 연결 경로를 따라 차례로 결합한다. 테이블이 N개이면 모두 연결하는 데 조인 조건이 **최소 N−1개** 필요하다(PDF: "3개의 테이블 조인이면 최소 2개의 조인 조건").
* **언제 쓰는가**: 선수 → 팀 → 경기장처럼 FK가 사슬로 이어질 때.
* **차이**: 조건이 하나라도 빠지면 그 테이블과는 카티션 곱(CROSS JOIN)이 된다. 오류 없이 행 수만 늘어나므로 더 위험하다.

## B. 입력 데이터
PLAYER 6행(연개소 team NULL), TEAM 3행(K03 숲시티 stadium NULL), STADIUM 3행(S03 숲경기장은 어느 팀도 쓰지 않음).

## C. 실행 SQL
[Oracle](ex06_multi_table_join_oracle.sql) · [SQL Server](ex06_multi_table_join_sqlserver.sql)

## D. 결과 예측 문제
1. Q1·Q2는 몇 행인가? 빠지는 선수 두 명과 각각의 이유는?
2. Q3(조건 1개 누락)은 몇 행인가?
3. Q4는 몇 행이고, 김유신·연개소의 경기장 값은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_multi_table_join_oracle.sql -->
```text
== [Q1] 3개 테이블 = 조인 조건 최소 2개 (Oracle WHERE 방식)

PLAYER_NAME|POSITION|REGION_NAME|TEAM_NAME|STADIUM_NAME
강감찬|GK|서울|하늘FC|하늘경기장
을지문|DF|서울|하늘FC|하늘경기장
이순신|GK|부산|바다유나이티드|바다경기장
권율|FW|부산|바다유나이티드|바다경기장

4 rows selected.

== [Q2] ANSI 방식

PLAYER_NAME|POSITION|REGION_NAME|TEAM_NAME|STADIUM_NAME
강감찬|GK|서울|하늘FC|하늘경기장
을지문|DF|서울|하늘FC|하늘경기장
이순신|GK|부산|바다유나이티드|바다경기장
권율|FW|부산|바다유나이티드|바다경기장

4 rows selected.

== [Q3] 조인 조건 하나를 빠뜨리면: player-team 은 조인되지만 stadium 과는 카티션 곱 (선수-팀 5행 x 경기장 3 = 15행)

ROWS_MISSING_CONDITION
15

1 row selected.

== [Q4] 모든 선수를 남기려면 LEFT JOIN 을 연쇄해야 한다

PLAYER_NAME|TEAM_NAME|STADIUM_NAME
강감찬|하늘FC|하늘경기장
을지문|하늘FC|하늘경기장
이순신|바다유나이티드|바다경기장
권율|바다유나이티드|바다경기장
김유신|숲시티|(null)
연개소|(null)|(null)

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_multi_table_join_sqlserver.sql -->
```text
== [Q1] WHERE 방식
player_name|position|region_name|team_name|stadium_name
-----------|--------|-----------|---------|------------
강감찬|GK|서울|하늘FC|하늘경기장
을지문|DF|서울|하늘FC|하늘경기장
이순신|GK|부산|바다유나이티드|바다경기장
권율|FW|부산|바다유나이티드|바다경기장

(4 rows affected)
== [Q2] ANSI 방식
player_name|position|region_name|team_name|stadium_name
-----------|--------|-----------|---------|------------
강감찬|GK|서울|하늘FC|하늘경기장
을지문|DF|서울|하늘FC|하늘경기장
이순신|GK|부산|바다유나이티드|바다경기장
권율|FW|부산|바다유나이티드|바다경기장

(4 rows affected)
== [Q3] 조인 조건 하나 누락
rows_missing_condition
----------------------
15

(1 rows affected)
== [Q4] LEFT JOIN 연쇄
player_name|team_name|stadium_name
-----------|---------|------------
강감찬|하늘FC|하늘경기장
을지문|하늘FC|하늘경기장
이순신|바다유나이티드|바다경기장
권율|바다유나이티드|바다경기장
김유신|숲시티|NULL
연개소|NULL|NULL

(6 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1·Q2 = 4행: 연개소는 team_id가 NULL이라 PLAYER–TEAM 조인에서 빠진다. 김유신은 팀 K03의 stadium_id가 NULL이라 TEAM–STADIUM 조인에서 빠진다.
* Q3 = 15행: PLAYER–TEAM 조인 5행 × STADIUM 3행. 오류는 나지 않는다.
* Q4 = 6행: LEFT JOIN을 연쇄하면 PLAYER 기준으로 모든 행이 남는다. **두 번째 조인도 LEFT여야 한다.** 두 번째를 INNER로 바꾸면 김유신·연개소가 다시 빠진다(F-1).

## F. 변형 문제
1. Q4의 두 번째 `LEFT JOIN stadium`을 `INNER JOIN`으로 바꾸면 몇 행인가?
2. 아무 팀도 쓰지 않는 S03 숲경기장까지 출력하려면 어떤 조인이 필요한가?
3. 조인 순서를 `stadium → team → player`로 바꾸어 Q2를 다시 쓰면 결과가 같은가? (INNER만 쓰면 같다)

G: [exercises/ex06_multi_table_join.md](../exercises/ex06_multi_table_join.md)
