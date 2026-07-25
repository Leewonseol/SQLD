---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 03. 단순선형회귀 계수 (Oracle · SQL Server)

## 1. 필기 예상문제

> [문제02]와 같은 자료(광고비 X, 매출액 Y, n=5)로 회귀직선 `Y=β0+β1X`의 계수를
> 최소제곱법으로 구하고, 광고비가 6일 때 매출액을 예측하시오.

## 2. 손계산

- `β1 = 공분산/분산(x) = 1.2/2 = 0.6`
- `β0 = ȳ - β1·x̄ = 4 - 0.6×3 = 2.2`
- `Ŷ = 2.2 + 0.6X`, `X=6`일 때 `Ŷ=5.8`

## 3. 공통 입력 데이터

```
ad_sales(mon, x, y)
(1,1,2), (2,2,4), (3,3,5), (4,4,4), (5,5,5)
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql). Oracle은 `REGR_SLOPE`, `REGR_INTERCEPT`, `REGR_R2` 회귀
집계함수를 내장한다.

```sql
SELECT REGR_SLOPE(y,x) AS beta1, REGR_INTERCEPT(y,x) AS beta0, REGR_R2(y,x) AS r_squared
FROM ad_sales;
```

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql). `REGR_*` 계열이 없어 정규방정식을 직접 전개한다.

```sql
SELECT
    (AVG(x*y) - AVG(x)*AVG(y)) / (AVG(x*x) - AVG(x)*AVG(x)) AS beta1,
    AVG(y) - (...) * AVG(x) AS beta0
FROM ad_sales;
```

## 6. Oracle 예상 결과

`beta1=0.6, beta0=2.2, predict_at_x6=5.8, r_squared=0.6` (손계산과 일치 —
**실제 Oracle 검증 필요**)

## 7. SQL Server 예상 결과

`beta1=0.6, beta0=2.2, predict_at_x6=5.8` (Oracle과 동일 — **실제 SQL Server 검증 필요**,
단 SQL Server 스크립트는 `r_squared`를 별도로 계산하지 않았다 — 필요하면
`1 - SSE/SST` 형태로 추가 전개해야 한다)

## 8. 두 DBMS에서 같은 부분

계수 값(`β0=2.2, β1=0.6`)과 예측값(5.8)은 동일하다 — 최소제곱 공식은 DBMS 독립적이다.

## 9. 두 DBMS에서 다른 부분

문제02와 같은 패턴: **Oracle은 전용 집계함수, SQL Server는 수식 전개**. 특히 결정계수
`R²`까지 한 번에 주는 `REGR_R2`가 SQL Server에는 대응 함수가 없어, 필요하면
`1 - SUM((y-ŷ)²)/SUM((y-ȳ)²)`처럼 잔차제곱합까지 직접 계산해야 한다 — 변수가 하나뿐인
단순회귀에서도 이 정도인데, `분석기법/05-회귀분석`처럼 독립변수가 여러 개인 다중회귀로
가면 SQL만으로 정규방정식(행렬 역산)을 직접 푸는 것은 사실상 불가능해진다 — 이것이
`분석기법/`에서 다중회귀의 계수 추정 자체는 Python(`statsmodels`)에 맡기고, SQL은
입력행렬 준비와 결과 검산만 담당하도록 설계한 이유다.

## 10. SQLD 출제 함정

- `REGR_SLOPE(y, x)`처럼 **Y가 먼저, X가 나중**인 인수 순서를 거꾸로 쓰면 기울기의
  역수 관계가 아니라 완전히 다른(잘못된) 값이 나온다 — Oracle `CORR(y,x)`/`REGR_SLOPE(y,x)`
  계열은 관례적으로 종속변수(Y)를 먼저 쓴다는 점을 실수하기 쉽다.

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| Oracle `REGR_SLOPE/INTERCEPT/R2` | `statsmodels.OLS(y, sm.add_constant(x)).fit()` | `lm(y ~ x)` |
| SQL Server 수식 전개 | 위와 동일(내부적으로 같은 정규방정식) | 동일 |

`분석기법/05-회귀분석/02_analyze.py`가 실제로 이 `statsmodels.OLS`를 다중회귀로 확장해
쓰고 있다 — 이 문제는 그 코드가 내부에서 무엇을 계산하는지를 SQL 수준에서 보여준다.

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세션에서 실제 실행 확인(`python3 run_compare.py`): 세 엔진 모두
`beta1=0.6, beta0=2.2, predict_at_x6=5.8`로 일치. DuckDB는 Oracle처럼 `REGR_SLOPE` 등을
지원하고, SQLite·MariaDB는 SQL Server처럼 수식을 직접 전개해야 한다.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
