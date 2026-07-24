---
type: concept
pilot: true
origin:
  - current-map
---

# GROUP BY

## 한 줄 정의

특정 열을 기준으로 같은 값끼리 묶어 데이터의 관찰 단위(입도)를 그룹 단위로 바꾸는 절이다.

## 핵심 규칙

- [[WHERE]] 이후, SELECT 이전에 실행된다.
- SELECT에서는 GROUP BY에 명시한 열·표현식과 [[집계 함수]]만 사용할 수 있다.
- [[HAVING]]으로 그룹을 추가 필터링할 수 있다.
- [[그룹함수 확장]](ROLLUP/CUBE/GROUPING SETS)으로 여러 집계 수준을 한 번에 낼 수 있다.

## Related Concepts

- [[집계 함수]]
- [[HAVING]]
- [[그룹함수 확장]]

## Source

- SQL 기본.md — 7. GROUP BY
