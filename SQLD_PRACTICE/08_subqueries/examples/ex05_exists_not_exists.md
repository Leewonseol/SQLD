# ex05 EXISTS · NOT EXISTS 와 NOT IN 의 NULL 함정

> 근거: PDF추출본 E-26("NOT EXISTS는 서브쿼리 테이블의 결과물을 제외한 나머지 […] (차집합)", "EXISTS는 […] 겹치는 데이터만"), 요구목록 §9(EXISTS와 NOT EXISTS) · 데이터: EMP, DEPT · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `EXISTS (서브쿼리)`: 서브쿼리가 1행이라도 내면 참이다. SELECT 목록의 값은 보지 않는다(`SELECT 1`, `SELECT NULL` 모두 같다). 보통 연관 조건과 함께 쓴다.
* `NOT EXISTS`: 짝이 하나도 없으면 참이다. 안티 조인(차집합)이다.
* **NOT IN과 차이**: 서브쿼리 결과에 NULL이 하나라도 있으면 `NOT IN`은 0행이다. `NOT EXISTS`는 NULL과 상관없다.

## B. 입력 데이터
EMP, DEPT (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex05_exists_not_exists_oracle.sql) · [SQL Server](ex05_exists_not_exists_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 사원이 없는 부서는?
2. Q4 `empno NOT IN (SELECT mgr FROM emp)`의 결과는? Q5 NOT EXISTS는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_exists_not_exists_oracle.sql -->
```text
== [Q1] EXISTS: 사원이 한 명이라도 있는 부서 (서브쿼리가 1행이라도 내면 참, SELECT 목록 내용은 무관)

DEPTNO|DNAME
10|ACCOUNTING
20|RESEARCH
30|SALES

3 rows selected.

== [Q2] NOT EXISTS: 사원이 없는 부서 (PDF: 차집합)

DEPTNO|DNAME
40|OPERATIONS

1 row selected.

== [Q3] EXISTS 안의 SELECT NULL 이나 SELECT 1/0 도 평가하지 않는다

CNT
3

1 row selected.

== [Q4] 부하가 없는 사원: NOT IN (SELECT mgr ...) -> mgr 에 NULL(KING) 이 있어 0행

NOT_IN_CNT
0

1 row selected.

== [Q5] NOT EXISTS 는 NULL 에 영향받지 않는다 -> 8행

ENAME
SMITH
ALLEN
WARD
MARTIN
TURNER
ADAMS
JAMES
MILLER

8 rows selected.

== [Q6] NOT IN 을 쓰려면 서브쿼리에서 NULL 을 제거

NOT_IN_FIXED
8

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_exists_not_exists_sqlserver.sql -->
```text
== [Q1] EXISTS: 사원이 한 명이라도 있는 부서 (서브쿼리가 1행이라도 내면 참, SELECT 목록 내용은 무관)
deptno|dname
------|-----
10|ACCOUNTING
20|RESEARCH
30|SALES

(3 rows affected)
== [Q2] NOT EXISTS: 사원이 없는 부서 (PDF: 차집합)
deptno|dname
------|-----
40|OPERATIONS

(1 rows affected)
== [Q3] EXISTS 안의 SELECT NULL 이나 SELECT 1/0 도 평가하지 않는다
cnt
---
3

(1 rows affected)
== [Q4] 부하가 없는 사원: NOT IN (SELECT mgr ...) -> mgr 에 NULL(KING) 이 있어 0행
not_in_cnt
----------
0

(1 rows affected)
== [Q5] NOT EXISTS 는 NULL 에 영향받지 않는다 -> 8행
ename
-----
SMITH
ALLEN
WARD
MARTIN
TURNER
ADAMS
JAMES
MILLER

(8 rows affected)
== [Q6] NOT IN 을 쓰려면 서브쿼리에서 NULL 을 제거
not_in_fixed
------------
8

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 10·20·30, Q2 40. Q3 `SELECT NULL`이어도 행이 있으면 참 → 3.
* Q4: mgr 목록에 KING의 NULL이 있어 0행이다. Q5 NOT EXISTS는 부하가 없는 8명. Q6: 서브쿼리에서 NULL을 걸러 내면 NOT IN도 8명이다.

## F. 변형 문제
1. 주문한 적이 없는 고객(04단원 CUST·ORDERS)을 NOT EXISTS, LEFT JOIN … IS NULL, NOT IN 세 방법으로 구하라. ORDERS.cust_id가 NOT NULL이므로 NOT IN도 안전한 이유를 설명하라.
2. 15단원 Q5(고객ID만 비교 vs 고객ID+컨텐츠ID 비교)를 풀어 보라.

G: [../exercises/ex05_exists_not_exists.md](../exercises/ex05_exists_not_exists.md)
