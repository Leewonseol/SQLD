# ex05 NULL 과 3값 논리

> 근거: PDF추출본 E-06("NULL은 ''로 조회가 불가능, IS NULL / IS NOT NULL을 사용"), 요구목록 §7(NULL과 3값 논리) · 데이터: EMP, W_LIKE · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* NULL은 "값이 없음 / 알 수 없음"이다. 0이나 공백이 아니다.
* NULL과 비교(`=, <>, >, …`)하면 결과는 TRUE도 FALSE도 아닌 **UNKNOWN**이다. WHERE는 TRUE인 행만 통과시킨다.
* 3값 논리표

| A | B | A AND B | A OR B | NOT A |
|---|---|---|---|---|
| TRUE | UNKNOWN | UNKNOWN | TRUE | FALSE |
| FALSE | UNKNOWN | FALSE | UNKNOWN | TRUE |
| UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |

* **Oracle 고유**: 길이 0인 문자열 `''`을 NULL로 저장하고 비교한다. SQL Server에서 `''`은 NULL이 아닌 값이다.

## B. 입력 데이터
EMP의 comm: 300, 500, 1400, 0(TURNER), 나머지 10명 NULL.

## C. 실행 SQL
[Oracle](ex05_null_three_valued_oracle.sql) · [SQL Server](ex05_null_three_valued_sqlserver.sql)

## D. 결과 예측 문제
1. `comm = NULL`과 `comm IS NULL`의 건수는?
2. `comm > 0`과 `NOT (comm > 0)`의 건수 합은 14인가?
3. `'' IS NULL`은 두 DBMS에서 각각 참인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_null_three_valued_oracle.sql -->
```text
== [Q1] = NULL 은 항상 UNKNOWN -> 0행

EQ_NULL
0

1 row selected.

== [Q2] IS NULL / IS NOT NULL

IS_NULL|IS_NOT_NULL
10|4

1 row selected.

== [Q3] 부정 조건도 NULL 행을 돌려주지 않는다: comm > 0 (3) + NOT (comm > 0) (1) = 4 ≠ 14

GT0|NOT_GT0
3|1

1 row selected.

== [Q4] 진리표: UNKNOWN 과 AND/OR/NOT

A|B|A_AND_B|A_OR_B|NOT_A
TRUE|UNKNOWN|UNKNOWN|TRUE|FALSE
FALSE|UNKNOWN|FALSE|UNKNOWN|TRUE
UNKNOWN|UNKNOWN|UNKNOWN|UNKNOWN|UNKNOWN

3 rows selected.

== [Q5] Oracle 에서 빈 문자열 '' 은 NULL 이다 -> = '' 도 0행, '' IS NULL 은 참

EQ_EMPTY|EMPTY_STRING
0|EMPTY_IS_NULL

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_null_three_valued_sqlserver.sql -->
```text
== [Q1] = NULL (ANSI_NULLS ON 기본)
eq_null
-------
0

(1 rows affected)
== [Q2] IS NULL / IS NOT NULL
is_null|is_not_null
-------|-----------
10|4

(1 rows affected)
== [Q3] 부정 조건과 NULL
gt0|not_gt0
---|-------
3|1

(1 rows affected)
== [Q4] 진리표
a|b|a_and_b|a_or_b|not_a
-|-|-------|------|-----
TRUE|UNKNOWN|UNKNOWN|TRUE|FALSE
FALSE|UNKNOWN|FALSE|UNKNOWN|TRUE
UNKNOWN|UNKNOWN|UNKNOWN|UNKNOWN|UNKNOWN

(3 rows affected)
== [Q5] SQL Server 에서 빈 문자열은 NULL 이 아니다

(1 rows affected)
eq_empty|empty_string
--------|------------
1|EMPTY_IS_NOT_NULL

(1 rows affected)

(1 rows affected)
== [Q6] (참고·비권장) SET ANSI_NULLS OFF 이면 = NULL 이 참이 된다. 향후 버전에서 제거 예정 기능
eq_null_ansi_off
----------------
10

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 0행, Q2 10/4.
* Q3: `comm > 0`은 3(300·500·1400), `NOT(comm > 0)`은 1(TURNER의 0). 합은 4다. NULL 10행은 양쪽 모두에서 빠진다. "조건 + 부정 조건 = 전체"가 **성립하지 않는다.**
* Q4: CASE의 첫 WHEN이 TRUE도 아니고, 둘째 WHEN `NOT(...)`도 TRUE가 아니면 ELSE로 가서 UNKNOWN이 나온다. 논리표와 같다.
* Q5: Oracle은 `''`이 NULL이라 `= ''`이 0행이고 `'' IS NULL`이 참이다. SQL Server는 `''`을 넣은 행이 `= ''`로 조회되고, `'' IS NULL`은 거짓이다. **결과가 다르다.**
* Q6(SQL Server 전용, 비권장): `SET ANSI_NULLS OFF`이면 `comm = NULL`이 10행이다. 향후 제거 예정 기능이므로 쓰지 않는다.

## F. 변형 문제
1. `WHERE comm > 0 OR comm IS NULL`은 몇 행인가?
2. `WHERE NOT (comm IS NULL)`과 `WHERE comm IS NOT NULL`은 같은가?
3. Oracle에서 `INSERT INTO t VALUES ('')` 뒤 `COUNT(col)`은 증가하는가?

G: [../exercises/ex05_null_three_valued.md](../exercises/ex05_null_three_valued.md)
