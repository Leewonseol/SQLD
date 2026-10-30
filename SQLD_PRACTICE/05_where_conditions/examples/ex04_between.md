# ex04 BETWEEN a AND b

> 근거: PDF추출본 E-06("a와 b값 사이 (a, b 포함)", "NOT BETWEEN a AND b — a와 b값 사이에 X (a, b 포함X)") · 데이터: EMP, W_TS(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `x BETWEEN a AND b` = `x >= a AND x <= b`(양 끝 포함). 작은 값을 앞에 써야 한다. 거꾸로 쓰면 오류 없이 0행이다.
* `x NOT BETWEEN a AND b` = `x < a OR x > b`(양 끝 미포함).
* **시각 함정**: Oracle DATE와 SQL Server DATETIME2는 시각까지 담는다. `BETWEEN '3/1' AND '3/31'`의 끝값은 3월 31일 00:00:00이라 그날 15시 데이터가 빠진다. 기간 조건은 반열린 구간 `>= 시작 AND < 다음날`로 쓴다.
* 문자열 BETWEEN은 사전순 비교다. `'C'`는 `'CLARK'`보다 작아서 `BETWEEN 'A' AND 'C'`에 CLARK이 포함되지 않는다.

## B. 입력 데이터 (학습용 가상 데이터)
W_TS(id PK, ts): 1 03-01 00:00 / 2 03-15 09:30 / 3 03-31 00:00 / 4 **03-31 15:00** / 5 04-01 00:00

## C. 실행 SQL
[Oracle](ex04_between_oracle.sql) · [SQL Server](ex04_between_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 `sal BETWEEN 1250 AND 1600`에 1250과 1600이 포함되는가? 몇 행인가?
2. Q4는 몇 행이고, 빠지는 id는?
3. Q6 결과에 CLARK이 있는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_between_oracle.sql -->
```text
== [Q1] 양 끝 포함: 1250 이상 1600 이하

ENAME|SAL
MARTIN|1250
WARD|1250
MILLER|1300
TURNER|1500
ALLEN|1600

5 rows selected.

== [Q2] 순서를 거꾸로 쓰면 (sal >= 1600 AND sal <= 1250) 이 되어 0행

CNT
0

1 row selected.

== [Q3] NOT BETWEEN: 양 끝 미포함 범위 밖

ENAME|SAL
SMITH|800
JAMES|950
ADAMS|1100
KING|5000

4 rows selected.

== [Q4] 시각이 포함된 DATE 에 날짜만으로 BETWEEN: 3월 31일 15시가 빠진다

ID|TS
1|2024-03-01 00:00
2|2024-03-15 09:30
3|2024-03-31 00:00

3 rows selected.

== [Q5] 반열린 구간으로 해결: ts >= 3/1 AND ts < 4/1

ID|TS
1|2024-03-01 00:00
2|2024-03-15 09:30
3|2024-03-31 00:00
4|2024-03-31 15:00

4 rows selected.

== [Q6] 문자열 BETWEEN 은 사전순: 'A' ~ 'C' 는 'C' 로 시작하는 긴 이름(CLARK)을 포함하지 않는다

ENAME
ADAMS
ALLEN
BLAKE

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_between_sqlserver.sql -->
```text
== [Q1] 양 끝 포함
ename|sal
-----|---
MARTIN|1250.00
WARD|1250.00
MILLER|1300.00
TURNER|1500.00
ALLEN|1600.00

(5 rows affected)
== [Q2] 거꾸로 쓴 BETWEEN
cnt
---
0

(1 rows affected)
== [Q3] NOT BETWEEN
ename|sal
-----|---
SMITH|800.00
JAMES|950.00
ADAMS|1100.00
KING|5000.00

(4 rows affected)
== [Q4] 시각이 있는 DATETIME2 에 날짜만으로 BETWEEN
id|ts
--|--
1|2024-03-01 00:00
2|2024-03-15 09:30
3|2024-03-31 00:00

(3 rows affected)
== [Q5] 반열린 구간
id|ts
--|--
1|2024-03-01 00:00
2|2024-03-15 09:30
3|2024-03-31 00:00
4|2024-03-31 15:00

(4 rows affected)
== [Q6] 문자열 BETWEEN
ename
-----
ADAMS
ALLEN
BLAKE

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 5행: 양 끝 1250(MARTIN·WARD)과 1600(ALLEN)이 포함된다. 같은 급여 1250이 두 명이라 ename으로 2차 정렬했다.
* Q2 0행: `sal >= 1600 AND sal <= 1250`을 만족하는 값은 없다.
* Q3: 1250 미만(SMITH·JAMES·ADAMS) + 3000 초과(KING). 3000인 SCOTT·FORD는 범위 안이라 빠진다.
* Q4 3행: id 4(03-31 15:00)는 끝값 03-31 00:00보다 크다. Q5(반열린 구간)는 4행이다.
* Q6: ADAMS·ALLEN·BLAKE. CLARK > 'C'라서 빠진다.

## F. 변형 문제
1. Q4에서 Oracle `TRUNC(ts) BETWEEN …`을 쓰면 4행이 되는가? 인덱스 사용 측면의 단점은?
2. `hiredate BETWEEN DATE '1981-01-01' AND DATE '1981-12-31'`로 1981년 입사자를 구하라(EMP의 hiredate는 시각이 00:00이다).
3. `NOT BETWEEN`과 NULL: sal이 NULL인 행은 `NOT BETWEEN` 결과에 포함되는가?

G: [../exercises/ex04_between.md](../exercises/ex04_between.md)
