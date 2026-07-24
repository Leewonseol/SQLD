---
type: concept
pilot: true
origin:
  - current-map
---

# FK

## 한 줄 정의

다른 테이블의 기본키를 참조하여 두 테이블 간 관계를 표현하는 외래키 제약조건이다.

## 핵심 규칙

- 참조 무결성을 보장한다(원본 표현 그대로 인용: "FOREIGN KEY: 참조 무결성 보장").
- CASCADE, SET NULL, SET DEFAULT, NO ACTION·RESTRICT 옵션을 가질 수 있다.

## Related Concepts

- [[PK]]
- [[제약조건]]

## Source

- SQL 관리 구문.md — 3. DDL 제약조건(FOREIGN KEY: 참조 무결성 보장)

참고: "참조 무결성"은 원본에 한 줄로만 언급되어 있고 이번 파일럿의 5개 지정 Concept Node에 포함되지 않으므로, 이 문서에서는 별도 노드로 링크하지 않고 서술어로만 사용함.
