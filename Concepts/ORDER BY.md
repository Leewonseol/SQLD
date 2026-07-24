---
type: concept
pilot: true
origin:
  - current-map
---

# ORDER BY

## 한 줄 정의

조회 결과를 지정한 기준으로 정렬하는 절이며, 논리적 실행 순서상 가장 마지막에 실행된다.

## 핵심 규칙

- ASC(기본값)/DESC로 정렬 방향을 지정한다.
- 다중 열 정렬 시 왼쪽 기준부터 적용된다.
- 열 이름, SELECT 순서 번호, 별칭, CASE 표현식을 정렬 기준으로 사용할 수 있다.
- NULL 정렬 순서는 Oracle과 SQL Server가 서로 다르다(Oracle ASC는 NULL이 마지막, SQL Server ASC는 NULL이 처음).
- 문자형 [[자료형]] 정렬 시 사전식 비교가 적용된다.

## Related Concepts

- [[자료형]]
- [[NULL]]

## Source

- SQL 기본.md — 8. ORDER BY
