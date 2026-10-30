# ex01 비교·논리·부정 연산자와 우선순위

> 근거: PDF추출본 E-06(연산자 종류 표, 연산자 우선순위 1 괄호 → 2 NOT → 3 비교·SQL 연산자 → 4 AND → 5 OR) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **비교 연산자** `= > >= < <=` / **SQL 연산자** `BETWEEN a AND b`, `IN (list)`, `LIKE`, `IS NULL` / **논리 연산자** `AND OR NOT`
* **부정 연산자**: `!=`, `^=`, `<>`(ISO 표준), `NOT 컬럼 =`, `NOT 컬럼 >`, `NOT BETWEEN`, `NOT IN`, `IS NOT NULL`
* **우선순위**: 괄호가 가장 먼저이고, NOT → 비교 → AND → OR 순이다. `A OR B AND C`는 `A OR (B AND C)`다.
* **언제**: 조건이 세 개 이상 섞일 때. 괄호를 생략하면 의도와 다른 행이 나오지만 **오류는 나지 않는다.**

## B. 입력 데이터
EMP 14행. SALESMAN 4명(1600·1250·1250·1500), MANAGER 3명(2975·2850·2450).

## C. 실행 SQL
[Oracle](ex01_operators_precedence_oracle.sql) · [SQL Server](ex01_operators_precedence_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(괄호 없음)과 Q2(괄호 있음)의 행 수는?
2. Q3 `NOT deptno = 10 AND sal > 2000`은 몇 행인가?
3. Q5의 세 조건을 모두 만족하는 사원은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_operators_precedence_oracle.sql -->
```text
== [Q1] 괄호 없음: AND 가 OR 보다 먼저 -> job='SALESMAN' OR (job='MANAGER' AND sal > 2800)

ENAME|JOB|SAL
ALLEN|SALESMAN|1600
WARD|SALESMAN|1250
JONES|MANAGER|2975
MARTIN|SALESMAN|1250
BLAKE|MANAGER|2850
TURNER|SALESMAN|1500

6 rows selected.

== [Q2] 괄호로 OR 를 먼저

ENAME|JOB|SAL
JONES|MANAGER|2975
BLAKE|MANAGER|2850

2 rows selected.

== [Q3] NOT 은 비교 연산자보다 늦게, AND 보다 먼저: NOT deptno = 10 AND sal > 2000 = (NOT (deptno = 10)) AND sal > 2000

ENAME|DEPTNO|SAL
JONES|20|2975
BLAKE|30|2850
SCOTT|20|3000
FORD|20|3000

4 rows selected.

== [Q4] 부정 비교 연산자 != , ^= , <> , NOT 컬럼 = (모두 같은 결과 건수)

NE1|NE2|NE3|NE4|NOT_GT
8|8|8|8|8

1 row selected.

== [Q5] SQL 연산자의 부정: NOT BETWEEN, NOT IN, NOT LIKE, IS NOT NULL

ENAME|SAL|COMM
SMITH|800|(null)

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_operators_precedence_sqlserver.sql -->
```text
== [Q1] 괄호 없음
ename|job|sal
-----|---|---
ALLEN|SALESMAN|1600.00
WARD|SALESMAN|1250.00
JONES|MANAGER|2975.00
MARTIN|SALESMAN|1250.00
BLAKE|MANAGER|2850.00
TURNER|SALESMAN|1500.00

(6 rows affected)
== [Q2] 괄호로 OR 를 먼저
ename|job|sal
-----|---|---
JONES|MANAGER|2975.00
BLAKE|MANAGER|2850.00

(2 rows affected)
== [Q3] NOT deptno = 10 AND sal > 2000
ename|deptno|sal
-----|------|---
JONES|20|2975.00
BLAKE|30|2850.00
SCOTT|20|3000.00
FORD|20|3000.00

(4 rows affected)
== [Q4] 부정 비교 연산자 != , <> , NOT 컬럼 = (^= 는 SQL Server 에 없다)
ne1|ne3|ne4|not_gt
---|---|---|------
8|8|8|8

(1 rows affected)
== [Q5] SQL 연산자의 부정
ename|sal|comm
-----|---|----
SMITH|800.00|NULL

(1 rows affected)
== [Q6] ^= 연산자 -> 구문 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near '^='.
```
<!-- /RESULT -->

**이유**
* Q1 6행: AND가 먼저 묶인다. SALESMAN 4명 전원 + (MANAGER이면서 2800 초과) JONES·BLAKE.
* Q2 2행: OR를 먼저 묶으면 "SALESMAN 또는 MANAGER" 중 2800 초과인 사람만 남는다. SALESMAN은 모두 2800 이하다.
* Q3 4행: `(NOT deptno = 10) AND sal > 2000` → 20·30번 부서에서 2000 초과인 JONES·BLAKE·SCOTT·FORD. 10번 KING·CLARK은 빠진다.
* Q4: 30번 부서가 아닌 사원은 8명이다. 모든 부정 표기가 같은 결과를 낸다. `NOT sal > 2000`도 8명이다(2000 이하 8명). SQL Server는 `^=`가 없다(Q6, Msg 102).
* Q5: 급여 1000~3000 밖 + 30번이 아님 + K로 시작하지 않음 → SMITH(800)만 남는다. KING(5000)은 NOT LIKE 'K%'에서 빠진다.

## F. 변형 문제
1. Q1에서 `job = 'MANAGER' AND sal > 2800 OR job = 'SALESMAN'`으로 순서만 바꾸면 결과가 달라지는가?
2. `NOT (deptno = 10 AND sal > 2000)`은 몇 행인가? (드모르간: `deptno <> 10 OR sal <= 2000`)
3. comm이 NULL인 사원이 있을 때 `NOT comm > 100`의 결과에 NULL 행이 포함되는가? (ex05)

G: [../exercises/ex01_operators_precedence.md](../exercises/ex01_operators_precedence.md)
