# 04. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## 기준 데이터 — score 값

`score`(customer_id 1~12 순): `85, 92, NULL, 77, 60, 0, 88, 95, NULL, 70, 82, 99`

- NULL: customer_id 3, 9 (2행)
- NULL이 아닌 값(10개): `85, 92, 77, 60, 0, 88, 95, 70, 82, 99`
- 합계(NULL 제외) = 85+92+77+60+0+88+95+70+82+99 = **748**
- `COALESCE(score, 0)`으로 NULL 2개를 0으로 치환한 전체 12개: 원래 10개 값 +
  0(원래부터 있던 customer_id=6) + 0(치환된 customer_id=3) + 0(치환된
  customer_id=9) → 합계는 그대로 **748**(0을 더해도 합계는 안 변함), 개수만 12개.

## STEP 1. COUNT(*) vs COUNT(score)

| 쿼리 | Oracle | SQL Server |
|---|---|---|
| `COUNT(*)` | 12 | 12 |
| `COUNT(score)` | 10 | 10 |

## STEP 2. AVG(score) vs AVG(COALESCE(score, 0)) — 정확한 수치

| 계산식 | 값 |
|---|---|
| `AVG(score)`(NULL 2개 제외, 10개 평균) | 748 / 10 = **74.8** |
| `AVG(COALESCE(score, 0))`(NULL을 0으로 치환한 12개 평균) | 748 / 12 = **62.333...**(반복소수, 62 + 1/3) |
| 두 평균의 차이 | 74.8 − 62.333... = **12.4666...** |

**Oracle**: `NUMBER`는 정수/소수 구분이 없어 `AVG(score)` = 74.8,
`AVG(COALESCE(score,0))` = 62.333...(반환되는 소수 자릿수는 세션/클라이언트
설정에 따라 다르지만 값 자체는 정확하다).

**SQL Server**: `score`가 `INT`로 선언되어 있어 `AVG(score)`(CAST 없이)는
반환 타입도 `INT`로 고정되고 **소수부가 버려진다**(반올림이 아니라 절삭).

| 쿼리 | SQL Server 결과(CAST 없음) | SQL Server 결과(DECIMAL로 CAST) |
|---|---|---|
| `AVG(score)` | **74**(74.8 → 버림) | `AVG(CAST(score AS DECIMAL(10,2)))` = **74.80** |
| `AVG(COALESCE(score,0))` | **62**(62.33... → 버림) | `AVG(CAST(COALESCE(score,0) AS DECIMAL(10,2)))` ≈ **62.33**(반복소수, 표시 자릿수는 CAST 스케일에 따름) |

SQL Server에서 정수 컬럼을 `CAST`/`CONVERT` 없이 그냥 `AVG`하면 소수부가
조용히 버려진다는 것이 이 STEP에서 가장 중요한 SQLD 함정이다.

## STEP 3. SUM/MIN/MAX

| 함수 | 값 | 근거 |
|---|---|---|
| `SUM(score)` | 748 | NULL 2개 제외 10개 합 |
| `MIN(score)` | 0 | customer_id=6(실제 숫자 0, NULL 아님) |
| `MAX(score)` | 99 | customer_id=12 |

Oracle·SQL Server 결과 동일(SUM/MIN/MAX는 값 자체가 정수라 잘림 문제가
생기지 않는다 — AVG만 이 문제가 있다).

### 부서별(GROUP BY dept_code) 상세

| dept_code | 포함 행(customer_id) | score 값 | n_all | n_scored | sum | avg | min | max |
|---|---|---|---|---|---|---|---|---|
| D01 | 1, 5, 9 | 85, 60, NULL | 3 | 2 | 145 | 72.50 | 60 | 85 |
| D02 | 2, 6, 11 | 92, 0, 82 | 3 | 3 | 174 | 58.00 | 0 | 92 |
| D03 | 3, 7, 12 | NULL, 88, 99 | 3 | 2 | 187 | 93.50 | 88 | 99 |
| D99 | 8 | 95 | 1 | 1 | 95 | 95.00 | 95 | 95 |
| NULL | 4, 10 | 77, 70 | 2 | 2 | 147 | 73.50 | 70 | 77 |

(SQL Server 버전은 `AVG(CAST(score AS DECIMAL(10,2)))`으로 CAST했으므로 위
표의 avg 값과 동일하게 나온다. CAST 없이 `AVG(score)`만 쓰면 D01은 72,
D03은 93처럼 소수부가 잘려 다르게 나온다는 점에 주의.)

## STEP 4. 그룹 전체가 NULL이거나 결과 집합이 비어 있을 때

`WHERE score IS NULL GROUP BY dept_code` — 각 그룹에 남는 행의 score가
전부 NULL이므로:

| dept_code | 포함 행 | n_all | n_scored | sum_score | avg_score | min_score | max_score |
|---|---|---|---|---|---|---|---|
| D01 | 9 | 1 | 0 | NULL | NULL | NULL | NULL |
| D03 | 3 | 1 | 0 | NULL | NULL | NULL | NULL |

`WHERE 1=0`(GROUP BY 없이, 결과 집합 자체가 0행) — 집계 결과는 **1행**으로
반환되며:

| n_all | n_scored | sum_score | avg_score | min_score | max_score |
|---|---|---|---|---|---|
| 0 | 0 | NULL | NULL | NULL | NULL |

`COUNT(*)`/`COUNT(score)`는 대상 행이 0개면 0을 반환하지만, `SUM`/`AVG`/
`MIN`/`MAX`는 대상 행이 0개(또는 전부 NULL)면 **NULL**을 반환한다 —
`COUNT`류와 나머지 집계함수가 "0행일 때의 기본값"이 다르다는 것이 이
STEP의 핵심 결론.

## 12. 실제 실행 검증 여부

미검증. `COUNT`/`SUM`/`AVG`/`MIN`/`MAX`의 NULL 무시 규칙(표준 SQL 공통),
SQL Server `AVG(INT)`의 절삭 규칙, 빈 결과 집합/전체 NULL 그룹에서의 반환값
차이는 각 벤더 공식 문서와 표준 SQL 집계함수 규칙을 근거로 도출했으며, 위
수치들은 직접 손으로 계산해 검산했다(748/10=74.8, 748/12=62.333...). 다만
이 세션에서 실제 DBMS로 실행해 재확인하지는 않았다.
