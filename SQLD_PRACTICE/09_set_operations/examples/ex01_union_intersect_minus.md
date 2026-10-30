# ex01 UNION · UNION ALL · INTERSECT · MINUS(EXCEPT)

> 근거: PDF추출본 E-27("합집합, 교집합, 차집합의 연산", UNION/UNION ALL/INTERSECT/EXCEPT 도식) · 데이터: EMP, S_A{1,2,2,NULL}·S_B{2,3,NULL}·S_C{2}(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 연산 | 결과 | 중복 |
|---|---|---|
| UNION | A ∪ B | 제거(정렬이 일어날 수 있지만 순서는 보장되지 않음) |
| UNION ALL | A + B 그대로 | 유지 |
| INTERSECT | A ∩ B | 제거 |
| MINUS / EXCEPT | A − B | 제거 |
* 집합 연산은 **NULL을 같은 값으로** 본다. JOIN과 WHERE의 `=`에서는 NULL이 어떤 값과도 같지 않다.
* MINUS/EXCEPT는 순서가 바뀌면 결과가 바뀐다.

## B. 입력 데이터
EMP, S_A{1,2,2,NULL}·S_B{2,3,NULL}·S_C{2}(학습용 가상 데이터)

## C. 실행 SQL
[Oracle](ex01_union_intersect_minus_oracle.sql) · [SQL Server](ex01_union_intersect_minus_sqlserver.sql)

## D. 결과 예측 문제
1. Q1·Q2의 행 수는?
2. Q4 A−B와 B−A는?
3. Q5 S_A ∩ S_B에 NULL이 포함되는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_union_intersect_minus_oracle.sql -->
```text
== [Q1] UNION: 합집합, 중복 제거

JOB
ANALYST
CLERK
MANAGER
PRESIDENT

4 rows selected.

== [Q2] UNION ALL: 중복 유지 (3 + 5 = 8행)

JOB
ANALYST
ANALYST
CLERK
CLERK
CLERK
MANAGER
MANAGER
PRESIDENT

8 rows selected.

== [Q3] INTERSECT: 교집합

JOB
CLERK
MANAGER

2 rows selected.

== [Q4] MINUS: 차집합 A - B, B - A (순서가 결과를 바꾼다)

JOB
PRESIDENT

1 row selected.

JOB
ANALYST

1 row selected.

== [Q5] 집합 연산은 NULL 끼리를 같은 값으로 본다 (JOIN·= 비교와 다름)

V
2
(null)

2 rows selected.

V
1
2
3
(null)

4 rows selected.

== [Q6] (21c 이상 전용) EXCEPT 와 INTERSECT ALL / MINUS ALL. 19c 에서는 구문 오류 -- 기준 버전(19c) 미지원

V
1

1 row selected.

V
2

1 row selected.

V
1
2
(null)

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_union_intersect_minus_sqlserver.sql -->
```text
== [Q1] UNION
job
---
ANALYST
CLERK
MANAGER
PRESIDENT

(4 rows affected)
== [Q2] UNION ALL
job
---
ANALYST
ANALYST
CLERK
CLERK
CLERK
MANAGER
MANAGER
PRESIDENT

(8 rows affected)
== [Q3] INTERSECT
job
---
CLERK
MANAGER

(2 rows affected)
== [Q4] EXCEPT: A - B, B - A
job
---
PRESIDENT

(1 rows affected)
job
---
ANALYST

(1 rows affected)
== [Q5] NULL 끼리 같은 값
v
-
NULL
2

(2 rows affected)
v
-
NULL
1
2
3

(4 rows affected)
== [Q6] MINUS: 오류가 나지 않는다! MINUS 를 s_a 의 별칭으로 해석해 SELECT 두 개가 따로 실행된다 (조용한 함정)
v
-
1
2
2
NULL

(4 rows affected)
v
-
2
3
NULL

(3 rows affected)
== [Q7] INTERSECT ALL -> 오류
Msg 324, Level 15, State 1, Server a70f428a7f8a, Line 2
The 'ALL' version of the INTERSECT operator is not supported.
```
<!-- /RESULT -->

**이유**
* Q1 4행, Q2 8행(10번 3 + 20번 5).
* Q3 {CLERK, MANAGER}, Q4 A−B {PRESIDENT}, B−A {ANALYST}.
* Q5: 교집합에 NULL이 포함된다(NULL끼리 같다고 본다). 합집합은 {1, 2, 3, NULL}이다. Oracle은 NULL을 마지막에, SQL Server는 처음에 정렬한다.
* Oracle Q6(21c 이상): EXCEPT {1}, `INTERSECT ALL` {2}(S_A의 2 두 개 중 S_C에 있는 1개만), `MINUS ALL` {1, 2, NULL}(2 하나만 빠진다).
* SQL Server Q6: `MINUS`가 오류가 아니라 **별칭**으로 해석되어 결과가 두 개 나온다. 시험에서 "SQL Server에서 MINUS는 오류"라고 외우면 틀릴 수 있다(문법적으로는 별개의 두 문장이 된다). Q7 INTERSECT ALL은 Msg 324.

## F. 변형 문제
1. `SELECT deptno FROM dept MINUS SELECT deptno FROM emp`의 결과는?
2. UNION ALL 결과에 DISTINCT를 붙인 것과 UNION은 같은가?

G: [../exercises/ex01_union_intersect_minus.md](../exercises/ex01_union_intersect_minus.md)
