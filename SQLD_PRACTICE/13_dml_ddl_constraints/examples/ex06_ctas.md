# ex06 CTAS · SELECT INTO 가 복사하는 것

> 근거: 요구목록 §7(CREATE). 추출본에 CTAS 본문 없음 · 데이터: EMP(00_common) → D13_EMP_COPY · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* Oracle `CREATE TABLE 새 AS SELECT …`, SQL Server `SELECT … INTO 새 FROM …`.
* 복사되는 것: 컬럼 이름·자료형, 데이터, **NOT NULL**(NULL 허용 여부).
* 복사되지 않는 것: PK, FK, UNIQUE, CHECK, DEFAULT, 인덱스. 필요하면 ALTER로 다시 만든다.
* `WHERE 1 = 0`을 쓰면 구조만 복사한다.

## B. 입력 데이터
EMP(00_common) → D13_EMP_COPY. 실행 전후 데이터 변화는 E의 출력(SELECT 결과와 'n rows …' 메시지)으로 비교한다.

## C. 실행 SQL
[Oracle](ex06_ctas_oracle.sql) · [SQL Server](ex06_ctas_sqlserver.sql)

## D. 결과 예측 문제
1. 원본 EMP의 PK·FK가 D13_EMP_COPY에 있는가? ename의 NOT NULL은?
2. 복사본에 7369를 한 번 더 넣으면?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_ctas_oracle.sql -->
```text
PL/SQL procedure successfully completed.

== [Q1] 원본 EMP 의 제약: PK, FK 2개, NOT NULL(ename)

CONSTRAINT_TYPE|CNT
C|1
P|1
R|2

3 rows selected.

== [Q2] CTAS: 데이터와 컬럼(자료형)·NOT NULL 만 복사, PK/FK/UNIQUE/CHECK/DEFAULT 는 복사하지 않는다

Table created.

CONSTRAINT_TYPE|CNT
C|1

1 row selected.

COPIED_ROWS
14

1 row selected.

== [Q3] PK 가 없으니 중복 입력이 된다

1 row created.

DUP_7369
2

1 row selected.

Rollback complete.

== [Q4] 구조만 복사: WHERE 1 = 0

PL/SQL procedure successfully completed.

Table created.

ROWS_STRUCT_ONLY
0

1 row selected.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_ctas_sqlserver.sql -->
```text
== [Q0] CREATE TABLE AS SELECT -> 오류
Msg 156, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near the keyword 'SELECT'.
== [Q1] 원본 EMP 의 키 제약
type_desc|cnt
---------|---
FOREIGN_KEY_CONSTRAINT|2
PRIMARY_KEY_CONSTRAINT|1

(2 rows affected)
== [Q2] SELECT INTO: 데이터·컬럼·NULL 허용 여부만 복사, PK/FK 는 복사하지 않는다

(14 rows affected)
key_constraints
---------------
0

(1 rows affected)
ename_allows_null|copied_rows
-----------------|-----------
0|14

(1 rows affected)
== [Q3] PK 가 없으니 중복 입력

(1 rows affected)
dup_7369
--------
2

(1 rows affected)
== [Q4] 구조만 복사

(0 rows affected)
rows_struct_only
----------------
0

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 원본 Oracle은 P(1), R(2), C(1: ename NOT NULL은 Oracle 사전에 C로 기록). SQL Server는 PK 1, FK 2.
* Q2: 복사본에는 NOT NULL(C 1개)만 남는다. SQL Server도 키 제약 0개, ename NULL 허용 0(=NOT NULL 유지).
* Q3: PK가 없으니 중복이 들어간다 → 2행.
* Q4: 구조만 복사 → 0행. SQL Server Q0: CREATE TABLE … AS SELECT는 Msg 156.

## F. 변형 문제
1. 복사본에 empno PK를 추가하라. 중복 행이 있다면 어떻게 되는가?
2. DEFAULT를 가진 컬럼을 CTAS로 복사한 뒤 컬럼 없이 INSERT 하면 어떤 값이 들어가는가?

G: [../exercises/ex06_ctas.md](../exercises/ex06_ctas.md)
