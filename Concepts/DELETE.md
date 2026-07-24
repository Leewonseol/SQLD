---
type: concept
pilot: true
origin:
  - current-map
---

# DELETE

## 한 줄 정의

WHERE 조건에 맞는 행을 삭제하는 [[DML]] 명령이다.

## 핵심 규칙

- WHERE절로 삭제할 행을 선택할 수 있으며, 생략하면 모든 행이 삭제된다.
- 테이블 구조는 유지된다.
- DML이므로 [[ROLLBACK]]으로 복구할 수 있다.
- [[TRUNCATE]]·[[DROP]]과 함께 삭제 명령 3종 세트를 이룬다.

## Related Concepts

- [[TRUNCATE]]
- [[DROP]]
- [[ROLLBACK]]

## Source

- SQL 관리 구문.md — 1. DML(DELETE), 3. DDL(삭제 명령 비교)
