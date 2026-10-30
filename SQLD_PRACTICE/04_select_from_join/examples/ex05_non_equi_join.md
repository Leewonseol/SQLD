# ex05 NON EQUI JOIN

> 근거: PDF추출본 E-10 · 데이터: **PDF 원문 값**(PDF_EMP_SG 6행, PDF_SALGRADE 5행. MARTIN 1280, KING 8000, 1등급 800~1200은 SCOTT 표준값과 다른 PDF 고유 값) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을 하는가**: `=`가 아닌 연산자(BETWEEN, >, >=, <, <=)로 행을 짝짓는다. 대표 예는 값이 범위에 속하는지 보는 조인이다.
* **언제 쓰는가**: 급여 등급, 할인 구간, 유효 기간 테이블처럼 "범위 테이블"과 결합할 때.
* **차이**: EQUI JOIN은 키 값이 같은 행끼리 짝짓는다. NON EQUI JOIN은 구간이 겹치면 한 행이 여러 등급과 짝지어질 수 있고, 구간 사이 틈이 있으면 어느 등급과도 짝지어지지 않을 수 있다. 결과 행 수는 **구간 설계**에 달려 있다. PDF도 "설계상의 이유로 수행이 불가능함"이 있다고 했다.

## B. 입력 데이터 (PDF)
| PDF_EMP_SG(ename PK, sal) | PDF_SALGRADE(grade PK, losal, hisal) |
|---|---|
| SMITH 800, ALLEN 1600, WARD 1250, JONES 2975, MARTIN 1280, KING 8000 | 1: 800–1200, 2: 1201–1400, 3: 1401–2000, 4: 2001–3000, 5: 3001–9999 |

## C. 실행 SQL
[Oracle](ex05_non_equi_join_oracle.sql) · [SQL Server](ex05_non_equi_join_sqlserver.sql)

## D. 결과 예측 문제
1. 각 사원의 등급을 손으로 구하라. 결과 행 수는?
2. Q3: 1200, 1200.5, 1201은 각각 몇 등급인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_non_equi_join_oracle.sql -->
```text
== [Q1] PDF 쿼리 그대로: BETWEEN 으로 급여 등급 찾기

사원명|급여|급여등급
SMITH|800|1
WARD|1250|2
MARTIN|1280|2
ALLEN|1600|3
JONES|2975|4
KING|8000|5

6 rows selected.

== [Q2] 같은 의미를 >= / <= 로 (ANSI JOIN ... ON 에 비등가 조건)

ENAME|SAL|GRADE
SMITH|800|1
WARD|1250|2
MARTIN|1280|2
ALLEN|1600|3
JONES|2975|4
KING|8000|5

6 rows selected.

== [Q3] 경계값: 1200 은 1등급, 1200.5 는 어느 구간에도 없다(등급 사이 틈) -> INNER 결과에서 빠짐

SAL|GRADE
1200|1
1200.5|(null)
1201|2

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_non_equi_join_sqlserver.sql -->
```text
== [Q1] PDF 쿼리 그대로
사원명|급여|급여등급
---|--|----
SMITH|800|1
WARD|1250|2
MARTIN|1280|2
ALLEN|1600|3
JONES|2975|4
KING|8000|5

(6 rows affected)
== [Q2] JOIN ... ON 비등가 조건
ename|sal|grade
-----|---|-----
SMITH|800|1
WARD|1250|2
MARTIN|1280|2
ALLEN|1600|3
JONES|2975|4
KING|8000|5

(6 rows affected)
== [Q3] 경계값과 등급 사이 틈
sal|grade
---|-----
1200.0|1
1200.5|NULL
1201.0|2

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* 6명 모두 정확히 한 구간에 속한다 → 6행. PDF 결과표(SMITH 1, ALLEN 3, WARD 2, JONES 4, MARTIN 2, KING 5)와 **일치**한다. PDF 표는 입력 순서로 나열했고, 이 실습은 ORDER BY sal로 정렬했다.
* BETWEEN은 양 끝을 포함한다(`losal <= sal AND sal <= hisal`). 1200은 1등급이다.
* 1200.5는 1등급(~1200)과 2등급(1201~) **사이 틈**에 있다. LEFT JOIN이라 NULL로 남고, INNER였다면 빠졌을 것이다. 정수 급여만 있다고 가정한 설계의 약점이다.

## F. 변형 문제
1. 2등급의 losal을 1200으로 바꾸면 sal=1200인 사원은 몇 행으로 나오는가? (구간 겹침 → 2행)
2. KING의 급여를 10000으로 바꾸면 INNER 결과는 몇 행인가?
3. BETWEEN을 `e.sal > s.losal AND e.sal <= s.hisal`로 바꾸면 SMITH(800)는 어떻게 되는가?

G: [exercises/ex05_non_equi_join.md](../exercises/ex05_non_equi_join.md)
