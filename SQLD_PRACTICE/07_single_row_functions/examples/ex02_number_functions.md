# ex02 숫자 함수

> 근거: 요구목록 §7(숫자 함수). 추출본에 본문 없음 · 데이터: 리터럴 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* ROUND(반올림)·TRUNC(버림)의 두 번째 인수는 소수 자릿수다. 음수면 정수 자리(-1은 십의 자리)다.
* CEIL(올림)·FLOOR(내림)은 음수에서 방향에 주의한다(CEIL(-15.1) = -15, FLOOR(-15.1) = -16).
* MOD(나머지)의 부호는 피제수(왼쪽 값)를 따른다.
* **DBMS 차이**: SQL Server는 TRUNC가 없고 `ROUND(x, n, 1)`로 버린다. 정수끼리 나누면 결과도 정수다(7/2 = 3).

## B. 입력 데이터
리터럴. 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex02_number_functions_oracle.sql) · [SQL Server](ex02_number_functions_sqlserver.sql)

## D. 결과 예측 문제
1. ROUND(15.193, -1), TRUNC(-15.79)는?
2. MOD(-11, 4)와 SQL Server `-11 % 4`는?
3. 7/2는 두 DBMS에서 각각 얼마인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_number_functions_oracle.sql -->
```text
== [Q1] ROUND / TRUNC: 두 번째 인수가 음수면 정수 자리

R1|R2|R3|R4|T1|T2|T3
15.2|20|16|-16|15.7|15|-15

1 row selected.

== [Q2] CEIL / FLOOR (음수 주의)

C1|C2|F1|F2
16|-15|15|-16

1 row selected.

== [Q3] MOD 와 나눗셈: Oracle 의 / 는 항상 실수 나눗셈

M1|M2|M3|DIV|INT_DIV
3|-3|3|3.5|3

1 row selected.

== [Q4] ABS / SIGN / POWER / SQRT

A|S1|S2|P|Q
3.5|-1|0|1024|4

1 row selected.

== [Q5] 0 으로 나누기 -> 오류
SELECT 1 / 0 FROM dual
         *
ERROR at line 1:
ORA-01476: divisor is equal to zero
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_number_functions_sqlserver.sql -->
```text
== [Q1] ROUND(x, n) / 버림은 ROUND(x, n, 1) (TRUNC 없음)
r1|r2|r3|r4|t1|t2|t3
--|--|--|--|--|--|--
15.200|20.000|16.0|-16.0|15.70|15.00|-15.00

(1 rows affected)
== [Q2] CEILING / FLOOR
c1|c2|f1|f2
--|--|--|--
16|-15|15|-16

(1 rows affected)
== [Q3] % 연산자와 나눗셈: 정수 / 정수 = 정수
m1|m2|m3|div|real_div|real_div2
--|--|--|---|--------|---------
3|-3|3|3|3.500000|3.500000

(1 rows affected)
== [Q4] ABS / SIGN / POWER / SQRT
a|s1|s2|p|q
-|--|--|-|-
3.5|-1.0|0|1024|4.0

(1 rows affected)
== [Q5] 0 으로 나누기 -> 오류
Msg 8134, Level 16, State 1, Server a70f428a7f8a, Line 2
Divide by zero error encountered.
== [Q6] MOD / TRUNC 는 없는 함수
Msg 195, Level 15, State 10, Server a70f428a7f8a, Line 2
'MOD' is not a recognized built-in function name.
```
<!-- /RESULT -->

**이유**
* Q1: ROUND(15.5)=16, ROUND(-15.5)=-16. 두 DBMS 모두 0에서 먼 쪽으로 반올림했다. SQL Server는 리터럴의 소수 자릿수를 유지해 15.200, 20.000처럼 표시한다.
* Q2: CEIL(-15.1) = -15(더 큰 정수), FLOOR(-15.1) = -16.
* Q3: MOD(-11, 4) = -3, MOD(11, -4) = 3. 부호는 왼쪽 값을 따른다. 7/2는 Oracle 3.5, SQL Server 3이다. 실수 결과가 필요하면 `7/2.0`처럼 쓴다.
* Q5: 0으로 나누면 ORA-01476 / Msg 8134. NULLIF로 피하는 방법은 ex05 Q3.

## F. 변형 문제
1. 급여의 10% 보너스를 100원 단위에서 버려 계산하라(두 DBMS).
2. `ROUND(2.45, 1)`과 `ROUND(2.55, 1)`을 예측하고 실행해 보라(미실행 과제).
3. 11을 4로 나눈 몫과 나머지를 두 DBMS 문법으로 구하라.

G: [../exercises/ex02_number_functions.md](../exercises/ex02_number_functions.md)
