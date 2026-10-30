# ex07 정규 표현식 함수

> 근거: **추출본에서 확인되지 않은 항목**(SQLD 2024 범위 후보). 요구목록 "PDF에 추가로 등장하는 모든 관련 항목"에 대비해 작성했다. PDF 원문 확인이 필요하다 · 데이터: 05단원 W_CODE · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* Oracle(10g+) `REGEXP_LIKE`, `REGEXP_SUBSTR`, `REGEXP_INSTR`, `REGEXP_COUNT`, `REGEXP_REPLACE`는 POSIX 정규식으로 패턴을 찾는다.
* SQL Server 2022에는 정규식 함수가 없다(Msg 195). LIKE의 `[ ]`·`[^ ]` 문자 집합과 PATINDEX로 일부만 대체할 수 있다. SQL Server 2025와 Azure SQL에 REGEXP_* 함수가 추가되었다고 공식 문서가 밝히지만, **이 환경에서는 실행하지 않았다**(외부 문서 기준).

## B. 입력 데이터
05단원 W_CODE. 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex07_regex_oracle.sql) · [SQL Server](ex07_regex_sqlserver.sql)

## D. 결과 예측 문제
1. `REGEXP_SUBSTR('a1b22c333','[0-9]+',1,2)`는?
2. `REGEXP_COUNT('a1b22c333','[0-9]')`는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex07_regex_oracle.sql -->
```text
== [Q1] REGEXP_LIKE: 숫자로만 된 code

ID|CODE
1|001
2|01
3|1
4|10

4 rows selected.

== [Q2] REGEXP_SUBSTR / REGEXP_INSTR / REGEXP_COUNT / REGEXP_REPLACE

SUB2|INS3|CNT|MASKED
22|7|6|010-1234-****

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex07_regex_sqlserver.sql -->
```text
== [Q0] REGEXP_LIKE -> 2022 에서는 오류
Msg 195, Level 15, State 10, Server a70f428a7f8a, Line 2
'REGEXP_LIKE' is not a recognized built-in function name.
== [Q1] LIKE 패턴으로 대체: 숫자가 아닌 글자가 하나도 없는 값
id|code
--|----
1|001
2|01
3|1
4|10

(4 rows affected)
== [Q2] 일부 기능 대체: PATINDEX (첫 숫자 위치), 끝 4자리 마스킹
first_digit_pos|masked
---------------|------
3|010-1234-****

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 숫자로만 된 4행. 'A1'만 빠진다. SQL Server `NOT LIKE '%[^0-9]%'`(숫자가 아닌 글자가 없음)로 같은 결과.
* Q2: 두 번째 숫자 덩어리 '22', 세 번째 숫자 덩어리 시작 위치 7, 숫자 글자 수 6, 끝 4자리 마스킹.

## F. 변형 문제
1. 이름에 모음(A, E, I, O, U)이 2개 이상인 사원을 REGEXP_COUNT로 구하라.
2. 전화번호 '010-1234-5678'에서 가운데 4자리만 추출하라(두 DBMS).

G: [../exercises/ex07_regex.md](../exercises/ex07_regex.md)
