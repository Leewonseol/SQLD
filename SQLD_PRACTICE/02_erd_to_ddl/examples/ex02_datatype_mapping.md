# ex02 자료형 매핑과 DBMS 차이

> 근거: 요구목록 §8("자료형, NULL, 문자열 결합, 날짜 계산 […]을 확인하라") · 데이터: 학습용 가상 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 논리 자료형 | Oracle | SQL Server | 주의 |
|---|---|---|---|
| 가변 문자 | VARCHAR2(n [BYTE\|CHAR]) | VARCHAR(n)(바이트·코드 페이지), **NVARCHAR(n)**(UTF-16) | Oracle 기본 단위는 BYTE(AL32UTF8 한글 3바이트). SQL Server VARCHAR에 한글을 넣으면 DB 데이터 정렬이 한글을 지원하지 않을 때 '?'로 깨진다 |
| 고정 문자 | CHAR(n) | CHAR(n) / NCHAR(n) | 뒤 공백 패딩. 비교할 때는 뒤 공백 무시 |
| 정수 | NUMBER(p) | TINYINT·SMALLINT·INT·BIGINT | |
| 고정 소수 | NUMBER(p, s) | DECIMAL(p, s) / NUMERIC | 소수는 반올림, 정수부 초과는 오류 |
| 날짜 | DATE(초까지 포함) | DATE(날짜만), DATETIME2(시각) | 05단원 ex04 BETWEEN 함정 |
| 빈 문자열 | NULL로 저장 | 길이 0인 값 | 05단원 ex05 |

## B. 입력 데이터
L02_TYPES (예제 안에서 생성·삭제)

## C. 실행 SQL
[Oracle](ex02_datatype_mapping_oracle.sql) · [SQL Server](ex02_datatype_mapping_sqlserver.sql)

## D. 결과 예측 문제
1. 한글 4글자를 Oracle VARCHAR2(10)와 VARCHAR2(10 CHAR)에 넣으면?
2. CHAR(5)에 'AB'를 넣고 `= 'AB'`로 비교하면?
3. NUMBER(5,2)/DECIMAL(5,2)에 123.456과 1234.5를 넣으면?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_datatype_mapping_oracle.sql -->
```text
PL/SQL procedure successfully completed.

== [Q1] VARCHAR2(n) 의 기본 길이 단위는 바이트(NLS_LENGTH_SEMANTICS=BYTE): 한글 4자(12바이트)는 VARCHAR2(10) 에 들어가지 않는다

Table created.

INSERT INTO l02_types (b) VALUES ('가나다라')
                                  *
ERROR at line 1:
ORA-12899: value too large for column "SQLD_LAB"."L02_TYPES"."B" (actual: 12, maximum: 10)

1 row created.

C|CHARS|BYTES
가나다라|4|12

1 row selected.

== [Q2] CHAR 는 뒤를 공백으로 채운다. CHAR 끼리 비교할 때는 뒤 공백을 무시한다

1 row created.

PADDED|LEN
[AB   ]|5

1 row selected.

EQ_CHAR
1

1 row selected.

== [Q3] NUMBER(5,2): 정수 3자리 + 소수 2자리. 소수는 반올림, 정수부가 넘치면 오류

1 row created.

NUM
123.46

1 row selected.

INSERT INTO l02_types (num) VALUES (1234.5)
                                    *
ERROR at line 1:
ORA-01438: value larger than specified precision allowed for this column

== [Q4] DATE 는 초 단위 시각을 포함한다

1 row created.

DT
2024-03-15 13:45:10

1 row selected.

== [Q5] 빈 문자열은 NULL 로 저장된다

1 row created.

ALL_ROWS|NON_NULL_C
5|1

1 row selected.

Rollback complete.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_datatype_mapping_sqlserver.sql -->
```text
== [Q1] VARCHAR 에 한글: DB 기본 데이터 정렬(SQL_Latin1_General_CP1_CI_AS)의 코드 페이지 1252 로는 표현 불가 -> ?

(1 rows affected)

(1 rows affected)
b|c|chars|bytes
-|-|-----|-----
????|NULL|NULL|NULL
NULL|가나다라|4|8

(2 rows affected)

(2 rows affected)
== [Q2] CHAR 패딩과 비교

(1 rows affected)
padded|len|dlen
------|---|----
[AB   ]|2|5

(1 rows affected)
eq_char
-------
1

(1 rows affected)
== [Q3] DECIMAL(5,2): 반올림 / 정수부 초과 오류

(1 rows affected)
num
---
123.46

(1 rows affected)
Msg 8115, Level 16, State 8, Server a70f428a7f8a, Line 2
Arithmetic overflow error converting numeric to data type numeric.
The statement has been terminated.
== [Q4] DATE 는 날짜만, DATETIME2 는 날짜+시각

(1 rows affected)
dt|dt2
--|---
2024-03-15|2024-03-15 13:45:10

(1 rows affected)
== [Q5] 빈 문자열은 NULL 이 아니다

(1 rows affected)
all_rows|non_null_c
--------|----------
4|1

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: Oracle 바이트 단위는 12 > 10이라 ORA-12899, CHAR 단위는 4자라 성공한다. SQL Server VARCHAR는 오류 없이 '????'로 **데이터가 손상**되었다(코드 페이지 1252). NVARCHAR는 4자·8바이트다. 04단원 setup에서 Oracle 팀 이름이 바이트 초과로 실패해 `VARCHAR2(20 CHAR)`로 고친 일이 이 사례다.
* Q2: CHAR는 패딩되어 `[AB   ]`가 된다. Oracle LENGTH는 5, SQL Server LEN은 뒤 공백을 빼고 2(DATALENGTH 5). 비교는 두 DBMS 모두 일치(1)다.
* Q3: 123.456 → 123.46(반올림), 1234.5 → ORA-01438 / Msg 8115.
* Q4: Oracle DATE는 시각을 유지한다. SQL Server DATE는 시각을 버리고 DATETIME2가 유지한다.
* Q5: 빈 문자열이 Oracle은 NULL(COUNT(c)에서 제외), SQL Server는 값이다.

## F. 변형 문제
1. Oracle에서 `CHAR(5)`와 `VARCHAR2(5)` 컬럼을 비교하면 뒤 공백 규칙이 어떻게 되는가? (공백 패딩 비교 vs 비패딩 비교 — 미실행 과제)
2. SQL Server에서 한글을 VARCHAR에 안전하게 저장하려면 무엇을 바꿔야 하는가? (UTF-8 데이터 정렬 `..._UTF8` 또는 NVARCHAR)

G: [../exercises/ex02_datatype_mapping.md](../exercises/ex02_datatype_mapping.md)
