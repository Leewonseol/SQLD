# ex05 자기 자신과의 관계(순환 관계)

> 근거: PDF추출본 E-02("자기 자신끼리의 관계 - 하나의 엔터티 내에서 인스턴스끼리 계층 구조"), E-03("FK는 자기 자신이 속한 릴레이션을 참조할 수 있다. ex) 멘토") · 데이터: M01_MEM(업무 규칙 R8, 학습용 가상) · 처리 방식: 설계 + DDL·INSERT 실행 검증 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 한 엔터티의 인스턴스가 같은 엔터티의 다른 인스턴스와 관계를 맺는다(사원–관리자, 회원–추천인, 멘티–멘토). 순환 관계(재귀 관계)라고도 한다.
* 구현: 자기 테이블 PK를 참조하는 FK(NULL 허용 = 최상위/추천인 없음).
* 제약으로 구현되는 것: '추천인은 존재하는 회원'(FK), '자기 자신은 안 됨'(행 안의 CHECK).
* 제약으로 구현되지 **않는** 것: 'A→B→C→A 같은 순환 금지', '최대 깊이 3단계'. 여러 행을 따라가야 하는 조건이다.
* 조회: 한 단계는 셀프 조인(04단원 ex07), 여러 단계는 계층형 질의(12단원).

## B. 입력 데이터
M01_MEM(업무 규칙 R8, 학습용 가상). 예제 SQL 안에서 테이블(M01_*)을 만들고 끝나면 지운다.

## C. 실행 SQL
[Oracle](ex05_self_relationship_oracle.sql) · [SQL Server](ex05_self_relationship_sqlserver.sql)

## D. 결과 예측 문제
1. 존재하지 않는 회원 99를 추천인으로 넣으면? 자기 자신(5→5)은?
2. Q3 UPDATE 뒤 1→3→2→1 순환이 생기는가? 제약이 막는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_self_relationship_oracle.sql -->
```text
PL/SQL procedure successfully completed.

Table created.

== [Q1] 자기참조 FK: 추천인은 존재하는 회원이어야 한다 (NULL = 추천인 없음, 선택 관계)

1 row created.

1 row created.

1 row created.

INSERT INTO m01_mem VALUES (4, 'D', 99)
*
ERROR at line 1:
ORA-02291: integrity constraint (SQLD_LAB.FK_M01_MEM_REC) violated - parent key not found

== [Q2] '자기 자신을 추천할 수 없다'는 한 행 안의 조건 -> CHECK 로 구현 가능
INSERT INTO m01_mem VALUES (5, 'E', 5)
*
ERROR at line 1:
ORA-02290: check constraint (SQLD_LAB.CK_M01_MEM_NOT_SELF) violated

== [Q3] 'A 가 C 를 추천 -> 순환(A->C->B->A)' 같은 여러 행에 걸친 순환 금지는 CHECK·FK 로 막지 못한다

1 row updated.

MEMBER_ID|RECOMMENDER_ID
1|3
2|1
3|2

3 rows selected.

== [Q4] 순환 여부는 조회로 '탐지'만 할 수 있다 (12단원 NOCYCLE)

MEMBER_ID|LVL|IS_CYCLE
1|1|0
3|2|0
2|3|1

3 rows selected.

Rollback complete.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_self_relationship_sqlserver.sql -->
```text
== [Q1] 자기참조 FK

(3 rows affected)
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 2
The INSERT statement conflicted with the FOREIGN KEY SAME TABLE constraint "fk_m01_mem_rec". The conflict occurred in database "SQLD_LAB", table "dbo.m01_mem", column 'member_id'.
The statement has been terminated.
== [Q2] 자기 자신 추천 금지 CHECK
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the CHECK constraint "ck_m01_mem_not_self". The conflict occurred in database "SQLD_LAB", table "dbo.m01_mem".
The statement has been terminated.
== [Q3] 여러 행에 걸친 순환은 막지 못한다

(1 rows affected)
member_id|recommender_id
---------|--------------
1|3
2|1
3|2

(3 rows affected)
== [Q4] 순환 탐지(재귀 CTE, 경로에 이미 있으면 멈춤)
member_id|lvl|path
---------|---|----
1|1|/1/
3|2|/1/3/
2|3|/1/3/2/

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 FK 위반, Q2 CHECK 위반(ORA-02290 / Msg 547).
* Q3: UPDATE가 성공해 순환이 생겼다. **선언적 제약으로 막지 못한다.**
* Q4: CONNECT BY NOCYCLE로 3단계에서 순환을 탐지했다(IS_CYCLE 1). SQL Server는 경로 문자열로 같은 경로를 구했다.

## F. 변형 문제
1. 순환을 막는 트리거를 설계하라(갱신 후 재귀 조회로 자기 자신에 도달하면 오류).
2. '추천인은 같은 등급이어야 한다'는 제약으로 구현할 수 있는가?

G: [../exercises/ex05_self_relationship.md](../exercises/ex05_self_relationship.md)
