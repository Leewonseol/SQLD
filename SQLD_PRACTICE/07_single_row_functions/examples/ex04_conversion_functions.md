# ex04 변환 함수와 암시적 형변환

> 근거: 요구목록 §7(변환 함수). 추출본에 본문 없음. 암시적 변환 주의는 PDF E-06 · 데이터: 리터럴 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **명시적 변환**: Oracle TO_CHAR / TO_NUMBER / TO_DATE / CAST, SQL Server CAST / CONVERT(스타일 번호) / FORMAT / TRY_CAST·TRY_CONVERT(실패 시 NULL).
* **암시적 변환**: DBMS가 자동으로 바꾼다. 편리하지만 인덱스를 못 쓰거나(05단원 ex07) 의미가 바뀐다.
  * Oracle `+`는 산술 전용이다. `'10' + '1'` = 11.
  * SQL Server `+`는 문자끼리면 결합이다. `'10' + '1'` = '101'. 숫자가 섞이면 자료형 우선순위에 따라 숫자로 바뀐다. `'10' + 1` = 11.

## B. 입력 데이터
리터럴. 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex04_conversion_functions_oracle.sql) · [SQL Server](ex04_conversion_functions_sqlserver.sql)

## D. 결과 예측 문제
1. `'10' + '1'`은 두 DBMS에서 각각?
2. `CAST(12.7 AS NUMBER(3))`(Oracle)와 SQL Server `CAST(12.7 AS INT)`는?
3. `TO_DATE('2024-13-01','YYYY-MM-DD')`는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_conversion_functions_oracle.sql -->
```text
== [Q1] TO_CHAR(날짜, 형식) / TO_CHAR(숫자, 형식)

D1|D2|N1|N2
2024/03/05 14:07:09|20240305|1,234,567.89|007

1 row selected.

== [Q2] TO_NUMBER / TO_DATE

N|D
1235.5|2024-03-15

1 row selected.

== [Q3] CAST

C1|C2|C3
124|2024-03-15 00:00:00|13

1 row selected.

== [Q4] 암시적 변환: Oracle 의 + 는 산술 전용 -> 문자 '10' + '1' = 11

A|B|C
11|11|101

1 row selected.

== [Q5] 변환 실패 -> 오류
SELECT TO_NUMBER('12A') FROM dual
                 *
ERROR at line 1:
ORA-01722: invalid number

== [Q6] 형식과 맞지 않는 날짜 문자열 -> 오류
SELECT TO_DATE('2024-13-01', 'YYYY-MM-DD') FROM dual
               *
ERROR at line 1:
ORA-01843: not a valid month
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_conversion_functions_sqlserver.sql -->
```text
== [Q1] CONVERT(형, 값, 스타일) / FORMAT
d1|d2|n1|n2
--|--|--|--
2024-03-05 14:07:09|20240305|1,234,567.89|007

(1 rows affected)
== [Q2] CAST / CONVERT 로 숫자·날짜
n|d
-|-
1235.5|2024-03-15

(1 rows affected)
== [Q3] CAST (DECIMAL 로 줄이면 반올림)
c1|c2|c3|c4
--|--|--|--
124|2024-03-15 00:00:00|13|12

(1 rows affected)
== [Q4] 암시적 변환: + 는 문자끼리면 결합, 숫자가 섞이면 자료형 우선순위로 숫자
a|b|c
-|-|-
11|101|101

(1 rows affected)
== [Q5] TRY_CAST / TRY_CONVERT: 실패하면 NULL
t1|t2
--|--
NULL|NULL

(1 rows affected)
== [Q6] CAST 실패 -> 오류
Msg 245, Level 16, State 1, Server a70f428a7f8a, Line 2
Conversion failed when converting the varchar value '12A' to data type int.
== [Q7] 잘못된 날짜 문자열 -> 오류
Msg 242, Level 16, State 3, Server a70f428a7f8a, Line 2
The conversion of a varchar data type to a datetime data type resulted in an out-of-range value.
```
<!-- /RESULT -->

**이유**
* Q1: 형식 모델(`YYYY/MM/DD HH24:MI:SS`, `FM999,999,999.00`)과 SQL Server 스타일(120, 112)·FORMAT 문자열('N2', '000')로 같은 결과를 냈다.
* Q3: Oracle NUMBER(3)·SQL Server DECIMAL(3,0)은 반올림(13), SQL Server INT는 버림(12). **같은 '정수 변환'도 결과가 다르다.**
* Q4: Oracle 11/11/'101', SQL Server 11/'101'/'101'.
* Q5~Q7: 변환 실패 → ORA-01722, ORA-01843 / Msg 245, Msg 242. SQL Server TRY_CAST는 NULL을 돌려준다.

## F. 변형 문제
1. 사원 입사일을 'YYYY년 MM월' 형식 문자열로 출력하라.
2. 문자열 '3,000'을 숫자로 바꿔 급여와 비교하라.
3. Oracle `TO_CHAR(0.5, '9.9')`와 `TO_CHAR(0.5, '0.9')`의 차이는? (미실행 과제)

G: [../exercises/ex04_conversion_functions.md](../exercises/ex04_conversion_functions.md)
