[← 이전](./04-SELECT-작성순서-실행순서.md) | [목차](./README.md) | [다음 →](./06-NULL-비교와3값논리.md)

# WHERE와 HAVING

## 핵심 질문

> 무엇을 거르려는가?

## 분기표

```text
무엇을 거르려는가?
│
├─ GROUP BY 이전의 개별 행
│  └─ WHERE
│
└─ GROUP BY 이후 생성된 그룹
   └─ HAVING
```

흐름:

```text
원본 행
→ WHERE로 행 필터
→ GROUP BY로 그룹 생성
→ HAVING으로 그룹 필터
```

## 핵심 개념 표

| 구분 | 필터 대상 | 실행 시점 | 집계 함수 조건 |
|---|---|---|---|
| WHERE | 개별 행 | GROUP BY 이전 | 사용 불가 |
| HAVING | 그룹 | GROUP BY 이후 | 사용 가능 |

## 최소 SQL 예시

대표 예시:

```sql
SELECT deptno, AVG(sal)
FROM emp
WHERE sal >= 1000
GROUP BY deptno
HAVING AVG(sal) >= 1800;
```

잘못된 예:

```sql
WHERE AVG(sal) >= 1800
```

올바른 예:

```sql
HAVING AVG(sal) >= 1800
```

> **WHERE는 행 조건, HAVING은 그룹 조건이다.**

## 시험 함정

- 집계 함수 조건은 원칙적으로 `HAVING`에서 처리한다.
- `WHERE`는 `GROUP BY` 이전에 실행된다.
- `HAVING`은 `GROUP BY` 이후에 실행된다.
- `HAVING`을 `GROUP BY` 없이 쓸 수 있는 DBMS도 있지만, 시험 기본 개념은
  "HAVING = 그룹 조건"으로 기억한다.

## 상세 학습

- [Concepts/WHERE.md](<../Concepts/WHERE.md>)
- [Concepts/HAVING.md](<../Concepts/HAVING.md>)
- [Concepts/GROUP BY.md](<../Concepts/GROUP BY.md>)
- [_원본 자료/SQL 기본.md](<../_원본 자료/SQL 기본.md>) — WHERE 절·GROUP BY·HAVING 원본
