---
type: concept
pilot: true
origin:
  - current-map
---

# AUTO COMMIT

## 한 줄 정의

SQL문 실행 직후 자동으로 [[COMMIT]]이 이루어지는지를 결정하는 설정이다.

## 핵심 규칙

- Oracle: 기본적으로 DML은 자동 COMMIT되지 않지만, [[DDL]] 실행 시에는 자동 COMMIT이 발생한다.
- SQL Server: 기본적으로 AUTO COMMIT 상태이며, BEGIN TRANSACTION을 명시하면 수동 제어로 전환할 수 있다.
- 이 DBMS별 차이는 Oracle에만 해당하는 인과관계이며, SQL Server에는 적용되지 않는다.

## Related Concepts

- [[DDL]]
- [[Transaction]]

## Source

- SQL 관리 구문.md — 2. TCL(AUTO COMMIT)
