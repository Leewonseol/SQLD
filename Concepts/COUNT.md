---
type: concept
pilot: true
origin:
  - current-map
---

# COUNT

## 한 줄 정의

행의 개수를 세는 [[집계 함수]]이며, 대상 표기 방식에 따라 [[NULL]] 처리 방식이 달라진다.

## 핵심 규칙

- COUNT(*): 모든 행을 계산하며 NULL도 포함한다.
- COUNT(열): 해당 열이 NULL인 행은 제외하고 계산한다.
- COUNT(1), COUNT(0): 상수는 NULL이 아니므로 COUNT(*)와 같은 결과를 낸다.
- COUNT(DISTINCT 열): 중복을 제거한 뒤 집계한다.

## Related Concepts

- [[집계 함수]]
- [[NULL]]

## Source

- SQL 기본.md — 7. GROUP BY(② GROUP BY와 함께 쓰이는 집계 함수)
