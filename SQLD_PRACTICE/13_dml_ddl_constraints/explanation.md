# 13 DML·DDL·제약조건 — 단원 안내 (별도 학습 분기)

학습 흐름의 **"물리적 테이블·PK·FK·제약조건 → 테스트 데이터 INSERT"** 단계를 명령 수준에서 다룬다. 설계와 연결하는 부분은 02단원(ERD → DDL)이다.
명령 분류(PDF E-04): DML = INSERT·UPDATE·DELETE·MERGE / DDL = CREATE·ALTER·DROP·RENAME·TRUNCATE.

> 모든 예제는 자기 실험 테이블(D13_*)을 만들고, 끝나면 지운다. 원본 EMP·DEPT는 바꾸지 않는다.

| 실습 | 주제 | 근거 |
|---|---|---|
| [ex01](examples/ex01_insert_update_delete.md) | INSERT·UPDATE·DELETE, DEFAULT, 여러 행 INSERT | PDF E-04, §7 |
| [ex02](examples/ex02_merge.md) | MERGE | PDF E-04 |
| [ex03](examples/ex03_ddl_create_alter.md) | CREATE·ALTER(ADD/MODIFY/RENAME/DROP COLUMN)·RENAME·DROP | PDF E-04 |
| [ex04](examples/ex04_truncate_delete_drop.md) | DELETE·TRUNCATE·DROP 비교 | PDF E-04 |
| [ex05](examples/ex05_constraints.md) | PK·FK·UNIQUE·CHECK·NOT NULL, 참조 동작 | §7, PDF E-03 |
| [ex06](examples/ex06_ctas.md) | CTAS / SELECT INTO가 복사하는 것 | §7 |

## 실행으로 확인한 DBMS 차이
| 항목 | Oracle 21c | SQL Server 2022 |
|---|---|---|
| 여러 행 INSERT | INSERT ALL … SELECT FROM dual (23ai부터 VALUES 여러 개) | `VALUES (..), (..)` |
| MERGE | `ON (…)` 괄호 필수, `UPDATE … DELETE WHERE`, ON 컬럼 갱신 불가(ORA-38104) | 세미콜론 필수(Msg 10713), `WHEN NOT MATCHED BY SOURCE`, `WHEN MATCHED AND 조건` |
| 컬럼 변경 | `MODIFY`, `RENAME COLUMN`, `RENAME t TO t2` | `ALTER COLUMN`, `sp_rename` |
| DEFAULT 있는 컬럼 ADD | 기존 행에 기본값이 채워진다 | NULL 허용 컬럼은 NULL. `WITH VALUES`를 붙여야 채워진다 |
| TRUNCATE 롤백 | 불가(DDL 자동 커밋) | 명시적 트랜잭션 안에서는 가능(14단원 ex01) |
| FK가 참조하는 부모 TRUNCATE | 자식이 비어 있으면 **성공**, 자식에 행이 있으면 ORA-02266 | 항상 Msg 4712 |
| 부모 DROP | `CASCADE CONSTRAINTS`로 FK까지 삭제 | CASCADE 없음. FK를 먼저 삭제 |
| UNIQUE 컬럼의 NULL | 여러 개 허용 | **1개만** 허용(Msg 2627) → 필터링된 UNIQUE 인덱스로 해결 |
| 참조 동작 | ON DELETE CASCADE / SET NULL (ON UPDATE 없음) | ON DELETE·ON UPDATE 모두 CASCADE / SET NULL / SET DEFAULT |
| 제약 위반 오류 코드 | CHECK 02290, PK/UNIQUE 00001, NOT NULL 01400, FK 02291/02292 | CHECK·FK 모두 547, PK 2627, UNIQUE 인덱스 2601, NOT NULL 515 |
| 테이블 복사 | CREATE TABLE … AS SELECT | SELECT … INTO |
