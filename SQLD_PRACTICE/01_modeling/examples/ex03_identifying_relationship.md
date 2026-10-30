# ex03 식별 관계 vs 비식별 관계

> 근거: 요구목록 §6(식별·비식별 관계). 추출본 본문 없음 · 데이터: 도서–소장본–대출 (R3·R4, 학습용 가상) · 처리 방식: 설계 + DDL·INSERT 실행 검증 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **식별 관계**: 부모의 PK가 자식 PK의 **일부**가 된다(ERD 실선). 자식은 부모 없이 존재할 수 없고(PK 컬럼은 NOT NULL), 부모 단위로 번호를 매길 수 있다(도서별 소장본 1, 2, …).
* **비식별 관계**: 부모의 PK가 자식의 **일반 컬럼(FK)** 이 된다(ERD 점선). 자식은 자기 PK를 가진다. FK에 NULL을 허용하면 부모 없는 자식도 가능하다(선택 관계).
* **선택 기준**: 자식이 부모에 강하게 종속되고 독립 조회가 드물면 식별 관계를 쓴다. 식별 관계가 여러 단계로 이어지면 PK가 계속 길어져(손자는 FK 컬럼 2개, 3개 …) 조인 조건이 복잡해진다. 그럴 때 중간에 비식별 관계(인조 키)로 끊는다.

## B. 입력 데이터
도서–소장본–대출 (R3·R4, 학습용 가상). 예제 SQL 안에서 테이블(M01_*)을 만들고 끝나면 지운다.

## C. 실행 SQL
[Oracle](ex03_identifying_relationship_oracle.sql) · [SQL Server](ex03_identifying_relationship_sqlserver.sql)

## D. 결과 예측 문제
1. 식별 관계에서 도서 A와 B가 모두 copy_seq 1을 가질 수 있는가?
2. 손자(대출) 테이블의 FK 컬럼 수는 식별 관계와 비식별 관계에서 각각 몇 개인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_identifying_relationship_oracle.sql -->
```text
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

1 row created.

1 row created.

Commit complete.

== [Q1] 식별 관계: copy_seq 는 도서마다 1부터 다시 시작할 수 있다 (A-1, B-1 공존)

1 row created.

1 row created.

ISBN|COPY_SEQ
A|1
B|1

2 rows selected.

== [Q2] 식별 관계: 부모 없는 자식 불가 (isbn 이 PK 의 일부라 NULL 불가)
INSERT INTO m01_copy_i VALUES (NULL, 9)
                               *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."M01_COPY_I"."ISBN")

== [Q3] 비식별 관계: FK 가 NULL 이면 부모 없는 자식도 가능 (선택 관계). 필수로 만들려면 NOT NULL 을 추가

1 row created.

1 row created.

COPY_ID|ISBN
1|A
2|(null)

2 rows selected.

== [Q4] 손자 테이블이 부모를 참조하는 FK 컬럼 수: 식별 관계 2개, 비식별 관계 1개

TABLE_NAME|FK_COLUMNS
M01_LOAN_I|2
M01_LOAN_N|1

2 rows selected.

Rollback complete.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_identifying_relationship_sqlserver.sql -->
```text
(2 rows affected)
== [Q1] 식별 관계: 도서마다 일련번호

(2 rows affected)
isbn|copy_seq
----|--------
A|1
B|1

(2 rows affected)
== [Q2] 부모 없는 자식 불가
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 2
Cannot insert the value NULL into column 'isbn', table 'SQLD_LAB.dbo.m01_copy_i'; column does not allow nulls. INSERT fails.
The statement has been terminated.
== [Q3] 비식별 관계: FK NULL 허용

(2 rows affected)
copy_id|isbn
-------|----
1|A
2|NULL

(2 rows affected)
== [Q4] 손자 테이블 FK 컬럼 수
table_name|fk_columns
----------|----------
m01_loan_i|2
m01_loan_n|1

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: (A, 1), (B, 1) 공존 → PK가 (isbn, copy_seq)라서 가능하다.
* Q2: 식별 관계의 자식은 부모 없이 들어갈 수 없다(ORA-01400 / Msg 515).
* Q3: 비식별 관계 + NULL 허용 FK → 부모 없는 소장본(copy_id 2)이 들어간다. 필수로 하려면 NOT NULL을 추가한다.
* Q4: 손자가 부모를 참조하는 FK 컬럼 수: 식별 2개, 비식별 1개(데이터 사전 조회 결과).

## F. 변형 문제
1. 대출 테이블도 (isbn, copy_seq, 대출순번)으로 식별 관계를 만들면 PK는 몇 컬럼인가? 반납 이력 테이블이 또 식별 관계라면?
2. 주문–주문상세 관계는 보통 식별·비식별 중 무엇으로 설계하는가? 이유는?

G: [../exercises/ex03_identifying_relationship.md](../exercises/ex03_identifying_relationship.md)
