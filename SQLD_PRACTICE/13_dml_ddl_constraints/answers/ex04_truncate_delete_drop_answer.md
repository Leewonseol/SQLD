# ex04 정답 (H)
| 경우 | Oracle | SQL Server(자동 커밋) | 이유 |
|---|---|---|---|
| (1) DELETE; ROLLBACK | 3 | 0 | Oracle은 DML을 트랜잭션으로 묶어 ROLLBACK 할 수 있다. SQL Server 자동 커밋 모드에서는 DELETE가 바로 확정되고, ROLLBACK은 Msg 3903 |
| (2) TRUNCATE; ROLLBACK | 0 | 0 | Oracle은 DDL 자동 커밋. SQL Server는 자동 커밋 모드라 확정 |
| (3) BEGIN TRAN; TRUNCATE; ROLLBACK | — | 3 | SQL Server는 명시적 트랜잭션 안의 TRUNCATE를 되돌린다 |
| (4) DELETE; CREATE TABLE; ROLLBACK | 0 | — | CREATE TABLE(DDL) 직전에 암묵적 커밋이 일어나 DELETE가 확정된다 |

검증: (1)(2)(4)는 `14_transactions_permissions/examples/ex01_tcl_*.sql`과 13단원 ex04 실행 결과로 확인한다. (3)은 14단원 ex01 Q4(SQL Server)에서 확인한다.
