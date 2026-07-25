[← 이전](./02-DML-행조작.md) | [목차](./README.md) | [다음 →](./04-SELECT-작성순서-실행순서.md)

# DCL과 TCL: 권한과 트랜잭션은 다르다

## 핵심 질문

> DCL: 누가 무엇을 할 수 있는가?
> TCL: 수행한 데이터 변경 작업을 어떻게 할 것인가?

## 분기표

DCL:

```text
권한을 어떻게 통제하는가?
│
├─ 권한을 부여한다
│  └─ GRANT
│
├─ 권한을 회수한다
│  └─ REVOKE
│
└─ 여러 권한을 묶어 관리한다
   └─ ROLE
```

TCL:

```text
수행한 데이터 변경 작업을 어떻게 할 것인가?
│
├─ 확정한다
│  └─ COMMIT
│
├─ 취소한다
│  └─ ROLLBACK
│
└─ 중간 복구 지점을 만든다
   └─ SAVEPOINT
```

## 핵심 개념 표

> **트랜잭션은 하나의 논리적 업무를 완성하기 위해 함께 처리되는 데이터 변경 작업의
> 묶음이다.**

```text
DML 실행
→ 작업 단위 형성
→ COMMIT 또는 ROLLBACK
```

계좌이체 예시:

1. A 계좌에서 금액을 차감한다.
2. B 계좌에 금액을 추가한다.
3. 둘 다 성공하면 `COMMIT`한다.
4. 하나라도 실패하면 `ROLLBACK`한다.

DCL과 TCL 비교:

| 구분 | 핵심 대상 | 질문 |
|---|---|---|
| DCL | 사용자·역할의 권한 | 누가 무엇을 할 수 있는가? |
| TCL | 데이터 변경 작업 묶음 | 작업을 확정·취소할 것인가? |

관련 개념 구분:

| 항목 | 성격 |
|---|---|
| COMMIT | TCL 명령어 |
| ROLLBACK | TCL 명령어 |
| SAVEPOINT | TCL 명령어 |
| TRANSACTION | DBMS별 트랜잭션 경계 구문에 사용되는 키워드·개념 |
| 명시적 트랜잭션 | 실행 방식 |
| 묵시적 트랜잭션 | 실행 방식 |
| AUTO COMMIT | 자동 확정 설정·방식 |

## 최소 SQL 예시

```sql
-- DCL
GRANT SELECT, INSERT ON EMP TO USER1;
REVOKE INSERT ON EMP FROM USER1;

-- TCL (Oracle)
SAVEPOINT SV1;
UPDATE EMP SET SAL = SAL * 1.1;
ROLLBACK TO SV1;
COMMIT;

-- TCL (SQL Server)
SAVE TRANSACTION SV1;
UPDATE EMP SET SAL = SAL * 1.1;
ROLLBACK TRANSACTION SV1;
COMMIT;
```

## 시험 함정

- Oracle은 일반적으로 첫 DML 실행으로 트랜잭션이 묵시적으로 시작된다.
- SQL Server는 `BEGIN TRANSACTION`으로 명시적으로 트랜잭션을 시작할 수 있다.
- **AUTO COMMIT은 TCL 명령어가 아니다** — COMMIT 여부를 결정하는 DBMS의 동작 설정이다.
- Oracle은 DML을 기본적으로 자동 커밋하지 않지만, DDL을 실행하면 자동 커밋된다.
- SQL Server는 기본이 AUTO COMMIT이며, `BEGIN TRANSACTION`으로 수동 제어로 전환할 수 있다.
- SAVEPOINT 문법은 DBMS마다 다르다(Oracle `SAVEPOINT`/`ROLLBACK TO`, SQL Server
  `SAVE TRANSACTION`/`ROLLBACK TRANSACTION`).

## 상세 학습

- [Concepts/DCL.md](<../Concepts/DCL.md>)
- [Concepts/Transaction.md](<../Concepts/Transaction.md>)
- [Concepts/COMMIT.md](<../Concepts/COMMIT.md>)
- [Concepts/ROLLBACK.md](<../Concepts/ROLLBACK.md>)
- [Concepts/AUTO COMMIT.md](<../Concepts/AUTO COMMIT.md>)
- [깨우침/관리구문 구조.md](<../깨우침/관리구문 구조.md>)
- [_원본 자료/SQL 관리 구문.md](<../_원본 자료/SQL 관리 구문.md>) — SAVEPOINT, ACID, LOCK, 격리 수준
- [Questions/M01-Q40.md](<../Questions/M01-Q40.md>) — DDL 자동 커밋과 ROLLBACK 흐름 추적 기출
- [Questions/M01-Q44.md](<../Questions/M01-Q44.md>) — WITH GRANT OPTION 연쇄 회수 기출
- [Questions/M01-Q45.md](<../Questions/M01-Q45.md>) — WITH GRANT OPTION 연쇄 회수(재확인) 기출
