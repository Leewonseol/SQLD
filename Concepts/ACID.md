---
type: concept
pilot: true
origin:
  - current-map
---

# ACID

## 한 줄 정의

[[Transaction]]이 지켜야 할 4가지 속성(원자성·일관성·고립성·지속성)이다.

## 핵심 규칙

- Atomicity(원자성): 트랜잭션의 작업이 전부 성공하거나 전부 실패해야 한다(All or Nothing).
- Consistency(일관성): 실행 전후 DB의 규칙·제약조건이 유지되어야 한다.
- Isolation(고립성): 동시에 수행되는 트랜잭션 간 간섭을 방지한다.
- Durability(지속성): COMMIT 결과는 영구 보존된다.

## Related Concepts

- [[Transaction]]

## Source

- SQL 관리 구문.md — 2. TCL(ACID)
