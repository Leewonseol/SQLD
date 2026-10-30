# ex06 선언적 제약조건만으로 구현할 수 없는 업무 규칙

> 근거: 요구목록 §6("DBMS 제약조건만으로 구현할 수 없는 업무 규칙은 구현 가능하다고 가정하지 말고 별도로 설명") · 데이터: M01_LOAN6(업무 규칙 R5·R6, 학습용 가상) · 처리 방식: 설계 + DDL·INSERT 실행 검증 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 업무 규칙 | 범위 | 선언적 제약 | 대안 |
|---|---|---|---|
| R5 반납일 ≥ 대출일 | 한 행 | **CHECK 가능** | — |
| R6 회원당 미반납 대출 ≤ 3 | 여러 행(같은 테이블) | 불가(CHECK에 서브쿼리 불가) | 트리거, 응용 로직, (Oracle) 구체화 뷰+제약 등 |
| R10 도서는 소장본 ≥ 1 | 부모–자식(부모 쪽 필수) | 불가 | 트리거, 같은 트랜잭션에서 함께 등록, 지연 제약 + 상호 참조 |
| 등급별 대출 한도(우수 5권) | 여러 테이블 | 불가 | 트리거 |
| 순환 추천 금지 | 여러 행 경로 | 불가 | 트리거(재귀 조회) |
* 트리거도 완전하지 않다. 서로 다른 두 세션이 동시에 4번째 대출을 넣으면 각 트리거가 상대의 미커밋 행을 보지 못해 둘 다 통과할 수 있다. 회원 행 잠금(SELECT … FOR UPDATE / UPDLOCK) 같은 직렬화가 필요하다. **동시성 시나리오는 실행하지 않았다(미실행·설계 검토).**

## B. 입력 데이터
M01_LOAN6(업무 규칙 R5·R6, 학습용 가상). 예제 SQL 안에서 테이블(M01_*)을 만들고 끝나면 지운다.

## C. 실행 SQL
[Oracle](ex06_unenforceable_rules_oracle.sql) · [SQL Server](ex06_unenforceable_rules_sqlserver.sql)

## D. 결과 예측 문제
1. R5는 CHECK로 막히는가?
2. R6을 CHECK(서브쿼리)로 만들 수 있는가?
3. 트리거가 없을 때 4번째 대출은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_unenforceable_rules_oracle.sql -->
```text
PL/SQL procedure successfully completed.

Table created.

== [Q1] R5 반납일 >= 대출일: 한 행 안의 조건 -> CHECK 로 구현된다
INSERT INTO m01_loan6 VALUES (1, 7, DATE '2024-03-10', DATE '2024-03-01')
*
ERROR at line 1:
ORA-02290: check constraint (SQLD_LAB.CK_M01_LOAN6_DT) violated

== [Q2] R6 '회원당 미반납 대출 최대 3권': 여러 행을 세야 한다 -> CHECK 안에 서브쿼리 불가
ALTER TABLE m01_loan6 ADD CONSTRAINT ck_m01_loan6_max3 CHECK ((SELECT COUNT(*) FROM m01_loan6 x WHERE x.member_id = member_id AND x.return_dt IS NULL) <= 3)
                                                               *
ERROR at line 1:
ORA-02251: subquery not allowed here

== [Q3] 그래서 제약조건만 있으면 4번째 대출이 그대로 들어간다

1 row created.

1 row created.

1 row created.

1 row created.

MEMBER_ID|OPEN_LOANS
7|4

1 row selected.

Rollback complete.

== [Q4] 대안: 트리거(절차적 구현). 문장 단위 AFTER 트리거로 위반 시 오류

Trigger created.

1 row created.

1 row created.

1 row created.

INSERT INTO m01_loan6 VALUES (24, 8, DATE '2024-03-01', NULL)
            *
ERROR at line 1:
ORA-20006: R6 위반: 미반납 대출은 회원당 최대 3권 ORA-06512: at
"SQLD_LAB.TRG_M01_LOAN6_MAX3", line 4
ORA-04088: error during execution of trigger 'SQLD_LAB.TRG_M01_LOAN6_MAX3'

MEMBER_ID|OPEN_LOANS
8|3

1 row selected.

(주의: 트리거는 동시에 들어오는 두 세션의 INSERT 를 서로 보지 못해 둘 다 통과할 수 있다. 잠금·직렬화가 필요하다 - 미실행 설명)

Rollback complete.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_unenforceable_rules_sqlserver.sql -->
```text
== [Q1] R5 CHECK
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 2
The INSERT statement conflicted with the CHECK constraint "ck_m01_loan6_dt". The conflict occurred in database "SQLD_LAB", table "dbo.m01_loan6".
The statement has been terminated.
== [Q2] CHECK 안에 서브쿼리 -> 오류
Msg 1046, Level 15, State 1, Server a70f428a7f8a, Line 2
Subqueries are not allowed in this context. Only scalar expressions are allowed.
== [Q3] 제약만으로는 4번째 대출이 들어간다

(4 rows affected)
member_id|open_loans
---------|----------
7|4

(1 rows affected)
== [Q4] 대안: AFTER 트리거

(3 rows affected)
Msg 50006, Level 16, State 1, Server a70f428a7f8a, Procedure trg_m01_loan6_max3, Line 5
R6 위반: 미반납 대출은 회원당 최대 3권
member_id|open_loans
---------|----------
8|3

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 CHECK 위반으로 거부(ORA-02290 / Msg 547). return_dt가 NULL(미반납)이면 CHECK는 UNKNOWN이라 통과한다. 이것이 '반납 전에는 비어 있다'를 허용한다.
* Q2: CHECK 안의 서브쿼리 → ORA-02251 / Msg 1046.
* Q3: 4건 모두 들어간다(open_loans 4).
* Q4: 트리거가 4번째에서 오류(ORA-20006 / Msg 50006)를 내고 그 문장을 취소해 3건이 유지된다. Oracle은 행 단위 트리거에서 같은 테이블을 조회하면 ORA-04091(mutating table)이 나므로 **문장 단위** AFTER 트리거로 작성했다.

## F. 변형 문제
1. 등급별 대출 한도(일반 3, 우수 5)를 트리거로 바꾸려면 어떤 테이블을 조인해야 하는가?
2. R10을 '도서 등록 프로시저' 하나로만 등록하게 하는 방식과 트리거 방식의 장단점을 비교하라.

G: [../exercises/ex06_unenforceable_rules.md](../exercises/ex06_unenforceable_rules.md)
