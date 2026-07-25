[← 이전](./05-WHERE-HAVING.md) | [목차](./README.md) | [다음 →](./07-집계함수와NULL.md)

# NULL은 값이 아니라 알 수 없음

## 핵심 질문

> NULL과 비교하면 결과는 무엇인가?

```text
NULL ≠ 0 ≠ 빈 문자열
```

> 단, **Oracle은 빈 문자열 `''`을 VARCHAR2 컬럼에 저장할 때 NULL로 취급한다.**
> SQL Server는 `''`과 NULL을 별개의 값으로 구분한다.

## 분기표

```text
조건식 결과
│
├─ TRUE
│  └─ WHERE 통과
│
├─ FALSE
│  └─ WHERE 제외
│
└─ UNKNOWN
   └─ WHERE 제외
```

정확한 비교:

```sql
IS NULL
IS NOT NULL
```

잘못된 비교:

```sql
= NULL
<> NULL
!= NULL
```

## 핵심 개념 표

| 표현 | 결과 |
|---|---|
| `NULL = NULL` | UNKNOWN (TRUE 아님) |
| `col = NULL` | 항상 UNKNOWN |
| `col IS NULL` | col이 NULL이면 TRUE |
| `CASE WHEN 조건 THEN ...` | 조건이 TRUE일 때만 THEN 실행 |
| `CASE`의 FALSE·UNKNOWN | 둘 다 ELSE로 이동 |

> **NULL과 일반 비교 연산을 수행하면 결과는 UNKNOWN이며, WHERE는 TRUE인 행만
> 통과시킨다.**

## 최소 SQL 예시

```sql
SELECT ename, comm
FROM emp
WHERE comm IS NULL;      -- 정확: comm이 NULL인 행만 조회

SELECT ename, comm
FROM emp
WHERE comm = NULL;       -- 오류 아님, 그러나 결과는 항상 0건(UNKNOWN)
```

## 시험 함정

- `NULL = NULL`도 TRUE가 아니다(UNKNOWN).
- `CASE WHEN`은 조건이 TRUE일 때만 THEN이 실행된다.
- FALSE와 UNKNOWN은 둘 다 ELSE로 간다 — WHEN 조건이 "거짓"인지 "알 수 없음"인지
  결과만으로는 구분되지 않는다.
- Oracle은 `''`을 NULL로 처리하지만 SQL Server는 `''`과 NULL을 구분한다.
- `NOT IN` 목록에 NULL이 하나라도 섞이면 전체 비교가 UNKNOWN이 되어 결과 집합이
  비어버릴 수 있다.

## 상세 학습

- [Concepts/NULL.md](<../Concepts/NULL.md>)
- [Concepts/IN·NOT IN.md](<../Concepts/IN·NOT IN.md>)
- [Concepts/DBMS 문법 차이(Oracle-SQLServer).md](<../Concepts/DBMS 문법 차이(Oracle-SQLServer).md>) — NULL과 빈 문자열, NULL 정렬 차이
- [NULL-집중학습/README.md](<../NULL-집중학습/README.md>) — NULL 전체 학습 모듈 진입점
- [NULL-집중학습/00-NULL의미와3값논리/README.md](<../NULL-집중학습/00-NULL의미와3값논리/README.md>) — 3값 논리 진리표 상세
- [NULL-집중학습/01-NULL판정/README.md](<../NULL-집중학습/01-NULL판정/README.md>) — IS NULL, 빈 문자열/공백 판정 상세
- [NULL-집중학습/08-NOT-IN과NOT-EXISTS/README.md](<../NULL-집중학습/08-NOT-IN과NOT-EXISTS/README.md>) — NOT IN + NULL 함정 상세
- [Questions/M01-Q22.md](<../Questions/M01-Q22.md>) — NOT IN과 NULL의 상호작용 기출
