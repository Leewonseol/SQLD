---
type: concept
pilot: true
origin:
  - current-map
---

# DDL

## 한 줄 정의

테이블·뷰 등 객체와 구조를 정의·변경·삭제하는 명령어군(CREATE/ALTER/DROP/RENAME/TRUNCATE)이다.

## 핵심 규칙

- CREATE: 객체(TABLE, VIEW) 생성
- ALTER: 기존 객체 구조 변경
- DROP: 객체 자체(구조+데이터) 삭제
- Oracle에서 DDL을 실행하면 자동으로 [[AUTO COMMIT]]이 발생해, 그 이전의 [[DML]] 변경 사항까지 함께 확정된다.

## Related Concepts

- [[AUTO COMMIT]]
- [[ROLLBACK]]

## Source

- SQL 관리 구문.md — 3. DDL
