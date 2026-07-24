---
type: concept
pilot: true
origin:
  - current-map
---

# HAVING

## 한 줄 정의

[[GROUP BY]]로 만들어진 그룹을 필터링하는 절이며, GROUP BY 이후·SELECT 이전에 실행된다.

## 핵심 규칙

- [[집계 함수]] 결과를 조건으로 사용할 수 있다는 점에서 [[WHERE]]와 다르다.
- GROUP BY에 명시한 열이나 표현식은 사용할 수 있지만, 그룹화되지 않은 일반 열은 사용할 수 없다.

## Related Concepts

- [[WHERE]]
- [[GROUP BY]]
- [[집계 함수]]

## Source

- SQL 기본.md — 7. GROUP BY(③ HAVING 절)
