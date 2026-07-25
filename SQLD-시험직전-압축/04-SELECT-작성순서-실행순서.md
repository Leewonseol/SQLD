[← 이전](./03-DCL-TCL-트랜잭션.md) | [목차](./README.md) | [다음 →](./05-WHERE-HAVING.md)

# SELECT 문 작성 순서와 논리적 실행 순서

## 핵심 질문

> 내가 쓰는 순서와 DBMS가 처리하는 순서가 같은가?

## 분기표

작성 순서:

```text
SELECT
→ FROM
→ WHERE
→ GROUP BY
→ HAVING
→ ORDER BY
```

논리적 실행 순서:

```text
FROM
→ WHERE
→ GROUP BY
→ HAVING
→ SELECT
→ ORDER BY
```

## 핵심 개념 표

| 순서 | 절 | 역할 |
|---|---|---|
| 1 | FROM | 대상 결정 |
| 2 | WHERE | 행 필터 |
| 3 | GROUP BY | 그룹 생성 |
| 4 | HAVING | 그룹 필터 |
| 5 | SELECT | 출력 계산 |
| 6 | ORDER BY | 정렬 |

## 최소 SQL 예시

```sql
SELECT deptno, AVG(sal) AS avg_sal
FROM emp
WHERE sal >= 1000
GROUP BY deptno
HAVING AVG(sal) >= 1800
ORDER BY avg_sal DESC;
```

> 작성은 `SELECT`가 맨 위에 있지만, 실행은 `FROM`부터 시작한다. `SELECT`가 만든
> 별칭(`avg_sal`)을 `ORDER BY`에서 쓸 수 있는 이유도 `SELECT`가 `ORDER BY`보다 먼저
> 실행되기 때문이다.

## 시험 함정

- 작성 순서와 실행 순서는 다르다.
- `WHERE`는 생략할 수 있다.
- `SELECT` 목록에 스칼라 서브쿼리를 쓸 수 있다.
- `FROM` 생략 가능 여부는 DBMS별로 다르다(Oracle은 `FROM` 없는 SELECT가 불가능해
  `DUAL`이 필요하다).
- `WHERE`에서는 `SELECT`가 정의한 별칭을 바로 쓸 수 없다 — 논리적 실행 순서상
  `WHERE`가 `SELECT`보다 먼저 실행되어, `WHERE`가 처리되는 시점에는 아직 별칭이
  존재하지 않기 때문이다.
- `ORDER BY`는 `SELECT`보다 나중에 실행되므로 `SELECT`에서 정의한 별칭을 대부분의
  경우 사용할 수 있다.

## 상세 학습

- [_원본 자료/SQL 기본.md](<../_원본 자료/SQL 기본.md>) — SELECT문 작성 순서·논리적 실행 순서 원본
- [Concepts/ORDER BY.md](<../Concepts/ORDER BY.md>)
- [Questions/M01-Q36.md](<../Questions/M01-Q36.md>) — ORDER BY 별칭·순서번호 혼용 기출
- [Propositions/M01-Q36-O2.md](<../Propositions/M01-Q36-O2.md>) — 위 문제의 선지별 판별 해설
