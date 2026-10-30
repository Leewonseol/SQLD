# ex01 문자 함수

> 근거: 요구목록 §7(문자 함수). 추출본에 본문 없음 · 데이터: 리터럴(DUAL/FROM 없는 SELECT) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을**: 문자열을 바꾸거나(대소문자, 치환, 자르기, 채우기) 정보(길이, 위치)를 돌려준다.
* **언제**: 코드 정리, 표시 형식, 검색 조건(예: `UPPER(name) LIKE …`).
* **주의**: 같은 목적이어도 함수 이름·인수 순서·NULL과 공백 처리가 DBMS마다 다르다(단원 안내 대응표).

## B. 입력 데이터
리터럴(DUAL/FROM 없는 SELECT). 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex01_char_functions_oracle.sql) · [SQL Server](ex01_char_functions_sqlserver.sql)

## D. 결과 예측 문제
1. `LENGTH('AB  ')`(Oracle)와 `LEN('AB  ')`(SQL Server)는 각각 얼마인가?
2. `INSTR('CORPORATE FLOOR','OR',3,2)`는? SQL Server `CHARINDEX('OR','CORPORATE FLOOR',3)`는?
3. `TRANSLATE('2024-03-15','-0','/o')`의 결과는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_char_functions_oracle.sql -->
```text
== [Q1] 대소문자: LOWER / UPPER / INITCAP

LO|UP|INI
sql developer|SQL DEVELOPER|Sql Developer

1 row selected.

== [Q2] 길이: LENGTH 는 뒤 공백도 센다. LENGTHB 는 바이트(AL32UTF8 한글 3바이트)

LEN_TRAILING|LEN_KO|LENB_KO|LEN_EMPTY
4|3|9|(null)

1 row selected.

== [Q3] SUBSTR(문자열, 시작, 길이). 시작이 음수면 뒤에서부터

S1|S2|S3
Dev|per|Developer

1 row selected.

== [Q4] INSTR(문자열, 찾을값, 시작, n번째)

I1|I2|I3
2|14|0

1 row selected.

== [Q5] TRIM 계열: 지정 문자 제거

L|R|B|LEAD|SP
ABxx|xxAB|AB|ABxx|[AB]

1 row selected.

== [Q6] LPAD / RPAD

LP|RP|CUT
007|AB***|ABC

1 row selected.

== [Q7] REPLACE / TRANSLATE (글자 단위 대응 치환)

REP|REP_DEL|TR
20240315|AA|2o24/o3/15

1 row selected.

== [Q8] 결합과 문자 코드: CONCAT(인수 2개), ||, ASCII, CHR

C3|PIPES|ASC_A|CHR_66
ABC|ABC|65|B

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_char_functions_sqlserver.sql -->
```text
== [Q1] LOWER / UPPER (INITCAP 없음)
lo|up
--|--
sql developer|SQL DEVELOPER

(1 rows affected)
== [Q2] LEN 은 뒤 공백을 세지 않는다. DATALENGTH 는 바이트(NVARCHAR 한글 2바이트)
len_trailing|dlen|len_ko|dlen_ko|len_empty
------------|----|------|-------|---------
2|4|3|6|0

(1 rows affected)
== [Q3] SUBSTRING(문자열, 시작, 길이) - 길이 필수, 음수 시작 없음 -> RIGHT
s1|s2|s3
--|--|--
Dev|per|Developer

(1 rows affected)
== [Q4] CHARINDEX(찾을값, 문자열, 시작) - 인수 순서가 INSTR 와 반대, n번째 지정 없음
i1|i2_from3|i3
--|--------|--
2|5|0

(1 rows affected)
== [Q5] TRIM 계열 (2022: LTRIM/RTRIM 두 번째 인수, TRIM LEADING 지원)
l|r|b|lead|sp
-|-|-|----|--
ABxx|xxAB|AB|ABxx|[AB]

(1 rows affected)
== [Q6] LPAD/RPAD 없음 -> RIGHT(REPLICATE(...) + 값) / LEFT(값 + REPLICATE(...))
lp|rp|cut
--|--|---
007|AB***|ABC

(1 rows affected)
== [Q7] REPLACE / TRANSLATE (2017+). REPLACE 의 세 번째 인수는 필수
rep|rep_del|tr
---|-------|--
20240315|AA|2o24/o3/15

(1 rows affected)
== [Q8] CONCAT(인수 여러 개), +, ASCII, CHAR
c3|plus|asc_a|chr_66
--|----|-----|------
ABC|ABC|65|B

(1 rows affected)
== [Q9] INITCAP 은 없는 함수 -> 오류
Msg 195, Level 15, State 10, Server a70f428a7f8a, Line 2
'INITCAP' is not a recognized built-in function name.
```
<!-- /RESULT -->

**이유**
* Q2: Oracle LENGTH는 뒤 공백을 포함해 4, SQL Server LEN은 뒤 공백을 빼고 2다. 한글 3글자는 AL32UTF8에서 9바이트, NVARCHAR에서 6바이트다. `LENGTH('')`는 Oracle에서 NULL(빈 문자열 = NULL), `LEN('')`은 0이다.
* Q3: SUBSTR(…, 5, 3)='Dev', 음수 시작 -3은 뒤에서 3번째부터 → 'per'.
* Q4: 'OR'는 2·5·14번째에 있다. 3번째 위치부터 찾은 **두 번째** 'OR'는 14다. CHARINDEX는 3번째부터의 첫 번째(5)만 찾는다.
* Q5: LTRIM은 왼쪽, RTRIM은 오른쪽, TRIM은 양쪽의 지정 문자를 없앤다. SQL Server 2022도 같은 결과다.
* Q7: TRANSLATE는 글자 단위로 대응시킨다('-'→'/', '0'→'o'). REPLACE는 문자열 단위다. Oracle `REPLACE('ABAB','B')`처럼 세 번째 인수를 생략하면 삭제다. SQL Server는 세 번째 인수가 필수다.

## F. 변형 문제
1. `SUBSTR('SQL Developer', -9, 3)`은? SQL Server로 같은 결과를 내라.
2. 이메일 `'kim@sqld.kr'`에서 '@' 앞부분만 두 DBMS로 추출하라.
3. `LPAD(NULL, 3, '0')`의 결과는?

G: [../exercises/ex01_char_functions.md](../exercises/ex01_char_functions.md)
