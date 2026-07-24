---
type: concept
pilot: true
origin:
  - current-map
---

# OUTER JOIN

## 한 줄 정의

조인 조건에 일치하지 않는 행도 포함하며, 매칭되지 않는 반대편 열은 NULL로 채우는 [[JOIN]] 방식이다.

## 핵심 규칙

- LEFT OUTER JOIN: 왼쪽 테이블 전체를 유지한다.
- RIGHT OUTER JOIN: 오른쪽 테이블 전체를 유지한다.
- FULL OUTER JOIN: 양쪽 전체를 유지한다(LEFT와 RIGHT 결과의 합집합).
- 불일치로 채워진 [[NULL]] 값은 [[COUNT]](열)에서 제외되는 등 이후 집계 결과에 영향을 준다.

## Related Concepts

- [[JOIN]]
- [[NULL]]
- [[COUNT]]

## Source

- SQL 기본.md — 5. FROM 절(JOIN, OUTER JOIN)
