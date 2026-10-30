# ex01 INSERT · UPDATE · DELETE

> 근거: PDF추출본 E-04(DML: INSERT·UPDATE·DELETE, "DML: 사용자가 COMMIT 해야 함"), 요구목록 §7 · 데이터: D13_MEMBER(학습용 가상 데이터, 예제 안에서 생성·삭제) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `INSERT INTO t [(컬럼목록)] VALUES (…)` / `INSERT INTO t SELECT …`. 컬럼 목록을 생략하면 테이블의 모든 컬럼에 정의 순서대로 넣는다. 일부 컬럼만 쓰면 나머지는 DEFAULT(없으면 NULL)가 들어간다. 명시적으로 `NULL`을 넣으면 DEFAULT가 무시된다.
* `UPDATE t SET c1 = …, c2 = … [WHERE]` / `DELETE [FROM] t [WHERE]`. **WHERE가 없으면 모든 행**이 대상이다.
* 제약을 위반하면 그 문장 전체가 실패한다(일부 행만 들어가지 않는다).

## B. 입력 데이터
D13_MEMBER(학습용 가상 데이터, 예제 안에서 생성·삭제). 실행 전후 데이터 변화는 E의 출력(SELECT 결과와 'n rows …' 메시지)으로 비교한다.

## C. 실행 SQL
[Oracle](ex01_insert_update_delete_oracle.sql) · [SQL Server](ex01_insert_update_delete_sqlserver.sql)

## D. 결과 예측 문제
1. Q1에서 lee와 park의 grade·point는?
2. Q2 이후 행 수는? Q4 이후는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_insert_update_delete_oracle.sql -->
```text
PL/SQL procedure successfully completed.

Table created.

== [Q1] INSERT: 컬럼 목록 생략(모든 컬럼 순서대로) / 일부 컬럼만 -> 나머지는 DEFAULT 또는 NULL

1 row created.

1 row created.

1 row created.

ID|NAME|GRADE|POINT
1|kim|VIP|100
2|lee|BASIC|0
3|park|(null)|0

3 rows selected.

== [Q2] 여러 행 INSERT: INSERT ALL (19c) / INSERT ... SELECT

2 rows created.

3 rows created.

CNT
8

1 row selected.

== [Q3] UPDATE: WHERE 로 대상 제한, 여러 컬럼 동시 변경, 자기 컬럼 참조

2 rows updated.

ID|GRADE|POINT
2|GOLD|50
3|GOLD|50

2 rows selected.

== [Q4] DELETE: WHERE 없는 DELETE 는 모든 행 (Oracle 은 FROM 생략 가능: DELETE d13_member WHERE ...)

3 rows deleted.

CNT_AFTER_DELETE
5

1 row selected.

== [Q5] 제약 위반 INSERT 는 문장 전체가 실패한다 (PK 중복, NOT NULL)
INSERT INTO d13_member (id, name) VALUES (1, 'dup')
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.PK_D13_MEMBER) violated

INSERT INTO d13_member (id, name) VALUES (9, NULL)
                                             *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."D13_MEMBER"."NAME")

== [Q6] 값 개수와 컬럼 수 불일치 -> 오류
INSERT INTO d13_member VALUES (10, 'short')
            *
ERROR at line 1:
ORA-00947: not enough values

Rollback complete.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_insert_update_delete_sqlserver.sql -->
```text
== [Q1] INSERT

(1 rows affected)

(1 rows affected)

(1 rows affected)
id|name|grade|point
--|----|-----|-----
1|kim|VIP|100
2|lee|BASIC|0
3|park|NULL|0

(3 rows affected)
== [Q2] 여러 행 INSERT: VALUES (..), (..) / INSERT ... SELECT

(2 rows affected)

(3 rows affected)
cnt
---
8

(1 rows affected)
== [Q3] UPDATE

(2 rows affected)
id|grade|point
--|-----|-----
2|GOLD|50
3|GOLD|50

(2 rows affected)
== [Q4] DELETE (FROM 생략 가능)

(3 rows affected)
cnt_after_delete
----------------
5

(1 rows affected)
== [Q5] 제약 위반 INSERT
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 2
Violation of PRIMARY KEY constraint 'pk_d13_member'. Cannot insert duplicate key in object 'dbo.d13_member'. The duplicate key value is (1).
The statement has been terminated.
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 1
Cannot insert the value NULL into column 'name', table 'SQLD_LAB.dbo.d13_member'; column does not allow nulls. INSERT fails.
The statement has been terminated.
== [Q6] 값 개수 불일치
Msg 213, Level 16, State 1, Server a70f428a7f8a, Line 2
Column name or number of supplied values does not match table definition.
```
<!-- /RESULT -->

**이유**
* Q1: lee는 DEFAULT로 BASIC·0. park는 grade에 NULL을 명시해 NULL, point는 DEFAULT 0.
* Q2: 3 + 2 + 10번 부서 3명 = 8행. Q3: 2행 갱신. Q4: id > 100(사번 7782·7839·7934) 3행 삭제 → 5행.
* Q5: PK 중복 ORA-00001 / Msg 2627, NOT NULL ORA-01400 / Msg 515. Q6: 값 개수 부족 ORA-00947 / Msg 213.
* 실행기 주의: SQL Server sqlcmd에서 한 배치 안에 오류 문장이 여러 개 있으면 첫 오류 뒤 메시지가 'Invalid cursor state'로 바뀌어 보인다. 그래서 오류 문장마다 GO로 배치를 나눴다.

## F. 변형 문제
1. `INSERT INTO d13_member (name, id) VALUES (6, 'x')`는? (컬럼 순서와 값 순서)
2. UPDATE의 WHERE를 빠뜨렸을 때 되돌리는 방법을 두 DBMS에서 설명하라(14단원).

G: [../exercises/ex01_insert_update_delete.md](../exercises/ex01_insert_update_delete.md)
