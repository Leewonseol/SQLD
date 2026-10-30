# ex01 단일행 서브쿼리

> 근거: PDF추출본 E-22 ①(단일행 비교 연산자 = <> > >= < <=, 평균 급여 예, 강감찬 소속 팀 예) · 데이터: EMP, PLAYER(04단원) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을**: 결과가 **최대 1행 1열**인 서브쿼리를 단일행 연산자로 비교한다.
* **실패 조건**: 2행 이상이면 실행 오류(ORA-01427 / Msg 512)다. 데이터에 따라 성공했다가 실패할 수 있으므로 "항상 1행"이 보장되는지 확인한다(PK 조건, 집계함수 등).
* 0행이면 결과는 NULL이다. 비교 결과는 UNKNOWN이고 0행이 나온다(오류 아님).

## B. 입력 데이터
EMP, PLAYER(04단원) (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex01_single_row_subquery_oracle.sql) · [SQL Server](ex01_single_row_subquery_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 평균(2073.21)보다 많이 받는 사원 수는?
2. Q3은 왜 실패하는가? 10번 부서가 1명이었다면?
3. Q4의 결과는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_single_row_subquery_oracle.sql -->
```text
== [Q1] PDF 예: 평균 급여보다 많이 받는 사원

EMPNO|ENAME|SAL
7839|KING|5000
7788|SCOTT|3000
7902|FORD|3000
7566|JONES|2975
7698|BLAKE|2850
7782|CLARK|2450

6 rows selected.

== [Q2] PDF 예 구조: 강감찬과 같은 팀 선수 (04단원 PLAYER)

PLAYER_NAME|POSITION|BACK_NO
강감찬|GK|1
을지문|DF|4

2 rows selected.

== [Q3] 서브쿼리가 2행 이상을 돌려주면 단일행 연산자에서 오류
SELECT ename FROM emp WHERE sal = (SELECT sal FROM emp WHERE deptno = 10)
                                   *
ERROR at line 1:
ORA-01427: single-row subquery returns more than one row

== [Q4] 서브쿼리가 0행이면 결과는 NULL -> 비교가 UNKNOWN -> 0행 (오류 아님)

CNT
0

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_single_row_subquery_sqlserver.sql -->
```text
== [Q1] 평균보다 많이 받는 사원
empno|ename|sal
-----|-----|---
7839|KING|5000.00
7788|SCOTT|3000.00
7902|FORD|3000.00
7566|JONES|2975.00
7698|BLAKE|2850.00
7782|CLARK|2450.00

(6 rows affected)
== [Q2] 강감찬과 같은 팀
player_name|position|back_no
-----------|--------|-------
강감찬|GK|1
을지문|DF|4

(2 rows affected)
== [Q3] 서브쿼리 2행 이상 -> 오류
Msg 512, Level 16, State 1, Server a70f428a7f8a, Line 2
Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
== [Q4] 서브쿼리 0행
cnt
---
0

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 6명(KING·FORD·SCOTT·JONES·BLAKE·CLARK).
* Q2 강감찬의 팀 K01 → 강감찬·을지문.
* Q3: 10번 부서 급여가 3개라 ORA-01427 / Msg 512. 1명이었다면 성공한다. 데이터가 바뀌면 깨지는 쿼리다.
* Q4: 'NOBODY'가 없어 서브쿼리 결과는 NULL이다. `sal > NULL` → 0행.

## F. 변형 문제
1. Q3을 오류 없이 "10번 부서 누군가와 급여가 같은 사원"으로 고쳐라(IN).
2. "가장 늦게 입사한 사원과 같은 부서의 사원"을 구하라.

G: [../exercises/ex01_single_row_subquery.md](../exercises/ex01_single_row_subquery.md)
