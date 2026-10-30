# ex13 순수 관계 연산자 (SELECT·PROJECT·JOIN·DIVIDE)와 PRODUCT

> 근거: PDF추출본 E-13 · 데이터: 학습용 가상 데이터(ENROLL, REQ_COURSE) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 관계 연산 | 의미 | SQL 구현 (PDF E-13) |
|---|---|---|
| SELECT(σ) | 조건에 맞는 행 선택 | WHERE 절 |
| PROJECT(π) | 원하는 열 추출 | SELECT 절(관계는 집합이므로 엄밀히는 DISTINCT까지) |
| (NATURAL) JOIN | 공통 속성으로 결합 | 다양한 JOIN |
| DIVIDE(÷) | B의 모든 값과 관계가 있는 A의 값 | 전용 구문 없음. PDF: "현재 사용X" → NOT EXISTS 이중 부정이나 GROUP BY + HAVING COUNT로 구현 |
| (일반 집합) PRODUCT | 모든 조합 | CROSS JOIN (ex09) |

* **주의**: 관계 연산자 SELECT(행 선택)와 SQL의 SELECT 절(열 선택 = PROJECT)은 이름은 같지만 의미가 다르다. 시험에 자주 나온다.

## B. 입력 데이터 (학습용 가상 데이터)
ENROLL(student, course, PK=둘 다): 민수 DB·SQL·AI / 지영 DB / 하늘 SQL·DB · REQ_COURSE(course PK): DB, SQL

## C. 실행 SQL
[Oracle](ex13_relational_ops_oracle.sql) · [SQL Server](ex13_relational_ops_sqlserver.sql)

## D. 결과 예측 문제
1. ENROLL ÷ REQ_COURSE의 결과 학생은?
2. Q2 PROJECT에서 DISTINCT를 빼면 몇 행인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex13_relational_ops_oracle.sql -->
```text
== [Q1] SELECT(선택, 행 고르기) 연산 = WHERE 절

STUDENT|COURSE
민수|DB
지영|DB
하늘|DB

3 rows selected.

== [Q2] PROJECT(추출, 열 고르기) 연산 = SELECT 절. 관계(집합)는 중복이 없으므로 DISTINCT 까지 붙여야 같은 의미

STUDENT
민수
지영
하늘

3 rows selected.

== [Q3] DIVIDE(나누기): 필수 과목(DB, SQL)을 모두 수강한 학생 = 이중 NOT EXISTS

STUDENT
민수
하늘

2 rows selected.

== [Q4] DIVIDE 의 다른 구현: 필수 과목과 조인한 뒤 개수 비교

STUDENT
민수
하늘

2 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex13_relational_ops_sqlserver.sql -->
```text
== [Q1] SELECT(선택, 행 고르기) 연산 = WHERE 절
student|course
-------|------
민수|DB
지영|DB
하늘|DB

(3 rows affected)
== [Q2] PROJECT(추출, 열 고르기) 연산 = SELECT 절. 관계(집합)는 중복이 없으므로 DISTINCT 까지 붙여야 같은 의미
student
-------
민수
지영
하늘

(3 rows affected)
== [Q3] DIVIDE(나누기): 필수 과목(DB, SQL)을 모두 수강한 학생 = 이중 NOT EXISTS
student
-------
민수
하늘

(2 rows affected)
== [Q4] DIVIDE 의 다른 구현: 필수 과목과 조인한 뒤 개수 비교
student
-------
민수
하늘

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q3: "필수 과목 중 이 학생이 듣지 **않은** 과목이 **없다**." 이중 부정이다. 민수(AI는 필수가 아니라 무관), 하늘이 해당한다. 지영은 SQL이 없다.
* Q4: 필수 과목과 조인하면 AI 행이 빠진다. 학생별 필수 과목 수가 2(필수 과목 전체 수)인 학생만 남긴다. `COUNT(DISTINCT)`는 ENROLL에 중복 행이 있을 때를 대비한 것이다. PK가 있으므로 이 데이터에서는 COUNT(*)와 같다.
* 문자 정렬: 한글 이름 정렬은 두 DBMS에서 같은 순서로 나왔다(민수 < 지영 < 하늘).

## F. 변형 문제
1. REQ_COURSE에 'AI'를 추가하면 결과는?
2. REQ_COURSE가 비어 있으면 Q3과 Q4의 결과가 각각 어떻게 되는가? (Q3: 모든 학생, Q4: 0명 → 두 구현이 **다르다**)

G: [exercises/ex13_relational_ops.md](../exercises/ex13_relational_ops.md)
