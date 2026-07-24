---
type: concept
pilot: true
origin:
  - current-map
---

# ALTER

## 한 줄 정의

기존 테이블 등 객체의 구조를 변경하는 [[DDL]] 명령이다.

## 핵심 규칙

- 컬럼 추가: ALTER TABLE 테이블 ADD ...
- 컬럼 삭제: ALTER TABLE 테이블 DROP ...
- 자료형·속성 변경: Oracle은 MODIFY, SQL Server는 ALTER COLUMN을 사용한다.
- MODIFY(Oracle)는 여러 컬럼을 한 번에 묶어 변경할 수 있지만, ALTER COLUMN(SQL Server)은 한 번에 한 컬럼만 변경할 수 있다.

## Related Concepts

- [[DDL]]

## Source

- SQL 관리 구문.md — 3. DDL(ALTER)
