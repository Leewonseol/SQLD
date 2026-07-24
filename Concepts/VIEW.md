---
type: concept
pilot: true
origin:
  - current-map
---

# VIEW

## 한 줄 정의

SELECT 문을 저장해 가상 테이블처럼 사용하는 객체다.

## 핵심 규칙

- 실제 행 데이터를 직접 저장하지 않고, 실행할 때 저장된 SELECT를 다시 수행한다.
- 단순 뷰는 DML이 가능하지만, 복합 뷰는 DML이 제한된다.
- 뷰 자체에는 인덱스를 생성할 수 없다.

## Related Concepts

- [[제약조건]]

## Source

- SQL 관리 구문.md — VIEW
