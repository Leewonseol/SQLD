# ex03 날짜 함수와 날짜 연산

> 근거: 요구목록 §7(날짜 함수, 날짜 계산). 추출본에 본문 없음 · 데이터: 고정 날짜 리터럴(실행 시점과 무관한 결과) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* Oracle DATE는 초 단위 시각까지 담는다. `DATE + n`은 n일 뒤, `+ 1/24`는 1시간 뒤다. `DATE - DATE`는 일 수(실수)다.
* `ADD_MONTHS(d, n)`: 말일이거나 결과 월에 같은 일이 없으면 결과 월의 말일. `MONTHS_BETWEEN(a, b)`: 실수 개월 수(둘 다 말일이면 정수).
* SQL Server: `DATEADD(단위, n, d)`, `DATEDIFF(단위, 시작, 끝)`. DATEDIFF는 "단위 경계를 몇 번 넘었는가"를 센다. 1월 31일 → 2월 1일은 하루 차이지만 DATEDIFF(MONTH)는 1이다.
* DATE 형에 `+ 1`을 하면 SQL Server는 오류다(DATETIME 형은 허용).

## B. 입력 데이터
고정 날짜 리터럴(실행 시점과 무관한 결과). 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex03_date_functions_oracle.sql) · [SQL Server](ex03_date_functions_sqlserver.sql)

## D. 결과 예측 문제
1. 2024-01-31 + 1개월은? 2024-02-29 + 12개월은?
2. 2024-01-31부터 2024-02-01까지의 개월 수를 MONTHS_BETWEEN과 DATEDIFF(MONTH)로 각각 예측하라.
3. SQL Server에서 `CAST('2024-01-31' AS DATE) + 1`은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_date_functions_oracle.sql -->
```text
== [Q1] DATE + 숫자 = 일 단위 덧셈. 1/24 = 1시간

PLUS1|PLUS1H
2024-02-01|2024-01-31 01:00

1 row selected.

== [Q2] DATE - DATE = 일 수(숫자)

DAYS_FEB_2024|DAYS_FEB_2023
29|28

1 row selected.

== [Q3] ADD_MONTHS: 말일은 말일로. MONTHS_BETWEEN: 실수 개월 수

AM1|AM12|MB_LASTDAYS|MB_1DAY
2024-02-29|2025-02-28|1|.0323

1 row selected.

== [Q4] LAST_DAY / TRUNC(날짜, 단위) / ROUND(날짜, 단위)

LAST_D|TRUNC_MM|TRUNC_YY|ROUND_MM
2024-02-29|2024-03-01|2024-01-01|2024-04-01

1 row selected.

== [Q5] EXTRACT 와 TO_CHAR 로 부분 추출

Y|M|DD
2024|3|15

1 row selected.

== [Q6] 현재 시각 함수: SYSDATE(DATE), SYSTIMESTAMP (값은 실행 시점마다 다르므로 자료형만 확인)

CHK
SYSDATE_OK

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_date_functions_sqlserver.sql -->
```text
== [Q1] DATEADD (DATE 형에 + 1 은 오류: Q7)
plus1|plus1h
-----|------
2024-02-01|2024-01-31 01:00

(1 rows affected)
== [Q2] DATEDIFF(DAY, 시작, 끝)
days_feb_2024|days_feb_2023
-------------|-------------
29|28

(1 rows affected)
== [Q3] DATEADD(MONTH) 와 DATEDIFF(MONTH): DATEDIFF 는 "경계를 넘은 횟수"
am1|am12|dd_lastdays|dd_1day
---|----|-----------|-------
2024-02-29|2025-02-28|1|1

(1 rows affected)
== [Q4] EOMONTH / DATETRUNC(2022+) / 월초 계산
last_d|trunc_mm|trunc_yy|first_day
------|--------|--------|---------
2024-02-29|2024-03-01|2024-01-01|2024-03-01

(1 rows affected)
== [Q5] YEAR / MONTH / DATEPART / DAY
y|m|dd
-|-|--
2024|3|15

(1 rows affected)
== [Q6] 현재 시각: GETDATE(DATETIME), SYSDATETIME(DATETIME2)
chk
---
GETDATE_OK

(1 rows affected)
== [Q8] DATETIME 형은 + 1 이 하루 덧셈으로 허용된다
dt_plus1
--------
2024-02-01 00:00:00.000

(1 rows affected)
== [Q7] DATE 형 + 1 -> 오류 (피연산자 형식 충돌)
Msg 206, Level 16, State 2, Server a70f428a7f8a, Line 2
Operand type clash: date is incompatible with int
```
<!-- /RESULT -->

**이유**
* Q2: 2024년은 윤년이라 2월이 29일, 2023년은 28일이다.
* Q3: 두 DBMS 모두 1/31 + 1개월 = 2/29(말일 보정), 2024-02-29 + 12개월 = 2025-02-28. MONTHS_BETWEEN(3/31, 2/29) = 1(둘 다 말일). 1/31→2/1: MONTHS_BETWEEN = 1/31 ≈ 0.0323, DATEDIFF(MONTH) = 1. **결과가 다르다.**
* Q4: TRUNC(d,'MM') = 월초. ROUND(3/16,'MM') = 4/1(16일부터 올림). SQL Server 2022 DATETRUNC가 TRUNC에 대응한다.
* Q6: 현재 시각은 실행할 때마다 다르므로 비교 결과만 확인했다.
* Q7·Q8: SQL Server DATE + 1은 Msg 206, DATETIME + 1은 하루 뒤다.

## F. 변형 문제
1. EMP의 각 사원 근속 개월 수를 2024-03-31 기준으로 두 DBMS에서 구하고(Oracle은 소수 버림), 결과가 같은지 비교하라.
2. 2024년 각 달의 말일을 구하라.
3. 입사일이 속한 분기의 첫날을 구하라(Oracle TRUNC(d,'Q')).

G: [../exercises/ex03_date_functions.md](../exercises/ex03_date_functions.md)
