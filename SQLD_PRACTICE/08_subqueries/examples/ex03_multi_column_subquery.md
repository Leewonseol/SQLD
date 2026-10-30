# ex03 다중컬럼 서브쿼리

> 근거: PDF추출본 E-22 ③("메인쿼리의 비교 컬럼이 2개 이상", "대소 비교 전달 불가", "SQL Server 지원 X", 부서별 최대 급여자 예) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `(a, b) IN (SELECT x, y …)`는 **쌍**으로 비교한다. 컬럼마다 따로 IN을 거는 것과 다르다(Q2).
* 쌍의 대소 비교 `(a, b) > (…)`는 지원하지 않는다(ORA-01796).
* SQL Server는 다중컬럼 IN을 지원하지 않는다 → EXISTS(연관 조건)나 인라인 뷰 JOIN으로 바꾼다.

## B. 입력 데이터
EMP (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex03_multi_column_subquery_oracle.sql) · [SQL Server](ex03_multi_column_subquery_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 부서별 최대 급여자는 몇 명인가(동점 포함)?
2. Q2 두 쿼리의 행 수는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_multi_column_subquery_oracle.sql -->
```text
== [Q1] PDF 예: 부서별 최대 급여자

EMPNO|ENAME|SAL|DEPTNO
7839|KING|5000|10
7788|SCOTT|3000|20
7902|FORD|3000|20
7698|BLAKE|2850|30

4 rows selected.

== [Q2] 쌍 비교 vs 컬럼별 비교: (10,CLERK)·(20,ANALYST) 쌍과 같은 사원 / 부서 IN AND 직무 IN

ENAME|DEPTNO|JOB
SCOTT|20|ANALYST
FORD|20|ANALYST
MILLER|10|CLERK

3 rows selected.

ENAME|DEPTNO|JOB
SMITH|20|CLERK
SCOTT|20|ANALYST
ADAMS|20|CLERK
FORD|20|ANALYST
MILLER|10|CLERK

5 rows selected.

== [Q3] 다중 컬럼 대소 비교 -> 오류 (PDF "두 값을 동시에 묶어서 대소비교할 수 없으니")
SELECT ename FROM emp WHERE (deptno, sal) > (SELECT 10, 1000 FROM dual)
                                          *
ERROR at line 1:
ORA-01796: this operator cannot be used with lists
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_multi_column_subquery_sqlserver.sql -->
```text
== [Q0] 다중 컬럼 IN -> 오류
Msg 4145, Level 15, State 1, Server a70f428a7f8a, Line 2
An expression of non-boolean type specified in a context where a condition is expected, near ','.
== [Q1] EXISTS 로 대체
empno|ename|sal|deptno
-----|-----|---|------
7839|KING|5000.00|10
7788|SCOTT|3000.00|20
7902|FORD|3000.00|20
7698|BLAKE|2850.00|30

(4 rows affected)
== [Q1b] 인라인 뷰 JOIN 으로 대체
empno|ename|sal|deptno
-----|-----|---|------
7839|KING|5000.00|10
7788|SCOTT|3000.00|20
7902|FORD|3000.00|20
7698|BLAKE|2850.00|30

(4 rows affected)
== [Q2] 쌍 비교(EXISTS) vs 컬럼별 비교
ename|deptno|job
-----|------|---
SCOTT|20|ANALYST
FORD|20|ANALYST
MILLER|10|CLERK

(3 rows affected)
ename|deptno|job
-----|------|---
SMITH|20|CLERK
SCOTT|20|ANALYST
ADAMS|20|CLERK
FORD|20|ANALYST
MILLER|10|CLERK

(5 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 4명: 10번 KING, 20번 SCOTT·FORD(동점), 30번 BLAKE.
* Q2: 쌍 비교는 (10,CLERK)·(20,ANALYST)인 3명이다. 컬럼별 비교는 "부서 ∈ {10,20} AND 직무 ∈ {CLERK, ANALYST}"라서 (20, CLERK)인 SMITH·ADAMS까지 5명이다.
* Q3 ORA-01796. SQL Server Q0 Msg 4145, Q1(EXISTS)·Q1b(JOIN)가 Oracle Q1과 같은 4명이다.

## F. 변형 문제
1. 직무별 최저 급여자를 다중컬럼 IN(Oracle)과 JOIN(SQL Server)으로 구하라.
2. 부서별 최대 급여가 같은 사원이 둘이면 결과는 몇 행인가?

G: [../exercises/ex03_multi_column_subquery.md](../exercises/ex03_multi_column_subquery.md)
