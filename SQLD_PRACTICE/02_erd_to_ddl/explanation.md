# 02 ERD → DDL — 단원 안내

학습 흐름: **논리적 ERD → 물리적 테이블·PK·FK·제약조건 → 테스트 데이터 INSERT**.
01단원 ex01의 도서관 논리 ERD를 두 DBMS의 CREATE TABLE로 바꾼다. 그다음 업무 규칙을 어기는 INSERT가 실제로 거부되는지 실행으로 확인한다.

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_library_ddl.md) | 도서관 모델 DDL, 업무 규칙 ↔ 제약조건 대응표, 위반 테스트 | §6 |
| [ex02](examples/ex02_datatype_mapping.md) | 자료형 매핑(문자 길이 단위, CHAR 패딩, NUMBER/DECIMAL, DATE), 빈 문자열 | §8 |

FK 참조 동작(ON DELETE CASCADE·SET NULL·ON UPDATE)은 13단원 ex05에서 실행했다.
