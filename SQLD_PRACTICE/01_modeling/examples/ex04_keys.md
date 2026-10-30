# ex04 키의 종류와 식별자

> 근거: 요구목록 §6(후보키·기본키·대체키·슈퍼키·외래키, 본질식별자·인조식별자). 추출본 본문 없음 · 데이터: M01_STUDENT 4행, M01_ORDER(학습용 가상) · 처리 방식: 설계 + DDL·INSERT 실행 검증 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 용어 | 정의 | 이 실습 |
|---|---|---|
| 슈퍼키 | 유일성만 만족하는 속성 집합 | {stu_no, name}, {email, dept} … |
| 후보키 | 유일성 + **최소성**(하나라도 빼면 유일하지 않음) | {stu_no}, {email} |
| 기본키(PK) | 후보키 중 선택한 하나. NOT NULL + 유일 | stu_no |
| 대체키 | 선택되지 않은 후보키. UNIQUE로 구현 | email |
| 외래키(FK) | 다른(또는 같은) 테이블의 PK·UK를 참조 | ex02, ex05 |
| 본질 식별자 | 업무에 원래 있는 식별자(ISBN, 학번) | stu_no, ISBN |
| 인조 식별자 | 업무 의미 없이 만든 일련번호(IDENTITY, 시퀀스) | m01_order.order_id |
* **데이터로 키를 증명할 수 없다.** 현재 데이터에서 유일해도({name, birth}) 업무 규칙상 중복이 가능하면 키가 아니다. SQL은 '중복이 있다 → 키가 아니다'를 반증할 때만 쓴다(Q1).

## B. 입력 데이터
M01_STUDENT 4행, M01_ORDER(학습용 가상). 예제 SQL 안에서 테이블(M01_*)을 만들고 끝나면 지운다.

## C. 실행 SQL
[Oracle](ex04_keys_oracle.sql) · [SQL Server](ex04_keys_sqlserver.sql)

## D. 결과 예측 문제
1. Q1에서 dup_groups가 0인 속성(조합)은? 그중 후보키는?
2. email이 NULL인 학생을 넣을 수 있는가(대체키)?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_keys_oracle.sql -->
```text
PL/SQL procedure successfully completed.

Table created.

1 row created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [Q1] 유일성 검사: 각 속성(조합)에 중복 값이 있는가 (dup_groups 0 이면 현재 데이터에서 유일)

ATTR|DUP_GROUPS
stu_no|0
email|0
name|1
birth|1
name+birth|0
stu_no+name|0

6 rows selected.

== [Q2] 결정: 후보키 = {stu_no}, {email} (유일 + 최소). {stu_no, name} 은 유일하지만 최소가 아니다 = 슈퍼키
{name, birth} 는 지금은 유일하지만 업무상 동명이인·같은 생일이 가능 -> 키가 아니다(데이터가 아니라 규칙으로 판단)

Table altered.

Table altered.

== [Q3] 기본키는 NULL·중복 불가, 대체키(UNIQUE)는 중복 불가·NULL 허용(Oracle)
INSERT INTO m01_student VALUES (NULL, 'e@u.ac', '최다섯', DATE '2004-01-01', 'DB')
                                *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."M01_STUDENT"."STU_NO")

INSERT INTO m01_student VALUES ('S005', 'a@u.ac', '최다섯', DATE '2004-01-01', 'DB')
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.UQ_M01_STUDENT_EMAIL) violated

1 row created.

ROWS_NOW
5

1 row selected.

Rollback complete.

== [Q4] 인조 식별자: 업무 의미가 없는 일련번호. Oracle 12c+ IDENTITY 컬럼

PL/SQL procedure successfully completed.

Table created.

1 row created.

1 row created.

ORDER_ID|CUST|ORDERED
1|kim|2024-01-01
2|kim|2024-01-01

2 rows selected.

(본질 식별자 (cust, ordered) 로는 같은 날 두 번 주문을 구별할 수 없어 인조 식별자를 쓴 예)

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_keys_sqlserver.sql -->
```text
(4 rows affected)
== [Q1] 유일성 검사
attr|dup_groups
----|----------
stu_no|0
email|0
name|1
birth|1
name+birth|0
stu_no+name|0

(6 rows affected)
== [Q2] PK 와 대체키(UNIQUE) 지정 (SQL Server 는 PK 컬럼이 미리 NOT NULL 이어야 한다)
== [Q3] PK·대체키 위반
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 2
Cannot insert the value NULL into column 'stu_no', table 'SQLD_LAB.dbo.m01_student'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 1
Violation of UNIQUE KEY constraint 'uq_m01_student_email'. Cannot insert duplicate key in object 'dbo.m01_student'. The duplicate key value is (a@u.ac).
The statement has been terminated.

(1 rows affected)
rows_now
--------
5

(1 rows affected)
== [Q4] 인조 식별자: IDENTITY

(2 rows affected)
order_id|cust|ordered
--------|----|-------
1|kim|2024-01-01
2|kim|2024-01-01

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: stu_no·email·name+birth·stu_no+name이 0이다. name·birth는 각각 중복(김하나 2명, 2004-03-01 3명). stu_no+name은 stu_no만으로 유일하므로 최소성을 어긴 슈퍼키다. name+birth는 지금은 유일하지만 업무상 키가 아니다.
* Q3: PK NULL 거부, 대체키 중복 거부. 대체키 NULL은 허용(S006 입력 → 5행). SQL Server는 UNIQUE에 NULL을 한 번만 허용한다(13단원 ex05).
* Q4: 같은 날 같은 고객이 두 번 주문하는 업무에서는 본질 식별자 (cust, ordered)로 구별할 수 없어 인조 식별자를 쓴다. Oracle IDENTITY(12c+), SQL Server IDENTITY.

## F. 변형 문제
1. 학번이 4년마다 재사용된다면 학번은 여전히 후보키인가? 무엇을 더해야 하는가?
2. 인조 식별자만 PK로 두고 본질 식별자에 UNIQUE를 걸지 않으면 어떤 문제가 생기는가?

G: [../exercises/ex04_keys.md](../exercises/ex04_keys.md)
