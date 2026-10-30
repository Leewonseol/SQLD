# 14 트랜잭션(TCL)과 권한(DCL) — 단원 안내 (별도 학습 분기)

PDF E-04 분류: TCL = COMMIT·ROLLBACK·SAVEPOINT, DCL = GRANT·REVOKE. DML은 사용자가 COMMIT 해야 확정되고, DDL은 자동 커밋된다(PDF).
**이 "DDL 자동 커밋"은 Oracle의 동작이다.** SQL Server는 DDL도 명시적 트랜잭션 안에서 ROLLBACK 된다. 두 DBMS의 차이가 가장 큰 단원이다.

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_tcl.md) | COMMIT·ROLLBACK·SAVEPOINT, 자동 커밋, DDL과 트랜잭션, 문장 단위 롤백 | PDF E-04 |
| [ex02](examples/ex02_isolation.md) | 격리 수준, 두 세션 동시성 실험(Dirty Read·블로킹·읽기 일관성) | §7(추출본 미확인) |
| [ex03](examples/ex03_grant_revoke.md) | GRANT·REVOKE·ROLE·WITH GRANT OPTION·DENY | PDF E-04 |

## 실행으로 확인한 차이 (Oracle 21c / SQL Server 2022)
| 항목 | Oracle | SQL Server |
|---|---|---|
| 트랜잭션 시작 | 첫 DML에서 자동 시작, COMMIT/ROLLBACK까지 | 기본은 **자동 커밋**(문장마다 확정). BEGIN TRAN으로 묶음. `SET IMPLICIT_TRANSACTIONS ON`이면 Oracle처럼 동작 |
| 저장점 | SAVEPOINT s / ROLLBACK TO [SAVEPOINT] s | SAVE TRANSACTION s / ROLLBACK TRANSACTION s |
| DDL | 실행 전 암묵적 COMMIT. **실패한 DDL(ORA-00955)도 앞의 INSERT를 커밋했다** | 트랜잭션 안의 CREATE TABLE·TRUNCATE도 ROLLBACK 된다 |
| 트랜잭션 없는 ROLLBACK | 아무 일도 없음 | Msg 3903 |
| 오류 문장 | 그 문장만 취소(문장 단위 롤백) | 기본도 같다. `SET XACT_ABORT ON`이면 트랜잭션 전체 롤백 |
| 중첩 BEGIN TRAN | 개념 없음 | 안쪽 COMMIT은 @@TRANCOUNT만 감소, ROLLBACK은 전부 취소 |
| 격리 수준 | READ COMMITTED(기본), SERIALIZABLE, READ ONLY. READ UNCOMMITTED는 ORA-02179 | READ UNCOMMITTED·READ COMMITTED·REPEATABLE READ·SERIALIZABLE·SNAPSHOT |
| 커밋 안 된 행을 다른 세션이 읽기 | **기다리지 않고 이전 커밋 값**(다중 버전 읽기 일관성) | READ COMMITTED(기본, RCSI OFF)는 **잠금 대기**. READ UNCOMMITTED는 **Dirty Read** |
| 권한 없는 객체 조회 | ORA-00942(존재 자체를 숨김) | Msg 229(권한 거부) |
| WITH GRANT OPTION 회수 | 재부여된 객체 권한까지 **자동 연쇄 회수** | CASCADE 없이 REVOKE하면 Msg 4611, `REVOKE … CASCADE` |
| DENY | 없음 | 있음(역할로 받은 GRANT보다 우선) |
