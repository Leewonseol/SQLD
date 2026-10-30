# ex03 CREATE · ALTER · RENAME · DROP

> 근거: PDF추출본 E-04(DDL: CREATE·ALTER·DROP·RENAME) · 데이터: D13_PROD(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `CREATE TABLE`: 컬럼, 자료형, DEFAULT, 제약을 정의한다.
* `ALTER TABLE`: ADD(컬럼·제약 추가), MODIFY/ALTER COLUMN(자료형·길이·NULL 여부 변경), RENAME COLUMN, DROP COLUMN.
  * 기존 데이터와 맞지 않는 변경은 거부된다(길이 축소 ORA-01441 / Msg 2628, NULL이 있는데 NOT NULL ORA-02296 / Msg 515).
* `RENAME`(Oracle) / `sp_rename`(SQL Server), `DROP TABLE`(Oracle PURGE: 휴지통 생략).
* Oracle DDL은 실행 전후로 **자동 커밋**한다(14단원 ex01).

## B. 입력 데이터
D13_PROD(학습용 가상 데이터). 실행 전후 데이터 변화는 E의 출력(SELECT 결과와 'n rows …' 메시지)으로 비교한다.

## C. 실행 SQL
[Oracle](ex03_ddl_create_alter_oracle.sql) · [SQL Server](ex03_ddl_create_alter_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 ADD 후 기존 2행의 stock과 memo는?
2. Q3 pname을 3자로 줄이면? Q4 memo를 NOT NULL로 바꾸면?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_ddl_create_alter_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

== [Q1] CREATE TABLE (자료형·기본값·제약 포함)

Table created.

1 row created.

1 row created.

== [Q2] ALTER TABLE ADD (컬럼 추가: 기존 행은 NULL 또는 DEFAULT)

Table altered.

PID|PNAME|PRICE|STOCK|MEMO
1|pencil|0|10|(null)
2|eraser|500|10|(null)

2 rows selected.

== [Q3] ALTER TABLE MODIFY (자료형·길이·NOT NULL 변경). 데이터보다 짧게 줄이면 오류

Table altered.

ALTER TABLE d13_prod MODIFY (pname VARCHAR2(3))
                             *
ERROR at line 1:
ORA-01441: cannot decrease column length because some value is too big

== [Q4] NULL 이 있는 컬럼에 NOT NULL 추가 -> 오류 (기존 데이터 검증)
ALTER TABLE d13_prod MODIFY (memo NOT NULL)
*
ERROR at line 1:
ORA-02296: cannot enable (SQLD_LAB.) - null values found

== [Q5] RENAME COLUMN / DROP COLUMN / RENAME 테이블

Table altered.

Table altered.

Table renamed.

COLUMN_NAME|DATA_TYPE|DATA_LENGTH|NULLABLE
PID|NUMBER|22|N
PNAME|VARCHAR2|20|N
PRICE|NUMBER|22|Y
STOCK|NUMBER|22|Y

4 rows selected.

== [Q6] DROP TABLE (PURGE: 휴지통에 남기지 않음)

Table dropped.

REMAINING
0

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_ddl_create_alter_sqlserver.sql -->
```text
== [Q1] CREATE TABLE

(1 rows affected)

(1 rows affected)
== [Q2] ALTER TABLE ADD (DEFAULT 가 있는 NULL 허용 컬럼은 기존 행에 NULL. WITH VALUES 를 쓰면 기본값)
pid|pname|price|stock|memo
---|-----|-----|-----|----
1|pencil|0|10|NULL
2|eraser|500|10|NULL

(2 rows affected)
== [Q3] ALTER COLUMN (MODIFY 아님). 줄이면 잘림 오류
Msg 2628, Level 16, State 1, Server a70f428a7f8a, Line 2
String or binary data would be truncated in table 'SQLD_LAB.dbo.d13_prod', column 'pname'. Truncated value: ''.
The statement has been terminated.
== [Q4] NULL 이 있는 컬럼을 NOT NULL 로 -> 오류
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 2
Cannot insert the value NULL into column 'memo', table 'SQLD_LAB.dbo.d13_prod'; column does not allow nulls. UPDATE fails.
The statement has been terminated.
== [Q5] sp_rename (컬럼·테이블) / DROP COLUMN
Caution: Changing any part of an object name could break scripts and stored procedures.
Caution: Changing any part of an object name could break scripts and stored procedures.
column_name|data_type|character_maximum_length|is_nullable
-----------|---------|------------------------|-----------
pid|int|NULL|NO
pname|varchar|20|NO
price|int|NULL|YES
stock|int|NULL|YES

(4 rows affected)
== [Q6] DROP TABLE
remaining
---------
0

(1 rows affected)
== [Q7] Oracle 의 MODIFY 문법 -> 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near 'MODIFY'.
```
<!-- /RESULT -->

**이유**
* Q2: Oracle은 DEFAULT 10이 기존 행에 채워진다. SQL Server는 `WITH VALUES`를 붙였기 때문에 10이 채워졌다(붙이지 않으면 NULL). memo는 NULL.
* Q3: 'pencil'·'eraser'가 6자라 축소가 실패한다. Q4: memo가 모두 NULL이라 실패한다.
* Q5: 최종 컬럼 PID·PNAME(20)·PRICE·STOCK. Q7: SQL Server에 MODIFY 문법은 없다(Msg 102).

## F. 변형 문제
1. price 컬럼에 CHECK(price >= 0)를 ALTER로 추가하라.
2. Oracle에서 `ALTER TABLE t ADD c NUMBER NOT NULL`은 행이 있는 테이블에서 성공하는가? DEFAULT를 함께 주면? (미실행 과제)

G: [../exercises/ex03_ddl_create_alter.md](../exercises/ex03_ddl_create_alter.md)
