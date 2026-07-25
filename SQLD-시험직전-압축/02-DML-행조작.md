[← 이전](./01-SQL명령어-4분류.md) | [목차](./README.md) | [다음 →](./03-DCL-TCL-트랜잭션.md)

# DML 행 조작

## 핵심 질문

> 행 데이터에 무엇을 하려는가?

## 분기표

```text
행 데이터에 무엇을 하려는가?
│
├─ 새 행을 추가한다
│  └─ INSERT
│
├─ 기존 행의 값을 수정한다
│  └─ UPDATE
│
├─ 기존 행을 삭제한다
│  └─ DELETE
│
└─ 조건에 따라 삽입 또는 수정한다
   └─ MERGE
```

> **`ALTER` = 구조 변경(DDL)** · **`UPDATE` = 데이터 값 변경(DML)** — 이름이 비슷해
> 보이지만 대상이 다르다. `ALTER`는 테이블 자체를, `UPDATE`는 테이블 안의 값을 바꾼다.

## 핵심 개념 표

예시 테이블:

```text
MEMBER
ID  | NAME | STATUS
101 | KIM  | ACTIVE
102 | LEE  | ACTIVE
```

| 명령어 | 역할 |
|---|---|
| INSERT | 새로운 행 추가 |
| UPDATE | 기존 행의 값 수정 |
| DELETE | 기존 행 삭제 |
| MERGE | 조건에 따라 삽입 또는 수정 |

## 최소 SQL 예시

```sql
-- INSERT
INSERT INTO MEMBER (ID, NAME, STATUS) VALUES (103, 'PARK', 'ACTIVE');

-- UPDATE
UPDATE MEMBER SET STATUS = 'INACTIVE' WHERE ID = 102;

-- DELETE
DELETE FROM MEMBER WHERE ID = 101;

-- MERGE (Oracle)
MERGE INTO MEMBER M
USING (SELECT 101 AS ID, 'KIM' AS NAME FROM DUAL) S
ON (M.ID = S.ID)
WHEN MATCHED THEN UPDATE SET M.NAME = S.NAME
WHEN NOT MATCHED THEN INSERT (ID, NAME) VALUES (S.ID, S.NAME);
```

`DELETE` / `TRUNCATE` / `DROP` 비교:

| 명령어 | 분류 | 행 | 구조 |
|---|---|---|---|
| DELETE | DML | 조건부 또는 전체 삭제 | 유지 |
| TRUNCATE | DDL | 전체 삭제 | 유지 |
| DROP | DDL | 전체 삭제 | 객체 자체 삭제 |

## 시험 함정

- `DELETE`는 WHERE로 일부만 지울 수 있지만, `TRUNCATE`는 WHERE 자체를 쓸 수 없다.
- `DELETE`는 DML이라 `ROLLBACK`이 가능하지만, `TRUNCATE`/`DROP`은 DDL로 취급되어
  일반적으로 자동 커밋되어 `ROLLBACK`이 불가능하다.
- `DROP`은 데이터뿐 아니라 테이블 구조 자체를 없앤다는 점에서 `DELETE`·`TRUNCATE`와
  근본적으로 다르다.
- `MERGE`의 MATCHED/NOT MATCHED를 `UPDATE`/`INSERT`와 반대로 외우기 쉬우니 주의.

## 상세 학습

- [Concepts/DML.md](<../Concepts/DML.md>)
- [Concepts/DELETE.md](<../Concepts/DELETE.md>)
- [Concepts/TRUNCATE.md](<../Concepts/TRUNCATE.md>)
- [Concepts/DROP.md](<../Concepts/DROP.md>)
- [_원본 자료/SQL 관리 구문.md](<../_원본 자료/SQL 관리 구문.md>)
- [Questions/M01-Q46.md](<../Questions/M01-Q46.md>) — TRUNCATE의 특징 기출
- [Questions/M01-Q47.md](<../Questions/M01-Q47.md>) — DROP·DELETE·TRUNCATE 비교 기출
