---
type: concept
pilot: true
origin:
  - current-map
---

# WHERE

## 한 줄 정의

행 단위로 조건을 걸어 필터링하는 절이며, [[GROUP BY]]보다 먼저 실행된다.

## 핵심 규칙

- 조건이 TRUE인 행만 통과하고, FALSE와 UNKNOWN인 행은 제외된다.
- 비교·논리·부정 연산자, IN, BETWEEN, LIKE, NULL 조건(IS NULL/IS NOT NULL)을 사용할 수 있다.
- [[집계 함수]]는 WHERE절에서 사용할 수 없다(집계 이전 단계이므로). 집계 결과에 조건을 걸려면 [[HAVING]]을 사용해야 한다.

## Related Concepts

- [[HAVING]]
- [[GROUP BY]]
- [[집계 함수]]

## Source

- SQL 기본.md — 6. WHERE 절
