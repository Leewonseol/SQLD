# ex01 도서관 논리 ERD → CREATE TABLE, 업무 규칙 ↔ 제약조건 대응표

> 근거: 요구목록 §6("ERD마다 실제 CREATE TABLE 문을 제시하고, 업무 규칙이 어떤 제약조건으로 구현되는지 대응표") · 데이터: 학습용 가상(01단원 업무 규칙 R1~R10) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 논리 모델의 엔터티 → 테이블, 속성 → 컬럼(자료형·길이 결정), 식별자 → PK, 관계 → FK, 대체키 → UNIQUE, 도메인·업무 조건 → CHECK·NOT NULL·DEFAULT.
* 행 하나로 판단할 수 없는 규칙(R6, R10)은 DDL로 표현되지 않는다. 대응표에 **'구현 불가'** 로 따로 적는다.

## B. 업무 규칙 ↔ 제약조건 대응표
| 규칙 | 업무 규칙 | 구현 | Oracle 제약 이름 | 검증(T1) |
|---|---|---|---|---|
| R1 | 회원번호로 구별 | PK | pk_l02_member | — |
| R1 | 전화번호는 회원마다 다르다 | UNIQUE(대체키) | uq_l02_member_phone | 중복 전화번호 거부 ✔ |
| R2 | 모든 회원은 등급이 있다 | FK + NOT NULL | fk_l02_member_grade | 등급 NULL 거부 ✔ |
| R2 | 등급별 대출 한도 1~10 | CHECK | ck_l02_grade_max | — |
| R3 | 소장본은 도서별 일련번호 | 식별 관계: PK(isbn, copy_seq) + FK(isbn) | pk_l02_copy, fk_l02_copy_book | — |
| R4 | 회원이 소장본을 여러 번 대출 | 교차 엔터티 LOAN, 인조 PK, 복합 FK(isbn, copy_seq) | pk_l02_loan, fk_l02_loan_copy | 없는 소장본 대출 거부 ✔ |
| R5 | 반납일 ≥ 대출일, 반납 전 NULL | CHECK(return_dt >= loan_dt), return_dt NULL 허용 | ck_l02_loan_dt | 반납일 < 대출일 거부 ✔ |
| R6 | 동시 대출 최대 3권(등급별 한도) | **선언적 제약으로 구현 불가** → 트리거(01단원 ex06) | — | — |
| R7 | 도서 M : 저자 N | 교차 테이블 WRITING, 복합 PK | pk_l02_writing | — |
| R8 | 추천인 0..1, 자기 자신 불가 | 자기참조 FK(NULL 허용) + CHECK | fk_l02_member_rec, ck_l02_member_rec | 자기 추천 거부 ✔ |
| R8 | 추천 순환 금지 | **구현 불가**(여러 행 경로) | — | 01단원 ex05 |
| R9 | 카드 최대 1장, 카드는 반드시 회원 것 | FK + NOT NULL + UNIQUE, 회원 삭제 시 카드 삭제 | uq_l02_card_member, fk_l02_card_member(ON DELETE CASCADE) | 두 번째 카드 거부 ✔ |
| R10 | 회원 없는 등급 허용 | 기본(부모 쪽 선택) | — | — |
| R10 | 도서는 소장본 최소 1권 | **구현 불가**(부모 쪽 필수) | — | 01단원 ex02 Q5 |

## C. 실행 SQL
[Oracle](ex01_library_ddl_oracle.sql) · [SQL Server](ex01_library_ddl_sqlserver.sql)

## D. 결과 예측 문제
1. T1의 위반 INSERT 7개 중 성공하는 것은? 각 실패는 어느 제약 때문인가?
2. T3에서 Oracle과 SQL Server의 제약 개수가 다른 이유는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_library_ddl_oracle.sql -->
```text
PL/SQL procedure successfully completed.

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

Table created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [T1] 규칙별 위반 INSERT 가 모두 거부되는지 검증 (R1 UNIQUE, R2 NOT NULL, R3 FK, R5 CHECK, R8 CHECK, R9 UNIQUE)
INSERT INTO l02_member VALUES (3, '다', '010-1', 'N', NULL)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.UQ_L02_MEMBER_PHONE) violated

INSERT INTO l02_member VALUES (4, '라', '010-4', NULL, NULL)
                                                 *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."L02_MEMBER"."GRADE_CD")

INSERT INTO l02_loan VALUES (2, 1, '9780000000001', 9, DATE '2024-03-01', NULL)
*
ERROR at line 1:
ORA-02291: integrity constraint (SQLD_LAB.FK_L02_LOAN_COPY) violated - parent key not found

INSERT INTO l02_loan VALUES (3, 2, '9780000000001', 2, DATE '2024-03-05', DATE '2024-03-01')
*
ERROR at line 1:
ORA-02290: check constraint (SQLD_LAB.CK_L02_LOAN_DT) violated

INSERT INTO l02_member VALUES (5, '마', '010-5', 'N', 5)
*
ERROR at line 1:
ORA-02290: check constraint (SQLD_LAB.CK_L02_MEMBER_REC) violated

1 row created.

INSERT INTO l02_card VALUES (11, 1)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.UQ_L02_CARD_MEMBER) violated

== [T2] 정상 데이터는 남아 있다

MEMBERS|LOANS|CARDS
2|1|1

1 row selected.

== [T3] 제약조건 목록 (데이터 사전): 유형 P=PK, R=FK, U=UNIQUE, C=CHECK/NOT NULL

TABLE_NAME|CONSTRAINT_TYPE|CNT
L02_AUTHOR|C|1
L02_AUTHOR|P|1
L02_BOOK|C|1
L02_BOOK|P|1
L02_CARD|C|1
L02_CARD|P|1
L02_CARD|R|1
L02_CARD|U|1
L02_COPY|C|1
L02_COPY|P|1
L02_COPY|R|1
L02_GRADE|C|3
L02_GRADE|P|1
L02_LOAN|C|5
L02_LOAN|P|1
L02_LOAN|R|2
L02_MEMBER|C|3
L02_MEMBER|P|1
L02_MEMBER|R|2
L02_MEMBER|U|1
L02_WRITING|P|1
L02_WRITING|R|2

22 rows selected.

Rollback complete.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_library_ddl_sqlserver.sql -->
```text
(2 rows affected)

(2 rows affected)

(1 rows affected)

(2 rows affected)

(1 rows affected)
== [T1] 규칙별 위반 INSERT
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 2
Violation of UNIQUE KEY constraint 'uq_l02_member_phone'. Cannot insert duplicate key in object 'dbo.l02_member'. The duplicate key value is (010-1).
The statement has been terminated.
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 1
Cannot insert the value NULL into column 'grade_cd', table 'SQLD_LAB.dbo.l02_member'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the FOREIGN KEY constraint "fk_l02_loan_copy". The conflict occurred in database "SQLD_LAB", table "dbo.l02_copy".
The statement has been terminated.
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the CHECK constraint "ck_l02_loan_dt". The conflict occurred in database "SQLD_LAB", table "dbo.l02_loan".
The statement has been terminated.
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the CHECK constraint "ck_l02_member_rec". The conflict occurred in database "SQLD_LAB", table "dbo.l02_member".
The statement has been terminated.

(1 rows affected)
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 1
Violation of UNIQUE KEY constraint 'uq_l02_card_member'. Cannot insert duplicate key in object 'dbo.l02_card'. The duplicate key value is (1).
The statement has been terminated.
== [T2] 정상 데이터
members|loans|cards
-------|-----|-----
2|1|1

(1 rows affected)
== [T3] 제약조건 목록
table_name|type_desc|cnt
----------|---------|---
l02_author|PRIMARY_KEY_CONSTRAINT|1
l02_book|PRIMARY_KEY_CONSTRAINT|1
l02_card|FOREIGN_KEY_CONSTRAINT|1
l02_card|PRIMARY_KEY_CONSTRAINT|1
l02_card|UNIQUE_CONSTRAINT|1
l02_copy|CHECK_CONSTRAINT|1
l02_copy|FOREIGN_KEY_CONSTRAINT|1
l02_copy|PRIMARY_KEY_CONSTRAINT|1
l02_grade|CHECK_CONSTRAINT|1
l02_grade|PRIMARY_KEY_CONSTRAINT|1
l02_loan|CHECK_CONSTRAINT|1
l02_loan|FOREIGN_KEY_CONSTRAINT|2
l02_loan|PRIMARY_KEY_CONSTRAINT|1
l02_member|CHECK_CONSTRAINT|1
l02_member|FOREIGN_KEY_CONSTRAINT|2
l02_member|PRIMARY_KEY_CONSTRAINT|1
l02_member|UNIQUE_CONSTRAINT|1
l02_writing|FOREIGN_KEY_CONSTRAINT|2
l02_writing|PRIMARY_KEY_CONSTRAINT|1

(19 rows affected)
```
<!-- /RESULT -->

**이유**
* T1: 위반 6건이 모두 거부되고, 첫 카드(10, 1)만 성공한다 → 회원 2, 대출 1, 카드 1.
* T3: Oracle은 **NOT NULL도 CHECK 제약(C)으로** 사전에 기록한다(예: L02_LOAN의 C 5개 = NOT NULL 4 + CHECK 1). SQL Server에서 NOT NULL은 컬럼 속성이라 제약 목록에 나오지 않는다.

## F. 변형 문제
1. 회원을 삭제하면 그 회원의 대출 기록은 어떻게 되는가? 현재 DDL에서는? 대출 기록을 보존하려면?
2. R4를 PK(member_id, isbn, copy_seq, loan_dt)로 바꾸면 무엇이 달라지는가?
3. 등급 테이블에 '정지' 등급(대출 한도 0)을 추가하려면 어떤 제약을 바꿔야 하는가?

G: [../exercises/ex01_library_ddl.md](../exercises/ex01_library_ddl.md)
