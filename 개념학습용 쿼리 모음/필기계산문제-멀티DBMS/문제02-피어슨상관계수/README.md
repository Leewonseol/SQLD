---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 02. 피어슨 상관계수 (Oracle · SQL Server)

## 1. 필기 예상문제

> 다음은 5개월간 광고비(X, 백만원)와 매출액(Y, 백만원)이다.
>
> | 월 | 1 | 2 | 3 | 4 | 5 |
> |---|---|---|---|---|---|
> | 광고비(X) | 1 | 2 | 3 | 4 | 5 |
> | 매출액(Y) | 2 | 4 | 5 | 4 | 5 |
>
> 피어슨 상관계수 `r`을 구하시오.

## 2. 손계산

- `x̄=3, ȳ=4`, 공분산(모) `= Σ(x-x̄)(y-ȳ)/n = 6/5 = 1.2`
- `σx=√2≈1.4142`, `σy=√1.2≈1.0954`
- `r = 1.2 / (1.4142×1.0954) ≈ 0.7746` → 강한 양의 선형관계

## 3. 공통 입력 데이터

```
ad_sales(mon, x, y)
(1,1,2), (2,2,4), (3,3,5), (4,4,4), (5,5,5)
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql). Oracle은 `CORR` 집계함수를 내장하고 있어 공식 전개 없이
한 줄로 계산할 수 있다.

```sql
SELECT CORR(y, x) AS r_builtin FROM ad_sales;
```

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql). SQL Server는 `CORR` 자체가 없어 정의식을 그대로
SQL로 옮겨야 한다.

```sql
SELECT (AVG(x*y) - AVG(x)*AVG(y)) / (SQRT(VARP(x)) * SQRT(VARP(y))) AS r_manual
FROM ad_sales;
```

## 6. Oracle 예상 결과

`r_builtin ≈ 0.7746` (손계산과 일치 — **실제 Oracle 검증 필요**)

## 7. SQL Server 예상 결과

`r_manual ≈ 0.7746` (Oracle과 동일한 값 — **실제 SQL Server 검증 필요**)

## 8. 두 DBMS에서 같은 부분

계산 결과 값은 완전히 같다. 상관계수의 수학적 정의 자체가 DBMS와 무관하기 때문이다.

## 9. 두 DBMS에서 다른 부분

**결과가 아니라 "그 결과를 얻기 위한 코드량"이 다르다.** Oracle은 `CORR(y,x)` 한 번
호출로 끝나지만, SQL Server는 문제01의 `VARP`까지 동원해 정의식을 직접 조립해야 한다.
이는 문법 이름이 다른 수준이 아니라 **기능 자체의 유무** 차이이며, 실기에서 SQL Server
환경이 주어졌을 때 "상관계수 공식을 그대로 SQL로 옮길 수 있는가"를 직접 시험하는
지점이 된다.

## 10. SQLD 출제 함정

- "상관계수는 SQL 한 줄로 구할 수 있다"는 인상은 Oracle 한정이다. SQL Server 문제에서
  `CORR`을 그대로 썼다가 함수가 없다는 오류를 만나는 것이 전형적인 실수다.
- `COVAR_POP`/`COVAR_SAMP`도 SQL Server에는 없다(Oracle에는 있음) — 공분산부터 직접
  풀어야 한다는 점을 기억해야 한다.

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| Oracle `CORR(y,x)` | `numpy.corrcoef(x,y)[0,1]`, `scipy.stats.pearsonr(x,y)` | `cor(x,y)` |
| SQL Server 수식 전개 | 위와 동일(라이브러리가 내부적으로 같은 공식을 계산) | 동일 |

`분석기법/03-요인분석`의 `survey_correlation_matrix`(SQL 자기조인 상관행렬)가 바로
이 SQL Server식 "수식 직접 전개" 패턴을 여러 변수 쌍으로 확장한 것이다.

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세션에서 실제 실행 확인(`python3 run_compare.py`): 세 엔진 모두 `r≈0.7746`으로
Oracle·SQL Server 예상 결과와 일치한다. DuckDB는 Oracle처럼 `CORR` 내장함수를 지원하고,
SQLite·MariaDB는 SQL Server처럼 공식을 직접 전개해야 한다 — 즉 "내장함수 있음/없음"
축에서 Oracle·DuckDB가 한편, SQL Server·SQLite·MariaDB가 다른 편이다.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
