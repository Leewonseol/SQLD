# ex01 SQL 문장의 종류 (DML·DDL·DCL·TCL)

> 근거: PDF추출본 E-04 (페이지 미확인) · 처리 방식: **개념 분류 실습**(문장 분류 자체는 실행 결과가 아님) · 각 명령의 실행 실습은 13·14단원

## A. 개념 설명
* **무엇을 하는가**: SQL 명령을 목적에 따라 나눈다.

| 분류 | 명령 | 하는 일 | 트랜잭션 성질 (PDF E-04 / 실행 확인) |
|---|---|---|---|
| DML 데이터 조작어 | SELECT¹, INSERT, UPDATE, DELETE, MERGE | 행을 조회하거나 바꾼다 | 사용자가 COMMIT 해야 확정된다. ROLLBACK 할 수 있다 |
| DDL 데이터 정의어 | CREATE, ALTER, DROP, RENAME, TRUNCATE | 테이블 같은 구조를 정의한다 | PDF: "AUTO COMMIT, ROLLBACK 불가능". **Oracle에서만 그렇다.** SQL Server는 명시적 트랜잭션 안의 DDL을 ROLLBACK 할 수 있다(14단원 ex01에서 실행 확인) |
| DCL 데이터 제어어 | GRANT, REVOKE | 권한을 주고 회수한다 | Oracle은 DDL처럼 자동 커밋한다 |
| TCL 트랜잭션 제어어 | COMMIT, ROLLBACK, SAVEPOINT | 트랜잭션 단위를 제어한다 | — |

¹ PDF는 SELECT를 DML로 분류하면서 "+ DQL(Data Query Language): SELECT"도 함께 적었다. 시험에서는 SELECT를 DML로 분류하는 경우가 일반적이지만, DQL로 따로 묻기도 한다.

* **언제 쓰는가**: 명령이 자동 커밋되는지, 롤백할 수 있는지, 어떤 권한이 필요한지 판단할 때.
* **다른 개념과 차이**: TRUNCATE는 행을 지우지만 DML(DELETE)이 아니라 DDL이다. 그래서 Oracle에서는 ROLLBACK 할 수 없다. MERGE는 DML이다.

## B. 입력 데이터
없음(분류 문제).

## C. 실행 SQL
분류 자체는 실행하지 않는다. 각 분류의 동작은 아래에서 실행한다.
* DML: `13_dml_ddl_constraints/examples/ex01_insert_update_delete_*.sql`
* DDL·TRUNCATE: `13_dml_ddl_constraints/examples/ex04_ddl_*.sql`
* TCL·DDL 자동 커밋: `14_transactions_permissions/examples/ex01_tcl_*.sql`
* DCL: `14_transactions_permissions/examples/ex03_grant_revoke_*.sql`

## D. 결과 예측 문제
다음 명령을 DML/DDL/DCL/TCL로 분류하고, Oracle에서 실행 직후 ROLLBACK 하면 되돌릴 수 있는지 답하라.
`TRUNCATE TABLE t` / `MERGE INTO t ...` / `SAVEPOINT a` / `RENAME t TO t2` / `REVOKE SELECT ON t FROM u` / `SELECT * FROM t`

## E. 정답
| 명령 | 분류 | Oracle ROLLBACK 가능 |
|---|---|---|
| TRUNCATE | DDL | 불가(자동 커밋) |
| MERGE | DML | 가능 |
| SAVEPOINT | TCL | 해당 없음 |
| RENAME | DDL | 불가 |
| REVOKE | DCL | 불가(자동 커밋) |
| SELECT | DML(또는 DQL) | 변경이 없다 |

## F. 변형 문제
1. 같은 표를 SQL Server 기준으로 다시 채워라. (힌트: `BEGIN TRAN; TRUNCATE TABLE t; ROLLBACK;` 이후 행은 되살아난다. 14단원 ex01에서 확인)
2. Oracle에서 `INSERT` 다음에 `CREATE TABLE`을 실행하고 `ROLLBACK` 하면 INSERT는 어떻게 되는가? (암묵적 커밋. 14단원 ex01 Q3)

G(직접 작성): [exercises/ex01_sql_statement_types.md](../exercises/ex01_sql_statement_types.md)
