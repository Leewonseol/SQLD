---
type: concept
pilot: true
origin:
  - current-map
---

# ROLLBACK

## 한 줄 정의

[[Transaction]]에서 변경된 내용을 마지막 COMMIT 시점으로 되돌리는 명령이다.

## 핵심 규칙

- ROLLBACK은 마지막 COMMIT 이후의 변경 내용만 취소하며, 이미 COMMIT된 내용은 되돌릴 수 없다.
- SAVEPOINT까지만 부분적으로 되돌릴 수도 있다.
- [[DDL]] 실행 직후(Oracle 기준 자동 COMMIT 발생 후)에는 그 이전 DML까지 함께 확정되어 ROLLBACK으로 되돌릴 수 없다.

## Related Concepts

- [[Transaction]]
- [[DDL]]

## Source

- SQL 관리 구문.md — 2. TCL(ROLLBACK)
