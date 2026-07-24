---
type: concept
pilot: true
origin:
  - current-map
---

# JOIN

## 한 줄 정의

여러 테이블의 데이터를 조인 조건으로 연결해 한 번에 조회하는 연산이다.

## 핵심 규칙

- 실행 원리: 테이블 간 모든 조합(카티션 곱)을 만든 뒤 조인 조건으로 필터링한다.
- 조인 조건은 일반적으로 [[PK]]–[[FK]] 열을 사용하며, 테이블 N개 조인 시 최소 N-1개 조건이 필요하다.
- [[관계 차수]]가 1:N인 경우, 조인 결과에서 1쪽 행이 N쪽 수만큼 반복될 수 있다.
- 하위 유형: [[OUTER JOIN]], INNER JOIN(불일치 행 제외), ANSI JOIN(ON/USING/NATURAL), CROSS JOIN(카티션 곱).

## Related Concepts

- [[OUTER JOIN]]
- [[PK]]
- [[FK]]
- [[관계 차수]]

## Source

- SQL 기본.md — 5. FROM 절(JOIN)
