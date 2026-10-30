# ex01 정답 (H)
G1. (1) INSERT — DML (2) ALTER TABLE ... ADD — DDL (3) GRANT SELECT ON emp TO u2 — DCL (4) SAVEPOINT — TCL
    (5) TRUNCATE TABLE — DDL (6) MERGE — DML
G2. Oracle: TRUNCATE는 DDL이라 실행 전후로 자동 커밋된다. ROLLBACK 해도 행이 돌아오지 않는다.
    SQL Server: 명시적 트랜잭션(BEGIN TRAN) 안의 TRUNCATE는 ROLLBACK 하면 되돌아간다.
    두 결과 모두 `14_transactions_permissions/examples/ex01_tcl_*.sql`에서 실행으로 확인한다.
검증 방식: 분류 문제라 자동 검증 SQL이 없다. 동작 차이는 14단원 실행 결과로 검증한다.
