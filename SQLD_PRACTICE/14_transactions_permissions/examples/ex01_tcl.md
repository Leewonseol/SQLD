# ex01 COMMIT · ROLLBACK · SAVEPOINT 와 DDL·자동 커밋

> 근거: PDF추출본 E-04(TCL COMMIT·ROLLBACK, "TCL: SAVEPOOINT"[오기: SAVEPOINT], "DML: 사용자가 COMMIT 해야 함", "DDL: AUTO COMMIT ROLLBACK 불가능") · 데이터: D14_ACC(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **트랜잭션**: 하나의 논리적 작업 단위. 모두 반영(COMMIT)하거나 모두 취소(ROLLBACK)한다.
* **SAVEPOINT**: 트랜잭션 안의 중간 지점. 그 지점 이후만 취소할 수 있다.
* **DDL과 트랜잭션**: Oracle은 DDL 앞뒤로 암묵적 COMMIT을 한다. SQL Server는 DDL도 트랜잭션에 포함되어 ROLLBACK 된다.
* **자동 커밋 모드**: SQL Server는 기본적으로 문장 하나가 곧 트랜잭션이다.

## B. 입력 데이터
D14_ACC(학습용 가상 데이터)

## C. 실행 SQL
[Oracle](ex01_tcl_oracle.sql) · [SQL Server](ex01_tcl_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 뒤 두 계좌의 잔액은?
2. Q3(Oracle): INSERT → CREATE TABLE → ROLLBACK 뒤 행 수는? SQL Server Q3은?
3. Q4(Oracle): 이미 있는 테이블을 만들다 실패한 DDL도 커밋을 일으키는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_tcl_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

1 row created.

1 row created.

Commit complete.

== [Q1] ROLLBACK: 마지막 COMMIT 이후의 변경을 모두 취소

1 row updated.

Rollback complete.

ID|BAL
1|100
2|100

2 rows selected.

== [Q2] SAVEPOINT: 중간 지점까지만 취소 -> 1번 변경은 남고 2번 변경만 취소

1 row updated.

Savepoint created.

1 row updated.

Rollback complete.

Commit complete.

ID|BAL
1|70
2|100

2 rows selected.

== [Q3] DDL 은 실행 직전에 암묵적 COMMIT -> 앞의 INSERT 가 확정되어 ROLLBACK 해도 남는다

1 row created.

Table created.

Rollback complete.

ROWS_AFTER_DDL_ROLLBACK
3

1 row selected.

== [Q4] 실패한 DDL(이미 있는 테이블 생성)도 앞의 트랜잭션을 커밋했는가?

1 row created.

CREATE TABLE d14_tmp (x NUMBER)
             *
ERROR at line 1:
ORA-00955: name is already used by an existing object

Rollback complete.

ROWS_AFTER_FAILED_DDL_ROLLBACK
4

1 row selected.

== [Q5] 문장 단위 롤백: 트랜잭션 안의 한 문장이 실패해도 앞 문장은 그대로 (트랜잭션은 계속)

1 row updated.

INSERT INTO d14_acc VALUES (1, 999)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.SYS_C008653) violated

Commit complete.

ID|BAL
2|0

1 row selected.

== [Q6] 존재하지 않는 SAVEPOINT 로 ROLLBACK -> 오류
ROLLBACK TO SAVEPOINT nope
*
ERROR at line 1:
ORA-01086: savepoint 'NOPE' never established in this session or is invalid

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_tcl_sqlserver.sql -->
```text
(2 rows affected)
== [Q1] 자동 커밋 모드: BEGIN TRAN 없이 UPDATE 하면 바로 확정 -> ROLLBACK 은 오류

(1 rows affected)
Msg 3903, Level 16, State 1, Server a70f428a7f8a, Line 2
The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.
id|bal
--|---
1|50
2|100

(2 rows affected)

(1 rows affected)
== [Q2] SAVE TRANSACTION / ROLLBACK TRANSACTION 저장점

(1 rows affected)

(1 rows affected)
id|bal
--|---
1|70
2|100

(2 rows affected)
== [Q3] DDL 도 트랜잭션 안에서 ROLLBACK 된다: INSERT 와 CREATE TABLE 모두 취소

(1 rows affected)
rows_after_rollback|ddl_state
-------------------|---------
2|TABLE ROLLED BACK

(1 rows affected)
== [Q4] TRUNCATE 도 트랜잭션 안에서 ROLLBACK 된다
in_tran_after_truncate
----------------------
0

(1 rows affected)
after_rollback
--------------
2

(1 rows affected)
== [Q5] 중첩 트랜잭션: 안쪽 COMMIT 은 @@TRANCOUNT 만 줄인다. 바깥 ROLLBACK 이 전부 취소

(1 rows affected)
trancount_inner
---------------
2

(1 rows affected)
trancount_after_inner_commit
----------------------------
1

(1 rows affected)
id|bal
--|---
1|70

(1 rows affected)
== [Q6] 문장 단위 롤백 (XACT_ABORT OFF 기본): 실패한 INSERT 만 취소, 앞의 UPDATE 는 커밋됨

(1 rows affected)
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 2
Violation of PRIMARY KEY constraint 'PK__d14_acc__3213E83FC801FDF6'. Cannot insert duplicate key in object 'dbo.d14_acc'. The duplicate key value is (1).
The statement has been terminated.
id|bal
--|---
2|0

(1 rows affected)

(1 rows affected)
== [Q7] SET XACT_ABORT ON: 오류가 나면 트랜잭션 전체가 롤백된다

(1 rows affected)
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 5
Violation of PRIMARY KEY constraint 'PK__d14_acc__3213E83FC801FDF6'. Cannot insert duplicate key in object 'dbo.d14_acc'. The duplicate key value is (1).
id|bal|trancount
--|---|---------
2|130|0

(1 rows affected)
== [Q8] IMPLICIT_TRANSACTIONS ON: Oracle 처럼 첫 DML 에서 트랜잭션이 자동 시작

(1 rows affected)
trancount_implicit
------------------
1

(1 rows affected)
id|bal
--|---
1|70

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 마지막 COMMIT 이후 변경이 취소된다(Oracle). SQL Server 자동 커밋 모드에서는 UPDATE가 즉시 확정되어 ROLLBACK이 Msg 3903이다. 값은 50 그대로다(이후 실습을 위해 100으로 되돌렸다).
* Q2: 1번 −30(70) 유지, 2번 +30은 저장점 이후라 취소 → 70, 100(두 DBMS 같음).
* Q3: Oracle은 CREATE TABLE 직전 암묵적 COMMIT으로 INSERT가 확정되어 3행. SQL Server는 INSERT와 CREATE TABLE이 모두 롤백되어 2행이고 테이블도 없다. **결과가 다르다.**
* Q4(Oracle): ORA-00955로 실패했지만 행 수가 4다. **실패한 DDL도 그 앞의 트랜잭션을 커밋했다**(21c 실행 결과).
* Q5: 실패한 INSERT만 취소되고 앞의 UPDATE(2번 → 0)는 커밋된다(두 DBMS 같음). SQL Server Q7: `XACT_ABORT ON`이면 트랜잭션 전체가 롤백되어 130이 유지되고 @@TRANCOUNT는 0이다.
* SQL Server Q4: 트랜잭션 안의 TRUNCATE도 ROLLBACK으로 2행이 돌아온다. Q5: 안쪽 COMMIT 뒤에도 바깥 ROLLBACK이 1번 계좌 변경을 취소한다(70). Q8: IMPLICIT_TRANSACTIONS ON이면 UPDATE에서 트랜잭션이 열려 ROLLBACK이 동작한다.

## F. 변형 문제
1. Oracle에서 `SAVEPOINT a; … SAVEPOINT a;`처럼 같은 이름을 두 번 쓰면 어느 지점으로 돌아가는가? (미실행 과제)
2. SQL Server에서 트리거나 제약 오류가 XACT_ABORT와 함께 어떻게 동작하는지 조사하라.

G: [../exercises/ex01_tcl.md](../exercises/ex01_tcl.md)
