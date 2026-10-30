# ex02 다중행 서브쿼리 IN·ANY·ALL

> 근거: PDF추출본 E-22 ②(IN·ANY·ALL·EXISTS 표, ">ANY(10,200): 최소값(10)보다 큰 행들" 등) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 연산 | 뜻 | 같은 표현 |
|---|---|---|
| `> ANY (집합)` | 하나라도보다 크면 | `> MIN(집합)` |
| `< ANY` | 하나라도보다 작으면 | `< MAX` |
| `> ALL` | 모두보다 크면 | `> MAX` |
| `< ALL` | 모두보다 작으면 | `< MIN` |
| `= ANY` | 하나라도 같으면 | `IN` |
| `<> ALL` | 모두와 다르면 | `NOT IN` |
* PDF 표의 "최소값 반환" 등은 "어느 값과 비교하는 셈인가"를 뜻한다. 연산자가 값을 반환하는 것은 아니다.
* **경계조건**: 빈 집합이면 ALL은 참(모든 행), ANY는 거짓(0행)이다. 집합에 NULL이 있으면 `<> ALL`/`NOT IN`은 0행이다(Q6).

## B. 입력 데이터
EMP (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex02_multi_row_any_all_oracle.sql) · [SQL Server](ex02_multi_row_any_all_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 `> ANY`(10번 부서 1300·2450·5000)를 통과하는 사원 수는?
2. Q5 빈 집합에 ALL과 ANY를 쓰면?
3. Q6 `empno <> ALL (SELECT mgr FROM emp)`는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_multi_row_any_all_oracle.sql -->
```text
== [Q1] IN: 10번 부서 사원들의 직무와 같은 직무

ENAME|JOB
ADAMS|CLERK
JAMES|CLERK
MILLER|CLERK
SMITH|CLERK
BLAKE|MANAGER
CLARK|MANAGER
JONES|MANAGER
KING|PRESIDENT

8 rows selected.

== [Q2] PDF 예: > ANY = 최솟값보다 크면 참 (10번 부서 최소 1300)

ENAME|SAL
TURNER|1500
ALLEN|1600
CLARK|2450
BLAKE|2850
JONES|2975
FORD|3000
SCOTT|3000
KING|5000

8 rows selected.

== [Q3] > ALL = 최댓값보다 커야 참 (30번 부서 최대 2850)

ENAME|SAL
JONES|2975
FORD|3000
SCOTT|3000
KING|5000

4 rows selected.

== [Q4] < ANY = 최댓값보다 작으면 참, < ALL = 최솟값보다 작아야 참 (리터럴 목록: Oracle 허용)

LT_ANY|LT_ALL
11|2

1 row selected.

== [Q5] 빈 집합: ALL 은 항상 참(14행), ANY 는 항상 거짓(0행)

ALL_EMPTY|ANY_EMPTY
14|0

1 row selected.

== [Q6] = ANY 는 IN 과 같고, <> ALL 은 NOT IN 과 같다 (NULL 함정도 같다)

EQ_ANY|NE_ALL
6|0

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_multi_row_any_all_sqlserver.sql -->
```text
== [Q1] IN
ename|job
-----|---
ADAMS|CLERK
JAMES|CLERK
MILLER|CLERK
SMITH|CLERK
BLAKE|MANAGER
CLARK|MANAGER
JONES|MANAGER
KING|PRESIDENT

(8 rows affected)
== [Q2] > ANY
ename|sal
-----|---
TURNER|1500.00
ALLEN|1600.00
CLARK|2450.00
BLAKE|2850.00
JONES|2975.00
FORD|3000.00
SCOTT|3000.00
KING|5000.00

(8 rows affected)
== [Q3] > ALL
ename|sal
-----|---
JONES|2975.00
FORD|3000.00
SCOTT|3000.00
KING|5000.00

(4 rows affected)
== [Q4] < ANY / < ALL (값 목록은 VALUES 서브쿼리로)
lt_any|lt_all
------|------
11|2

(1 rows affected)
== [Q5] 빈 집합
all_empty|any_empty
---------|---------
14|0

(1 rows affected)
== [Q6] = ANY / <> ALL
eq_any|ne_all
------|------
6|0

(1 rows affected)
== [Q7] ANY 에 리터럴 목록 -> 구문 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near '1000'.
```
<!-- /RESULT -->

**이유**
* Q1 직무 CLERK·MANAGER·PRESIDENT인 8명.
* Q2 1300 초과 8명. Q3 2850 초과 4명.
* Q4 `< ANY(1000,3000)` = 3000 미만 11명, `< ALL` = 1000 미만 2명(SMITH 800, JAMES 950).
* Q5 ALL 14, ANY 0.
* Q6 `= ANY` = 관리자인 사원 6명. `<> ALL`은 mgr 집합에 NULL(KING)이 있어 0행이다.
* SQL Server는 `ANY (1000, 3000)` 같은 값 목록이 구문 오류(Q7)라 VALUES 서브쿼리로 바꿨다.

## F. 변형 문제
1. `sal >= ALL (SELECT sal FROM emp)`의 결과는? 최고 급여자 쿼리와 비교하라.
2. 30번 부서의 **어떤** 사원보다도 급여가 적은(모두보다 적은) 사원을 구하라.

G: [../exercises/ex02_multi_row_any_all.md](../exercises/ex02_multi_row_any_all.md)
