# ex02 트랜잭션 격리 수준과 동시성

> 근거: 요구목록 §7(COMMIT·ROLLBACK·SAVEPOINT 확장). **추출본에 격리 수준·ACID 본문 없음** · 데이터: D14_ISO, D14_CC(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **ACID**: 원자성(전부 아니면 전무), 일관성(제약을 지키는 상태 → 상태), 고립성(동시 트랜잭션의 간섭 차단), 지속성(커밋된 결과는 영구).
* 고립성이 약할 때의 현상: **Dirty Read**(커밋 안 된 값 읽기), **Non-Repeatable Read**(같은 행을 다시 읽으면 값이 다름), **Phantom Read**(같은 조건을 다시 조회하면 행이 늘거나 줆).

| ANSI 격리 수준 | Dirty | Non-Repeatable | Phantom | Oracle | SQL Server |
|---|---|---|---|---|---|
| READ UNCOMMITTED | 가능 | 가능 | 가능 | 미지원(ORA-02179) | 지원 |
| READ COMMITTED | 방지 | 가능 | 가능 | **기본**(다중 버전) | **기본**(잠금, RCSI OFF) |
| REPEATABLE READ | 방지 | 방지 | 가능 | 미지원 | 지원 |
| SERIALIZABLE | 방지 | 방지 | 방지 | 지원 | 지원 |
* 같은 READ COMMITTED여도 **구현이 다르다.** Oracle은 언두로 이전 커밋 버전을 읽어 기다리지 않는다. SQL Server(READ_COMMITTED_SNAPSHOT OFF)는 공유 잠금 때문에 쓰기 트랜잭션이 끝날 때까지 기다린다.

## B. 입력 데이터
D14_ISO, D14_CC(학습용 가상 데이터)

## C. 실행 SQL
[Oracle](ex02_isolation_oracle.sql) · [SQL Server](ex02_isolation_sqlserver.sql)

## D. 결과 예측 문제
1. 다른 세션이 999로 바꾸고 아직 커밋하지 않았을 때, Oracle(READ COMMITTED), SQL Server(READ UNCOMMITTED), SQL Server(READ COMMITTED)는 각각 무엇을 읽고 얼마나 기다리는가?
2. Oracle에서 READ UNCOMMITTED를 설정하면?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_isolation_oracle.sql -->
```text
PL/SQL procedure successfully completed.

Table created.

1 row created.

Commit complete.

== [Q1] Oracle 이 지원하는 격리 수준: READ COMMITTED(기본), SERIALIZABLE, 그리고 READ ONLY 트랜잭션

Transaction set.

V
100

1 row selected.

Commit complete.

== [Q2] READ UNCOMMITTED 는 지원하지 않는다 -> 오류
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
                                     *
ERROR at line 1:
ORA-02179: valid options: ISOLATION LEVEL { SERIALIZABLE | READ COMMITTED }

== [Q3] READ ONLY 트랜잭션에서 DML -> 오류

Transaction set.

UPDATE d14_iso SET v = 1
       *
ERROR at line 1:
ORA-01456: may not perform insert/delete/update operation inside a READ ONLY transaction

Commit complete.

== [Q4] SET TRANSACTION 은 트랜잭션의 첫 문장이어야 한다 -> DML 뒤에 쓰면 오류

1 row updated.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
*
ERROR at line 1:
ORA-01453: SET TRANSACTION must be first statement of transaction

Rollback complete.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_isolation_sqlserver.sql -->
```text
(1 rows affected)
== [Q1] 세션 격리 수준 바꾸기: 1 READ UNCOMMITTED, 2 READ COMMITTED(기본), 3 REPEATABLE READ, 4 SERIALIZABLE, 5 SNAPSHOT
lvl
---
1

(1 rows affected)
lvl
---
3

(1 rows affected)
lvl
---
4

(1 rows affected)
lvl
---
2

(1 rows affected)
== [Q2] 이 DB 의 READ COMMITTED 는 잠금 방식인가(0) 스냅숏 방식인가(1)? 스냅숏 격리 허용 여부는?
is_read_committed_snapshot_on|snapshot_isolation_state_desc
-----------------------------|-----------------------------
0|OFF

(1 rows affected)
== [Q3] ALLOW_SNAPSHOT_ISOLATION 이 꺼진 DB 에서 SNAPSHOT 트랜잭션으로 데이터 접근 -> 오류
Msg 3952, Level 16, State 1, Server a70f428a7f8a, Line 2
Snapshot isolation transaction failed accessing database 'SQLD_LAB' because snapshot isolation is not allowed in this database. Use ALTER DATABASE to allow snapshot isolation.
```
<!-- /RESULT -->

**이유**
* 단일 세션 스크립트: Oracle은 SERIALIZABLE·READ ONLY를 설정할 수 있다. READ UNCOMMITTED는 ORA-02179, READ ONLY 트랜잭션의 DML은 ORA-01456, DML 뒤의 SET TRANSACTION은 ORA-01453이다. SQL Server는 수준 번호 1·3·4·2가 차례로 바뀌었다. 이 DB는 RCSI OFF, 스냅숏 격리 OFF라 SNAPSHOT 접근이 Msg 3952다.
* **두 세션 실험**(`python3 tools/concurrency_demo.py`, 결과 [../expected_results/ex02_concurrency_demo.txt](../expected_results/ex02_concurrency_demo.txt))
  * Oracle READ COMMITTED: 1.0초에 읽기 시작해 0.2초 만에 **100**(이전 커밋 값). 기다리지 않는다.
  * SQL Server READ UNCOMMITTED: 0.1초 만에 **999**(커밋되지 않은 값 = Dirty Read). 그 뒤 쓰기 세션은 ROLLBACK 했으므로 999는 "존재한 적 없는" 값이다.
  * SQL Server READ COMMITTED: **3.1초 대기**한 뒤(쓰기 세션 ROLLBACK 시점) 100을 읽었다.
* Non-Repeatable·Phantom 현상은 실행하지 않았다(미실행). 같은 도구에 시나리오를 추가해 확인할 수 있다.

## F. 변형 문제
1. SQL Server에서 `ALTER DATABASE SQLD_LAB SET READ_COMMITTED_SNAPSHOT ON` 뒤에 세 번째 시나리오를 다시 실행하면 결과가 어떻게 바뀔지 예측하라(미실행 — DB 설정 변경이 필요하다).
2. Phantom Read를 재현하는 두 세션 시나리오를 설계하라.

G: [../exercises/ex02_isolation.md](../exercises/ex02_isolation.md)
