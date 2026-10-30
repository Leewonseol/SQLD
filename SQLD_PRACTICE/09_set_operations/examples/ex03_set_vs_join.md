# ex03 집합 연산 vs EXISTS · JOIN

> 근거: PDF추출본 E-27("두 개 이상의 테이블에서 JOIN을 사용하지 않고, 연관된 데이터를 조회"), E-19(FULL OUTER를 UNION으로) · 데이터: S_A·S_B · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* INTERSECT ≈ `DISTINCT … WHERE EXISTS (… b.v = a.v)`, MINUS ≈ `DISTINCT … WHERE NOT EXISTS (…)`.
* 두 방식은 **NULL 행**에서 다르다. 집합 연산은 NULL = NULL을 같다고 보고, EXISTS의 `b.v = a.v`는 UNKNOWN으로 본다.
* FULL OUTER JOIN 흉내: `LEFT JOIN` + `UNION ALL` + (오른쪽에만 있는 행). UNION으로 합치면 같은 행이 원래 두 번 있을 때 하나로 줄어든다(04단원 ex10 Q7).

## B. 입력 데이터
S_A·S_B

## C. 실행 SQL
[Oracle](ex03_set_vs_join_oracle.sql) · [SQL Server](ex03_set_vs_join_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 INTERSECT와 EXISTS의 결과 행은?
2. Q2 MINUS와 NOT EXISTS의 결과 행은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_set_vs_join_oracle.sql -->
```text
== [Q1] INTERSECT ≈ EXISTS (단, 중복 제거와 NULL 처리가 다르다)

V
2
(null)

2 rows selected.

V
2

1 row selected.

== [Q2] MINUS ≈ NOT EXISTS (NULL 행에서 결과가 갈린다)

V
1

1 row selected.

V
1
(null)

2 rows selected.

== [Q3] UNION ALL 로 FULL OUTER JOIN 흉내 (04단원 ex10 의 UNION 방식과 비교)

A_V|B_V
1|(null)
2|2
2|2
(null)|3
(null)|(null)
(null)|(null)

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_set_vs_join_sqlserver.sql -->
```text
== [Q1] INTERSECT ≈ EXISTS (단, 중복 제거와 NULL 처리가 다르다)
v
-
NULL
2

(2 rows affected)
v
-
2

(1 rows affected)
== [Q2] EXCEPT ≈ NOT EXISTS (NULL 행에서 결과가 갈린다)
v
-
1

(1 rows affected)
v
-
NULL
1

(2 rows affected)
== [Q3] UNION ALL 로 FULL OUTER JOIN 흉내 (04단원 ex10 의 UNION 방식과 비교)
a_v|b_v
---|---
NULL|NULL
NULL|NULL
NULL|3
1|NULL
2|2
2|2

(6 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: INTERSECT {2, NULL}, EXISTS {2}. NULL은 `=`로 짝지어지지 않는다.
* Q2: MINUS {1}, NOT EXISTS {1, NULL}. NULL은 짝이 '없는' 것으로 판정된다.
* Q3: 6행. S_A의 2가 두 개라 (2,2)가 두 번, NULL이 양쪽에 있지만 `=`로 짝지어지지 않아 (NULL, NULL) 두 행이 따로 나온다(왼쪽 NULL 1행 + 오른쪽 NULL 1행).

## F. 변형 문제
1. NULL까지 같다고 보는 EXISTS를 작성하라(`b.v = a.v OR (b.v IS NULL AND a.v IS NULL)`).
2. 04단원 BOOK_LIST·PUBLISHER의 FULL OUTER JOIN을 UNION ALL 방식으로 다시 써라.

G: [../exercises/ex03_set_vs_join.md](../exercises/ex03_set_vs_join.md)
