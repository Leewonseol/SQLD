---
type: concept
pilot: true
origin:
  - current-map
---

# TRUNCATE

## 한 줄 정의

테이블의 모든 행을 삭제하되 테이블 구조는 유지하는 [[DDL]] 명령이다.

## 핵심 규칙

- WHERE절을 사용할 수 없다(전체 삭제만 가능).
- 실행 즉시 자동 COMMIT되어 일반적으로 ROLLBACK이 불가능하다.
- UNDO 로그를 남기지 않아 [[DELETE]]보다 빠르다.

## Related Concepts

- [[DELETE]]
- [[DROP]]
- [[DDL]]

## Source

- SQL 관리 구문.md — 3. DDL(TRUNCATE, 삭제 명령 비교)
