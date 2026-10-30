# ex04 DELETE · TRUNCATE · DROP 비교

> 근거: PDF추출본 E-04("DDL: TRUNCATE(오토커밋이라)", "DDL: AUTO COMMIT ROLLBACK 불가능") · 데이터: D13_PARENT·D13_CHILD(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| 분류 | DML | DDL | DDL |
| 대상 | WHERE로 일부 가능 | 모든 행(WHERE 불가) | 테이블 구조까지 |
| 롤백 | 가능 | Oracle 불가 / SQL Server 트랜잭션 안에서 가능 | Oracle 불가 / SQL Server 트랜잭션 안에서 가능 |
| 저장 공간 | 유지 | 해제(초기화) | 해제 |
* FK가 참조하는 부모: DELETE는 자식 행이 있으면 실패한다. TRUNCATE·DROP은 아래 실행 결과처럼 DBMS마다 다르다.

## B. 입력 데이터
D13_PARENT·D13_CHILD(학습용 가상 데이터). 실행 전후 데이터 변화는 E의 출력(SELECT 결과와 'n rows …' 메시지)으로 비교한다.

## C. 실행 SQL
[Oracle](ex04_truncate_delete_drop_oracle.sql) · [SQL Server](ex04_truncate_delete_drop_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(DELETE 후 ROLLBACK)과 Q2(TRUNCATE 후 ROLLBACK)의 결과 행 수는?
2. 자식이 비어 있을 때 부모를 TRUNCATE 할 수 있는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_truncate_delete_drop_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

Table created.

5 rows created.

1 row created.

Commit complete.

== [Q1] DELETE (DML): WHERE 가능, ROLLBACK 으로 되돌릴 수 있다

1 row deleted.

AFTER_DELETE
0

1 row selected.

Rollback complete.

AFTER_ROLLBACK
1

1 row selected.

== [Q2] TRUNCATE (DDL): 자동 커밋 -> ROLLBACK 해도 돌아오지 않는다

Table truncated.

Rollback complete.

AFTER_TRUNCATE_ROLLBACK
0

1 row selected.

== [Q3a] 자식 테이블이 비어 있으면 FK 가 참조하는 부모도 TRUNCATE 된다 (21c·23ai 실행 결과. 19c 미실행)

Table truncated.

PARENT_AFTER_TRUNCATE
0

1 row selected.

5 rows created.

1 row created.

Commit complete.

== [Q3b] 자식에 행이 있으면 부모 TRUNCATE 불가 -> 오류
TRUNCATE TABLE d13_parent
               *
ERROR at line 1:
ORA-02266: unique/primary keys in table referenced by enabled foreign keys

== [Q4] TRUNCATE 에는 WHERE 가 없다 -> 오류
TRUNCATE TABLE d13_child WHERE id = 1
                         *
ERROR at line 1:
ORA-03291: Invalid truncate option - missing STORAGE keyword

== [Q5] DROP: 구조까지 삭제. 자식 FK 가 있으면 CASCADE CONSTRAINTS 필요
DROP TABLE d13_parent
           *
ERROR at line 1:
ORA-02449: unique/primary keys in table referenced by foreign keys

Table dropped.

FK_LEFT
0

1 row selected.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_truncate_delete_drop_sqlserver.sql -->
```text
(5 rows affected)

(1 rows affected)
== [Q1] DELETE 를 명시적 트랜잭션 안에서 -> ROLLBACK 으로 복구

(1 rows affected)
after_delete
------------
0

(1 rows affected)
after_rollback
--------------
1

(1 rows affected)
== [Q2] 자동 커밋 모드의 TRUNCATE: 이미 커밋됨 (ROLLBACK 할 트랜잭션이 없다)
after_truncate
--------------
0

(1 rows affected)
== [Q2b] 트랜잭션 없이 ROLLBACK -> 오류
Msg 3903, Level 16, State 1, Server a70f428a7f8a, Line 2
The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.
== [Q3] FK 가 참조하는 부모 TRUNCATE -> 오류
Msg 4712, Level 16, State 1, Server a70f428a7f8a, Line 2
Cannot truncate table 'd13_parent' because it is being referenced by a FOREIGN KEY constraint.
== [Q5] 자식 FK 가 있는 부모 DROP -> 오류 (SQL Server 는 CASCADE 옵션이 없다: FK 먼저 삭제)
Msg 3726, Level 16, State 1, Server a70f428a7f8a, Line 2
Could not drop object 'd13_parent' because it is referenced by a FOREIGN KEY constraint.
```
<!-- /RESULT -->

**이유**
* Q1: DELETE는 ROLLBACK으로 1행이 돌아온다. Q2(Oracle): TRUNCATE는 자동 커밋이라 ROLLBACK 뒤에도 0행이다. SQL Server 자동 커밋 모드에서는 TRUNCATE가 바로 확정되고, 뒤의 ROLLBACK은 '트랜잭션 없음' Msg 3903이다.
* Q3: **Oracle 21c(23ai도 같음)는 자식 테이블이 비어 있으면 부모 TRUNCATE를 허용했다.** 자식에 행이 있을 때만 ORA-02266이다. "FK가 참조하면 TRUNCATE 불가"라는 일반 설명과 다르다(19c는 미실행). SQL Server는 자식이 비어 있어도 Msg 4712다.
* Q4: TRUNCATE에 WHERE → ORA-03291.
* Q5: 부모 DROP → ORA-02449. CASCADE CONSTRAINTS를 쓰면 자식의 FK까지 삭제된다(FK_LEFT 0). SQL Server는 Msg 3726이고, FK를 먼저 지워야 한다.

## F. 변형 문제
1. 30번 부서 사원만 지우는 데 TRUNCATE를 쓸 수 있는가?
2. 14단원 ex01에서 SQL Server의 `BEGIN TRAN; TRUNCATE; ROLLBACK;` 결과를 확인하라.

G: [../exercises/ex04_truncate_delete_drop.md](../exercises/ex04_truncate_delete_drop.md)
