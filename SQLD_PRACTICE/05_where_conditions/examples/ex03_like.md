# ex03 LIKE · 와일드카드 · ESCAPE

> 근거: PDF추출본 E-06("LIKE '비교문자열' — 비교문자열과 형태 일치"), 요구목록 §7. 와일드카드 상세 설명은 추출본에 없음 · 데이터: EMP, W_LIKE(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `%`: 0글자 이상 / `_`: 정확히 1글자 / `ESCAPE 'c'`: c 다음의 `%`, `_`를 문자 그대로 비교한다.
* NULL은 어떤 패턴과도 일치하지 않는다(`LIKE '%'`도 마찬가지).
* **DBMS 차이**: 대소문자 구분은 데이터 정렬(collation)에 따른다. Oracle 기본은 구분한다. SQL Server 기본 `..._CI_AS`는 구분하지 않는다. SQL Server는 `[abc]`, `[0-9]`, `[^a]` 문자 집합도 지원한다.

## B. 입력 데이터 (학습용 가상 데이터)
W_LIKE(id PK, txt): 1 `A_B`, 2 `AXB`, 3 `AB`, 4 `100%`, 5 `1000`, 6 `ab`, 7 NULL

## C. 실행 SQL
[Oracle](ex03_like_oracle.sql) · [SQL Server](ex03_like_sqlserver.sql)

## D. 결과 예측 문제
1. `'A_B'` 패턴에 일치하는 id는?
2. `LIKE 'A%'`는 두 DBMS에서 각각 몇 행인가?
3. `LIKE '%'`는 7행 중 몇 행인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_like_oracle.sql -->
```text
== [Q1] _ 는 정확히 한 글자: 두 번째 글자가 A 인 이름

ENAME
JAMES
MARTIN
WARD

3 rows selected.

== [Q2] % 는 0글자 이상: S 로 끝나는 이름

ENAME
ADAMS
JAMES
JONES

3 rows selected.

== [Q3] 'A_B' 패턴: _ 가 와일드카드라 A_B, AXB 둘 다 일치 (AB 는 가운데 글자가 없어 불일치)

ID|TXT
1|A_B
2|AXB

2 rows selected.

== [Q4] ESCAPE 로 _ 를 문자 그대로: A_B 만

ID|TXT
1|A_B

1 row selected.

== [Q5] % 문자 자체를 찾기: 100% 만

ID|TXT
4|100%

1 row selected.

== [Q6] 대소문자: Oracle 기본 비교는 대소문자를 구분 -> 'ab' 는 'A%' 에 불일치

ID|TXT
1|A_B
2|AXB
3|AB

3 rows selected.

== [Q7] NULL 은 LIKE '%' 에도 일치하지 않는다

LIKE_ALL|TOTAL
6|7

1 row selected.

(참고: COUNT(*) 와 스칼라 서브쿼리를 한 SELECT 에 섞으면 Oracle 은 오류(not a single-group group function), SQL Server 는 허용)
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_like_sqlserver.sql -->
```text
== [Q1] _A%
ename
-----
JAMES
MARTIN
WARD

(3 rows affected)
== [Q2] %S
ename
-----
ADAMS
JAMES
JONES

(3 rows affected)
== [Q3] A_B 패턴
id|txt
--|---
1|A_B
2|AXB

(2 rows affected)
== [Q4] ESCAPE
id|txt
--|---
1|A_B

(1 rows affected)
== [Q5] % 문자 자체
id|txt
--|---
4|100%

(1 rows affected)
== [Q6] 대소문자: 기본 데이터 정렬 CI(대소문자 구분 안 함) -> ab 도 A% 에 일치
id|txt
--|---
1|A_B
2|AXB
3|AB
6|ab

(4 rows affected)
== [Q7] NULL 과 LIKE %
like_all|total
--------|-----
6|7

(1 rows affected)
== [Q8] SQL Server 전용: [ ] 문자 집합. 대괄호로 _ 를 감싸도 문자 그대로
id|txt
--|---
1|A_B

(1 rows affected)
id|txt
--|---
4|100%
5|1000

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 `_A%`: 두 번째 글자가 A인 WARD·MARTIN·JAMES. Q2 `%S`: ADAMS·JAMES·JONES.
* Q3: `_`는 아무 한 글자와 일치하므로 `A_B`와 `AXB`. `AB`는 가운데 글자가 없어 불일치.
* Q4·Q5: ESCAPE 문자 뒤의 `_`·`%`는 문자 그대로 비교한다.
* Q6: Oracle 3행, SQL Server 4행(소문자 `ab` 포함). **결과가 다르다.**
* Q7: NULL 1행만 빠진다 → 6/7.
* Q8(SQL Server 전용): `[_]`는 이스케이프와 같은 효과다. `[0-9]%`는 숫자로 시작하는 `100%`·`1000`.

## F. 변형 문제
1. 세 글자짜리 이름(`'___'`)은 누구인가?
2. Oracle에서 대소문자 구분 없이 'a'로 시작하는 txt를 찾으려면? (`UPPER(txt) LIKE 'A%'`)
3. ESCAPE 문자 자체(`\`)가 데이터에 있다면 어떻게 찾는가? (`'\\'`)

G: [../exercises/ex03_like.md](../exercises/ex03_like.md)
