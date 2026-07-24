---
type: concept
pilot: true
origin:
  - current-map
---

# PK

## 한 줄 정의

테이블에서 각 행을 유일하게 식별하는 기본키 제약조건이다.

## 핵심 규칙

- 중복된 값을 허용하지 않는다.
- [[NULL]]을 허용하지 않는다.
- 한 테이블에 하나만 지정할 수 있다(복합키로 여러 컬럼을 묶을 수 있음).

## Related Concepts

- [[NULL]]
- [[제약조건]]
- [[개체 무결성]]
- [[FK]]

## Source

- 데이터 모델링.md — 9. 식별자(주식별자 특징: 유일성/최소성/불변성/존재성)
- SQL 관리 구문.md — 3. DDL 제약조건(PRIMARY KEY: 중복 X, NULL X, 테이블당 하나(복합키 가능))
