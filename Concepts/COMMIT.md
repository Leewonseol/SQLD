---
type: concept
pilot: true
origin:
  - current-map
---

# COMMIT

## 한 줄 정의

[[Transaction]]의 변경 내용을 DB에 영구 반영하는 명령이다.

## 핵심 규칙

- COMMIT 이후에는 [[ROLLBACK]]으로 되돌릴 수 없다.
- COMMIT 이후에는 다른 사용자도 변경 결과를 조회할 수 있다.
- [[DDL]] 실행 시 Oracle에서는 자동으로 COMMIT이 발생한다([[AUTO COMMIT]]).

## Related Concepts

- [[ROLLBACK]]
- [[Transaction]]
- [[AUTO COMMIT]]

## Source

- SQL 관리 구문.md — 2. TCL(COMMIT)
