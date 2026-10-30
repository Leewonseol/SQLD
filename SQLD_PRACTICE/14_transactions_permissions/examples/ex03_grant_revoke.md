# ex03 GRANT · REVOKE · ROLE · WITH GRANT OPTION

> 근거: PDF추출본 E-04(DCL GRANT·REVOKE "데이터베이스에 접근하고 객체들을 사용하도록 권한을 주고 회수하는 명령어"). 상세 구문은 추출본에 없음 · 데이터: D14_SECRET, 실습 계정 SQLD_LAB(소유자)·SQLD_LAB_U2·SQLD_LAB_U3 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `GRANT 권한 ON 객체 TO 사용자|역할 [WITH GRANT OPTION]` / `REVOKE 권한 ON 객체 FROM 사용자|역할`.
* **ROLE**: 권한 묶음. 역할에 권한을 주고, 사용자에게 역할을 준다. 관리가 쉬워진다.
* **WITH GRANT OPTION**: 받은 객체 권한을 다른 사용자에게 다시 줄 수 있다. 회수 동작이 DBMS마다 다르다(아래).
* 시스템 권한의 `WITH ADMIN OPTION`(Oracle)은 연쇄 회수되지 않는다고 공식 문서가 설명한다. 이 환경에서는 실행하지 않았다(DBA 권한 필요 — 미실행).
* 실행 방법: Oracle은 sqlplus `CONNECT`로 사용자를 바꾼다. SQL Server는 `EXECUTE AS USER … REVERT`로 다른 사용자처럼 실행한다.

## B. 입력 데이터
D14_SECRET, 실습 계정 SQLD_LAB(소유자)·SQLD_LAB_U2·SQLD_LAB_U3

## C. 실행 SQL
[Oracle](ex03_grant_revoke_oracle.sql) · [SQL Server](ex03_grant_revoke_sqlserver.sql)

## D. 결과 예측 문제
1. 권한이 없는 U2가 테이블을 조회하면 두 DBMS의 오류는?
2. U2 → U3로 재부여한 뒤 U2의 권한을 회수하면 U3은 조회할 수 있는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_grant_revoke_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

1 row created.

Commit complete.

== [Q1] 권한이 없으면 다른 사용자는 테이블의 존재조차 알 수 없다 -> "없는 테이블" 오류
SELECT * FROM sqld_lab.d14_secret
                       *
ERROR at line 1:
ORA-00942: table or view does not exist

== [Q2] GRANT SELECT 후 조회 가능, INSERT 는 권한 부족

Grant succeeded.

ID|V
1|top

1 row selected.

INSERT INTO sqld_lab.d14_secret VALUES (2, 'x')
                     *
ERROR at line 1:
ORA-01031: insufficient privileges

== [Q3] WITH GRANT OPTION: U2 가 받은 권한을 U3 에게 다시 줄 수 있다

Grant succeeded.

Grant succeeded.

U3_CAN_READ
1

1 row selected.

== [Q4] U2 의 권한을 REVOKE 하면 U2 가 U3 에게 준 객체 권한도 연쇄 회수된다 (Oracle 객체 권한의 기본 동작)

Revoke succeeded.

SELECT COUNT(*) FROM sqld_lab.d14_secret
                              *
ERROR at line 1:
ORA-00942: table or view does not exist

== [Q5] ROLE: 권한을 묶어 역할에 주고, 역할을 사용자에게 부여 (새 세션부터 기본 역할로 활성화)

Role created.

Grant succeeded.

Grant succeeded.

VIA_ROLE
1

1 row selected.

GRANTED_ROLE
D14_READER

1 row selected.

== [Q6] 정리: 역할·테이블 삭제 (DCL·DDL 은 자동 커밋)

Revoke succeeded.

Role dropped.

PL/SQL procedure successfully completed.

CURRENT_USER
SQLD_LAB

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_grant_revoke_sqlserver.sql -->
```text
(1 rows affected)
== [Q1] 권한 없음 -> 권한 거부 오류 (Oracle 과 달리 객체의 존재는 드러난다)
Msg 229, Level 14, State 5, Server a70f428a7f8a, Line 2
The SELECT permission was denied on the object 'd14_secret', database 'SQLD_LAB', schema 'dbo'.
== [Q2] GRANT SELECT 후 조회 가능, INSERT 는 거부
id|v
--|-
1|top

(1 rows affected)
Msg 229, Level 14, State 5, Server a70f428a7f8a, Line 1
The INSERT permission was denied on the object 'd14_secret', database 'SQLD_LAB', schema 'dbo'.
== [Q3] WITH GRANT OPTION -> U2 가 U3 에게 부여
u3_can_read
-----------
1

(1 rows affected)
== [Q4] 재부여한 권한이 있으면 CASCADE 없이 REVOKE 불가 -> 오류
Msg 4611, Level 16, State 1, Server a70f428a7f8a, Line 2
To revoke or deny grantable privileges, specify the CASCADE option.
== [Q4b] REVOKE ... CASCADE: U3 의 권한까지 회수
Msg 229, Level 14, State 5, Server a70f428a7f8a, Line 1
The SELECT permission was denied on the object 'd14_secret', database 'SQLD_LAB', schema 'dbo'.
== [Q5] ROLE: CREATE ROLE + ALTER ROLE ADD MEMBER
via_role
--------
1

(1 rows affected)
== [Q6] DENY (SQL Server 전용): 역할로 받은 권한보다 DENY 가 우선
Msg 229, Level 14, State 5, Server a70f428a7f8a, Line 1
The SELECT permission was denied on the object 'd14_secret', database 'SQLD_LAB', schema 'dbo'.
== [Q7] 정리
current_user_name
-----------------
sqld_lab

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: Oracle ORA-00942(존재하지 않는 것처럼 보인다), SQL Server Msg 229(권한 거부).
* Q2: SELECT만 받았으므로 INSERT는 ORA-01031 / Msg 229.
* Q3·Q4: Oracle은 REVOKE 한 번으로 U3의 권한까지 연쇄 회수되었다(U3 조회 ORA-00942). SQL Server는 CASCADE 없는 REVOKE가 Msg 4611이고, `REVOKE … CASCADE` 뒤 U3이 Msg 229다.
* Q5: 역할로 받은 권한으로 조회된다. Oracle은 새로 접속한 세션에서 기본 역할로 활성화된다.
* Q6(SQL Server): 역할로 SELECT를 받았어도 사용자에게 DENY 하면 거부된다.

## F. 변형 문제
1. U2에게 d14_secret의 v 컬럼만 UPDATE 할 수 있게 하라(컬럼 권한: `GRANT UPDATE (v) ON …`).
2. PUBLIC에 권한을 주면 어떤 위험이 있는가?

G: [../exercises/ex03_grant_revoke.md](../exercises/ex03_grant_revoke.md)
