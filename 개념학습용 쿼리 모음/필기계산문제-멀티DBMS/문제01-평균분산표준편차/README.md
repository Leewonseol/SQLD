---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 01. 평균·분산·표준편차 (Oracle · SQL Server)

## 1. 필기 예상문제

> 다음은 5개 매장(A~E)의 일일 매출액(단위: 백만원)이다.
>
> | 매장 | A | B | C | D | E |
> |---|---|---|---|---|---|
> | 매출액 | 12 | 15 | 11 | 18 | 14 |
>
> 이 자료의 평균, **모분산·모표준편차**, **표본분산·표본표준편차**를 구하시오.

## 2. 손계산

- 평균 `x̄ = (12+15+11+18+14) / 5 = 14`
- 편차제곱합 `Σ(xᵢ-x̄)² = 4+1+9+16+0 = 30`
- 모분산 `σ² = 30/5 = 6`, 모표준편차 `σ = √6 ≈ 2.449`
- 표본분산 `s² = 30/(5-1) = 7.5`, 표본표준편차 `s = √7.5 ≈ 2.739`

## 3. 공통 입력 데이터

```
sales(store, amount)
('A',12), ('B',15), ('C',11), ('D',18), ('E',14)
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql) 참고. 핵심:

```sql
SELECT
    AVG(amount)        AS mean,
    VAR_POP(amount)     AS pop_variance,
    STDDEV_POP(amount)  AS pop_stddev,
    VARIANCE(amount)    AS sample_variance,
    STDDEV(amount)      AS sample_stddev
FROM sales;
```

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql) 참고. 핵심:

```sql
SELECT
    AVG(amount)     AS mean,
    VARP(amount)    AS pop_variance,
    STDEVP(amount)  AS pop_stddev,
    VAR(amount)     AS sample_variance,
    STDEV(amount)   AS sample_stddev
FROM sales;
```

## 6. Oracle 예상 결과

`mean=14, pop_variance=6, pop_stddev≈2.449, sample_variance=7.5, sample_stddev≈2.739`
(손계산과 일치 — **실제 Oracle 검증 필요**, 이 세션에서 실행하지 않음)

## 7. SQL Server 예상 결과

`mean=14, pop_variance=6, pop_stddev≈2.449, sample_variance=7.5, sample_stddev≈2.739`
(Oracle과 동일한 값 — **실제 SQL Server 검증 필요**, 이 세션에서 실행하지 않음)

## 8. 두 DBMS에서 같은 부분

- **계산 결과 값 자체가 완전히 같다.** Oracle `VARIANCE`/`STDDEV`(인수 1개)와 SQL Server
  `VAR`/`STDEV`는 둘 다 **표본** 통계량을 반환하고, `VAR_POP`/`STDDEV_POP`(Oracle)과
  `VARP`/`STDEVP`(SQL Server)는 둘 다 **모** 통계량을 반환한다 — 이름은 다르지만 "기본이
  표본"이라는 의미 체계는 동일하다. 이 문제는 **문법만 다르고 결과는 같은 사례**다.

## 9. 두 DBMS에서 다른 부분

- 함수 이름 자체: `VAR_POP`↔`VARP`, `STDDEV_POP`↔`STDEVP`, `VARIANCE`↔`VAR`, `STDDEV`↔`STDEV`
- 다중행 INSERT: SQL Server는 `VALUES (...), (...), (...)`를 한 문장으로 지원하지만,
  Oracle 전통 `INSERT`는 한 문장에 한 행만 허용한다(`oracle.sql`에서 5개 `INSERT`문을
  따로 쓴 이유). Oracle에서 여러 행을 한 문장으로 넣으려면 `INSERT ALL` 구문이 필요하다.
- 자료형: Oracle `NUMBER`(정밀도 내장) vs SQL Server `FLOAT`/`DECIMAL` — 이 문제 범위의
  정수 매출액에서는 계산 결과에 영향 없음.

## 10. SQLD 출제 함정

- MySQL 계열의 `STD()`/`VARIANCE()`(모통계량 기본)에 익숙해진 상태로 Oracle/SQL Server를
  풀면 표본/모 관계가 반대로 뒤바뀐다고 착각하기 쉽다. **Oracle과 SQL Server는 이름이 없는
  기본형(`STDDEV`/`STDEV`, `VARIANCE`/`VAR`)이 항상 "표본"** 이라는 점을 고정 규칙으로
  외워야 한다.
- `VARP`/`STDEVP`처럼 이름 끝에 `P`가 붙으면 Population(모집단)이라는 규칙을 SQL Server
  전반(예: `PERCENTILE_CONT` 계열은 다른 규칙이므로 혼동 주의)에 무조건 확대 적용하지 말 것.

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| `VAR_POP`/`VARP` | `numpy.var(x, ddof=0)` | `mean((x-mean(x))^2)` (R `var()`은 기본이 표본) |
| `VARIANCE`/`VAR` | `numpy.var(x, ddof=1)` 또는 `statistics.variance(x)` | `var(x)` (기본이 표본) |
| `STDDEV_POP`/`STDEVP` | `numpy.std(x, ddof=0)` | `sqrt(mean((x-mean(x))^2))` |
| `STDDEV`/`STDEV` | `numpy.std(x, ddof=1)` 또는 `statistics.stdev(x)` | `sd(x)` (기본이 표본) |

`분석기법/01-PCA`의 `pca.explained_variance_`(sklearn)도 내부적으로 표본 기준 공분산을
쓴다 — 이 문제의 표본/모 구분이 실기 PCA 코드의 스케일링과 직접 연결된다.

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세 엔진은 Oracle·SQL Server의 **대체가 아니라 보조 검증**이며, 이 세션에서 실제로
실행해 확인했다(`python3 run_compare.py`). 세 엔진 모두 `mean=14, pop_variance=6,
pop_stddev≈2.449, sample_variance=7.5, sample_stddev≈2.739`로 Oracle·SQL Server의
예상 결과와 일치한다. 다만 함수 이름 체계는 또 다르다: SQLite는 통계 내장함수가 아예
없어 `SQRT(AVG(x*x)-AVG(x)*AVG(x))` 수식을 직접 전개해야 하고, MariaDB(MySQL 호환)는
이름 없는 기본형(`VARIANCE`, `STD`)이 Oracle/SQL Server와 반대로 **모**통계량이다 —
자세한 실행 결과와 SQL은 [`run_compare.py`](./run_compare.py) 참고.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
