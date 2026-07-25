# 09. NULL 정렬과 윈도우 함수

## 1. 학습 목표

- `ORDER BY`에서 NULL이 정렬되는 기본 위치가 Oracle과 SQL Server에서
  **정반대**라는 것을 직접 실행으로 확인한다.
- Oracle의 `NULLS FIRST`/`NULLS LAST` 절과, 이 절이 없는 SQL Server에서
  같은 효과를 내는 `CASE WHEN` 트릭을 비교한다.
- `ROW_NUMBER`/`RANK`/`DENSE_RANK`가 NULL이 섞인 컬럼을 정렬 기준으로 쓸 때
  NULL 값끼리 "동순위"로 묶인다는 것을 확인한다.
- `PARTITION BY` 기준 컬럼이 NULL이어도 NULL 값들이 하나의 파티션으로
  묶인다는 것을 확인한다.

## 2. 핵심 원리

- **Oracle 기본 정렬 순서**: `ORDER BY col ASC`에서 NULL은 **가장 큰 값**처럼
  취급되어 맨 뒤에 온다(`NULLS LAST`가 기본값). `ORDER BY col DESC`에서는
  반대로 NULL이 맨 앞에 온다(`NULLS FIRST`가 기본값). `NULLS FIRST`/
  `NULLS LAST` 절로 이 기본값을 명시적으로 뒤집을 수 있다.
- **SQL Server 기본 정렬 순서(Oracle과 반대)**: SQL Server는 NULL을 항상
  **가장 작은 값**처럼 취급한다. `ORDER BY col ASC`에서는 NULL이 맨 앞에,
  `ORDER BY col DESC`에서는 NULL이 맨 뒤에 온다. SQL Server에는
  `NULLS FIRST`/`NULLS LAST` 절 자체가 없어서, Oracle과 같은 위치에 NULL을
  두고 싶다면 `ORDER BY CASE WHEN col IS NULL THEN 1 ELSE 0 END, col`
  같은 `CASE WHEN` 트릭을 써야 한다.
- **윈도우 함수와 NULL 정렬**: `ROW_NUMBER()`/`RANK()`/`DENSE_RANK()`는
  모두 내부적으로 `ORDER BY`를 쓰므로 위의 NULL 정렬 규칙을 그대로
  따른다. 정렬 기준 값이 NULL인 행이 여러 개면, `RANK`/`DENSE_RANK`는
  이들을 "값이 같다"고 취급해 **동일한 순위**를 부여한다(`=` 비교에서는
  NULL끼리 절대 같다고 판정되지 않는 것과 다른 결이다 — 정렬/그룹핑
  맥락에서는 NULL을 "서로 같다"고 다루는 것이 SQL 표준의 일관된 원칙이다.
  `07` 폴더의 `UNION`/`GROUP BY`에서도 같은 원리가 적용된다). `ROW_NUMBER()`는
  동순위를 허용하지 않으므로 NULL 행들에도 서로 다른 번호를 매기지만, 그
  순서는 표준상 보장되지 않아 실무에서는 항상 2차 정렬 키(예:
  `customer_id`)를 추가해 결정적으로 만든다.
- **PARTITION BY와 NULL**: `PARTITION BY col`은 `GROUP BY`와 마찬가지로
  `col`이 NULL인 행들을 하나의 파티션으로 묶는다 — NULL은 서로 다른
  파티션에 흩어지지 않는다.

## 3. 공통 입력 데이터

`00-NULL의미와3값논리`와 완전히 같은 `null_lab_customer`/`null_lab_dept`/
`null_lab_excluded_codes`를 재사용한다. 이 폴더가 실제로 쓰는 컬럼:

- `score`(NULL 2행: customer_id 3, 9) — `ORDER BY` NULL 위치 비교.
- `purchase_amt`(NULL 2행: customer_id 5, 11) — 윈도우 함수 순위 비교.
- `dept_code`(NULL 2행: customer_id 4, 10) — `PARTITION BY` NULL 파티션
  확인.

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) — 공통 데이터셋 생성 후 3단계.

1. `score ASC`/`DESC` 기본 정렬(NULL 위치 확인) + `NULLS FIRST`/
   `NULLS LAST` 명시 절
2. `purchase_amt` 기준 `ROW_NUMBER`/`RANK`/`DENSE_RANK`(NULL 동순위 확인)
3. `PARTITION BY dept_code`(NULL 파티션 확인)

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) — 로직은 같지만 NULL 정렬 기본값이
Oracle과 정반대이고, `NULLS FIRST`/`NULLS LAST` 절이 없어 `CASE WHEN`
트릭으로 대체한다.

## 6. 예상 결과

[`expected_results.md`](./expected_results.md) 참고.

## 7. 결과 차이의 이유

NULL을 정렬할 때 어느 쪽에 둘지는 **ANSI SQL 표준이 강제하지 않고 벤더가
자유롭게 정할 수 있는 부분**이다(표준은 "구현체가 정의하기 나름"이라고만
규정한다). Oracle은 NULL을 "알 수 없는 큰 값"처럼 취급해 오름차순에서
맨 뒤에 두는 쪽을 기본값으로 택했고, SQL Server는 반대로 NULL을 "가장
작은 값"처럼 취급해 오름차순에서 맨 앞에 두는 쪽을 기본값으로 택했다.
어느 쪽이 "더 표준적"이라고 할 수 없는, 순수한 벤더 설계 선택의 차이다.
반면 `RANK`/`DENSE_RANK`가 NULL끼리 동순위로 묶는 규칙과 `PARTITION BY`가
NULL을 하나의 그룹으로 묶는 규칙은 두 DBMS가 완전히 동일하다 — 이는
"정렬/그룹핑 관점에서는 NULL을 서로 같다고 본다"는 표준의 공통 원칙이기
때문이다.

## 8. SQLD 함정

- **"NULL은 항상 정렬에서 맨 뒤(또는 맨 앞)에 온다"고 DBMS 구분 없이
  암기하는 함정** — Oracle 기본값과 SQL Server 기본값이 정반대라는 것을
  놓치면 시험에서 결과 예측 문제를 틀린다.
- **"SQL Server에도 `NULLS LAST`가 있을 것"이라는 착각** — SQL Server
  표준 T-SQL에는 이 절이 없다(`CASE WHEN` 트릭이 정석 대체 방법이다).
- **"`=` 비교에서 NULL끼리 다르다고 배웠으니 정렬/순위에서도 NULL끼리
  다르게 취급될 것"이라는 착각** — `RANK`/`DENSE_RANK`/`GROUP BY`/
  `PARTITION BY` 등 **정렬·그룹핑 맥락**에서는 NULL을 서로 같다고 보는
  것이 표준이다. `=` 비교(3값 논리, `00`~`01` 폴더)와 정렬/그룹핑 규칙은
  서로 다른 규칙이라는 것을 구분해야 한다.
- **`ROW_NUMBER`가 매긴 NULL 행들의 순서가 항상 일정할 것이라는 착각** —
  2차 정렬 키(예: PK)를 명시하지 않으면 동순위 NULL 행들 사이의
  `ROW_NUMBER` 순서는 실행마다 달라질 수 있다.

## 9. 빅분기 결측치 처리와의 연결

빅데이터분석기사 실기에서 결측치가 포함된 컬럼을 정렬해 상위/하위
n개를 뽑아야 할 때(`pandas`의 `sort_values(na_position=...)`), SQL과
마찬가지로 결측치를 어느 쪽에 둘지 명시적으로 결정해야 한다.
`sort_values`의 기본값은 `na_position='last'`로, 이는 Oracle의
오름차순 기본값과 우연히 일치한다 — 그러나 이를 "당연한 표준 동작"으로
암기하면 SQL Server 기본값에서 헷갈리게 된다. 결측치 위치를 항상 명시적으로
지정하는 습관(`na_position='first'`/`'last'`를 코드에 명시, SQL에서는
`NULLS FIRST`/`LAST`나 `CASE WHEN` 트릭을 명시)이 재현 가능한 분석
파이프라인의 기본이다.

## 10. 연습문제

[`quiz.sql`](./quiz.sql) 참고.

## 11. 정답 해설

[`answer.sql`](./answer.sql) 참고.

## 12. 실제 실행 검증 여부

**Oracle·SQL Server 모두 미검증** — 이 세션에는 두 DBMS를 실행할 환경이
없다(저장소 루트 `README.md` §5, `../README.md` 참고). NULL 정렬 기본값과
윈도우 함수의 동순위 처리 규칙은 각 벤더 공식 문서에 근거해 작성했으며,
`oracle.sql`/`sqlserver.sql`은 각자의 환경에 그대로 복사해 실행할 수 있는
완전한 스크립트다. 실행했다고 보고하지 않는다 — 실제 결과는 각 환경에서
재확인이 필요하다.
