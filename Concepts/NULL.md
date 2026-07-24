---
type: concept
pilot: true
origin:
  - current-map
---

# NULL

## 한 줄 정의

값이 존재하지 않는 상태를 나타내며, 연산·비교·집계에서 일반 값과 다르게 취급된다.

## 핵심 규칙

- [[PK]] 컬럼은 NULL을 저장할 수 없다.
- NULL은 = 연산자로 비교할 수 없다(IS NULL / IS NOT NULL 사용).
- NULL이 포함된 산술 연산의 결과는 NULL이다.

## Related Concepts

- [[PK]]
- [[제약조건]]
- [[개체 무결성]]

## Source

- 데이터 모델링.md — 9. 식별자(주식별자 특징: 존재성(NULL 불가))
- SQL 관리 구문.md — 3. DDL 제약조건(PRIMARY KEY: NULL X)
- SQL 기본.md — 6. WHERE절(NULL 조건), 2. SELECT절(산술 연산에 NULL 포함 시 결과도 NULL)
