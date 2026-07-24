---
type: concept
pilot: true
origin:
  - current-map
---

# Transaction

## 한 줄 정의

하나 이상의 SQL 문을 묶은 논리적 작업 단위이며, 전부 성공하거나 전부 취소된다.

## 핵심 규칙

- 명시적 트랜잭션: BEGIN TRANSACTION 후 [[COMMIT]]/[[ROLLBACK]]으로 직접 종료한다.
- 묵시적 트랜잭션: DML 실행 시 자동 시작되며 COMMIT/ROLLBACK 전까지 유지된다.
- [[ACID]] 속성(원자성/일관성/고립성/지속성)을 지켜야 한다.
- LOCK은 COMMIT 또는 ROLLBACK 시 해제된다.

## Related Concepts

- [[COMMIT]]
- [[ROLLBACK]]
- [[ACID]]

## Source

- SQL 관리 구문.md — 2. TCL(트랜잭션)
