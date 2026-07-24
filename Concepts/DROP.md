---
type: concept
pilot: true
origin:
  - current-map
---

# DROP

## 한 줄 정의

테이블 객체 자체(구조+데이터)를 삭제하는 [[DDL]] 명령이다.

## 핵심 규칙

- 실행 후 테이블 자체가 존재하지 않게 된다.
- 일반적으로 ROLLBACK이 불가능하다.
- CASCADE CONSTRAINTS 옵션으로 참조 제약조건도 함께 삭제할 수 있다.
- [[DELETE]]·[[TRUNCATE]]와 달리 테이블 구조까지 완전히 없앤다는 점이 가장 큰 차이다.

## Related Concepts

- [[DELETE]]
- [[TRUNCATE]]
- [[DDL]]

## Source

- SQL 관리 구문.md — 3. DDL(DROP, 삭제 명령 비교)
