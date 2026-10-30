# ex02 관계의 차수(1:1·1:N·M:N)와 선택성(필수·선택) 구현

> 근거: 요구목록 §6(1:1, 1:N, M:N 관계, 필수참여·선택참여). 추출본 본문 없음 · 데이터: 업무 규칙 R2·R3·R7·R9·R10 (학습용 가상) · 처리 방식: 설계 + DDL·INSERT 실행 검증 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| ERD에서 읽은 것 | 구현 방법 | 이 실습의 테이블 |
|---|---|---|
| 1:N, 자식 쪽 필수 | 자식에 FK + **NOT NULL** | m01_member.grade_cd |
| 1:N, 자식 쪽 선택 | 자식에 FK(NULL 허용) | m01_mem.recommender_id(ex05) |
| 1:N, 부모 쪽 선택(자식 0개 가능) | 아무것도 하지 않음(기본) | 등급 'V' |
| 1:N, **부모 쪽 필수**(자식 ≥ 1) | **선언적 제약으로 불가** → 트리거/절차·지연 제약 | m01_book–m01_copy (Q5) |
| 1:1 | FK + **UNIQUE**(+ 필수면 NOT NULL) | m01_card.member_id |
| M:N | **교차 엔터티** + 두 FK + 복합 PK | m01_writing |
* 차수와 선택성은 **양쪽 방향**으로 읽는다. "회원은 등급을 정확히 1개 가진다(필수·1)" / "등급은 회원을 0명 이상 가진다(선택·N)".

## B. 입력 데이터
업무 규칙 R2·R3·R7·R9·R10 (학습용 가상). 예제 SQL 안에서 테이블(M01_*)을 만들고 끝나면 지운다.

## C. 실행 SQL
[Oracle](ex02_cardinality_optionality_oracle.sql) · [SQL Server](ex02_cardinality_optionality_sqlserver.sql)

## D. 결과 예측 문제
1. 등급이 NULL인 회원과 없는 등급('X')을 가진 회원은 각각 어떤 오류로 거부되는가?
2. 같은 회원에게 카드를 두 장 줄 수 있는가?
3. 소장본이 하나도 없는 도서를 넣을 수 있는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_cardinality_optionality_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

Table created.

Table created.

Table created.

Table created.

Table created.

Table created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [Q1] 1:N 자식 쪽 필수: 등급 없는 회원 -> NOT NULL 위반 / 없는 등급 -> FK 위반
INSERT INTO m01_member VALUES (3, '다', NULL)
                                        *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."M01_MEMBER"."GRADE_CD")

INSERT INTO m01_member VALUES (3, '다', 'X')
*
ERROR at line 1:
ORA-02291: integrity constraint (SQLD_LAB.FK_M01_MEMBER_GRADE) violated - parent key not found

== [Q2] 1:N 부모 쪽 선택: 회원이 없는 등급 'V' 는 존재할 수 있다

GRADE_CD|MEMBERS
N|2
V|0

2 rows selected.

== [Q3] 1:1 : 같은 회원에게 카드 두 번째 -> UNIQUE 위반 / 회원 없는 카드 -> NOT NULL 위반

1 row created.

INSERT INTO m01_card VALUES (101, 1)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.UQ_M01_CARD_MEMBER) violated

INSERT INTO m01_card VALUES (102, NULL)
                                  *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."M01_CARD"."MEMBER_ID")

== [Q4] M:N : 한 도서에 저자 2명, 같은 (도서, 저자) 쌍 중복은 PK 위반

1 row created.

1 row created.

INSERT INTO m01_writing VALUES ('9780000000001', 10)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.PK_M01_WRITING) violated

WRITING_ROWS
2

1 row selected.

== [Q5] 부모 쪽 필수(R10: 도서는 소장본이 최소 1권)는 막지 못한다 -> 소장본 없는 도서가 들어간다

1 row created.

ISBN|COPIES
9780000000001|2
9780000000002|0

2 rows selected.

Rollback complete.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_cardinality_optionality_sqlserver.sql -->
```text
(2 rows affected)

(2 rows affected)

(1 rows affected)

(2 rows affected)

(2 rows affected)
== [Q1] 자식 쪽 필수
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 2
Cannot insert the value NULL into column 'grade_cd', table 'SQLD_LAB.dbo.m01_member'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the FOREIGN KEY constraint "fk_m01_member_grade". The conflict occurred in database "SQLD_LAB", table "dbo.m01_grade", column 'grade_cd'.
The statement has been terminated.
== [Q2] 부모 쪽 선택
grade_cd|members
--------|-------
N|2
V|0

(2 rows affected)
== [Q3] 1:1

(1 rows affected)
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 2
Violation of UNIQUE KEY constraint 'uq_m01_card_member'. Cannot insert duplicate key in object 'dbo.m01_card'. The duplicate key value is (1).
The statement has been terminated.
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 1
Cannot insert the value NULL into column 'member_id', table 'SQLD_LAB.dbo.m01_card'; column does not allow nulls. INSERT fails.
The statement has been terminated.
== [Q4] M:N

(2 rows affected)
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 1
Violation of PRIMARY KEY constraint 'pk_m01_writing'. Cannot insert duplicate key in object 'dbo.m01_writing'. The duplicate key value is (9780000000001, 10).
The statement has been terminated.
writing_rows
------------
2

(1 rows affected)
== [Q5] 부모 쪽 필수는 막지 못한다

(1 rows affected)
isbn|copies
----|------
9780000000001|2
9780000000002|0

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 NOT NULL(ORA-01400 / Msg 515)과 FK(ORA-02291 / Msg 547)로 '자식 쪽 필수'가 구현된다.
* Q2 부모 쪽 선택: 등급 V는 회원 0명으로 존재한다.
* Q3 1:1: UNIQUE가 두 번째 카드를 막고(ORA-00001 / Msg 2627), NOT NULL이 회원 없는 카드를 막는다.
* Q4 M:N: 복합 PK가 같은 (도서, 저자) 쌍의 중복을 막는다 → 2행.
* Q5: **'도서는 소장본 최소 1권'(부모 쪽 필수)은 들어가 버린다.** 선언적 제약조건은 '자식이 부모를 가리키는' 방향만 강제할 수 있다. 해결책은 ex06(트리거)과 '도서와 첫 소장본을 한 트랜잭션에서 함께 등록'하는 응용 규칙이다.

## F. 변형 문제
1. 회원–카드 관계를 '카드는 선택(회원 없는 임시 카드 가능)'으로 바꾸면 DDL의 무엇을 바꾸는가?
2. M:N 교차 엔터티에 '집필 순서(1저자, 2저자)'를 추가하면 PK는 어떻게 되는가?

G: [../exercises/ex02_cardinality_optionality.md](../exercises/ex02_cardinality_optionality.md)
