---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 06. Z-score 표준화 · Min-Max 정규화 (Oracle · SQL Server)

## 1. 필기 예상문제

> [문제01]의 5개 매장 매출액(12,15,11,18,14)을 Z-score로 표준화하고, Min-Max로
> 0~1 범위로 정규화하시오.

## 2. 손계산

- `x̄=14, σ≈2.449`(모표준편차), `min=11, max=18`
- A(12): `z≈-0.816`, `minmax≈0.143`
- D(18): `z≈1.633`, `minmax=1.0`(최댓값은 항상 1)
- C(11): `minmax=0`(최솟값은 항상 0)

## 3. 공통 입력 데이터

```
sales(store, amount)
('A',12), ('B',15), ('C',11), ('D',18), ('E',14)
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql). 파티션 없는 윈도우 함수로 행 단위 변환:

```sql
SELECT amount, (amount - AVG(amount) OVER()) / STDDEV_POP(amount) OVER() AS z_score
FROM sales;
```

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql). 함수 이름만 바뀔 뿐 구조는 동일:

```sql
SELECT amount, (amount - AVG(amount) OVER()) / STDEVP(amount) OVER() AS z_score
FROM sales;
```

## 6. Oracle 예상 결과

`A: z≈-0.816, minmax≈0.143` 등 5행, 손계산과 일치. (**실제 Oracle 검증 필요**)

## 7. SQL Server 예상 결과

Oracle과 동일한 5행 결과. (**실제 SQL Server 검증 필요**)

## 8. 두 DBMS에서 같은 부분

- 파티션 없는 `OVER()`로 통계함수를 윈도우 함수처럼 쓰는 방식 자체가 동일하다 —
  두 DBMS 모두 `AVG`/`MIN`/`MAX`/표준편차 계열 집계함수를 `OVER()`와 결합할 수 있다.
- 계산 결과 값도 완전히 동일하다.

## 9. 두 DBMS에서 다른 부분

함수 이름만 다르다: `STDDEV_POP`(Oracle) ↔ `STDEVP`(SQL Server). 문제01에서 확인한
이름 대응표가 윈도우 함수 맥락에서도 그대로 적용된다는 것을 보여준다 — **새로운 차이가
아니라 기존 차이(문제01)가 다른 문법(윈도우 함수) 위에서 재현된 사례**다.

## 10. SQLD 출제 함정

- 표준화·정규화를 `GROUP BY`로 풀려는 시도가 흔한 실수다. 이 문제는 그룹별 집계가
  아니라 "행마다 전체 통계량을 적용"하는 것이므로 `GROUP BY` 없는 `OVER()`가 정답이다.
  `GROUP BY`를 쓰면 5행이 1행으로 뭉개져 버린다.

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| Z-score | `sklearn.preprocessing.StandardScaler` | `scale(x)` |
| Min-Max | `sklearn.preprocessing.MinMaxScaler` | `(x-min(x))/(max(x)-min(x))` |

`분석기법/01-PCA/01_prepare.sql`, `분석기법/11-Kmeans/01_prepare.sql`이 이 표준화
패턴(CROSS JOIN 방식이긴 하나 원리는 동일: 전체 평균/표준편차를 모든 행에 broadcast)을
PCA·K-means 입력 준비에 그대로 쓰고 있다.

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세션에서 실제 실행 확인(`python3 run_compare.py`): 세 엔진 모두 동일한 5행 결과.
DuckDB·MariaDB는 Oracle/SQL Server처럼 `STDDEV_POP(x) OVER()`를 그대로 지원하지만,
SQLite는 통계 내장함수 자체가 없어 `SQRT(AVG(x*x) OVER()-AVG(x) OVER()*AVG(x) OVER())`
식으로 윈도우 함수 안에서도 수식을 직접 전개해야 한다.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
