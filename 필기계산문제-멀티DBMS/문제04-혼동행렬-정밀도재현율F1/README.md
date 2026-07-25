---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 04. 혼동행렬 기반 정밀도·재현율·F1 (Oracle · SQL Server)

## 1. 필기 예상문제

> 어떤 이탈예측 모델을 10명의 고객에게 적용한 실제값(actual)과 예측값(predicted)이
> 다음과 같다(1=이탈, 0=정상).
>
> | 고객 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
> |---|---|---|---|---|---|---|---|---|---|---|
> | 실제 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
> | 예측 | 1 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 |
>
> 혼동행렬을 작성하고 정확도, 정밀도, 재현율, F1-score를 구하시오.

## 2. 손계산

| | 예측 1 | 예측 0 |
|---|---|---|
| 실제 1 | TP=3 | FN=1 |
| 실제 0 | FP=1 | TN=5 |

- 정확도 `=(TP+TN)/10=0.8`, 정밀도 `=TP/(TP+FP)=0.75`, 재현율 `=TP/(TP+FN)=0.75`,
  F1 `=2×0.75×0.75/1.5=0.75`

## 3. 공통 입력 데이터

```
preds(customer_id, actual, predicted)  -- 10행, 위 표 그대로
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql). `actual`, `predicted`를 `NUMBER`로 선언하고, 캐스팅 없이
그대로 나눗셈을 수행한다.

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql). `actual`, `predicted`를 `INT`로 선언하고, (A) 캐스팅
없는 버전과 (B) `1.0 *`로 실수 승격시킨 버전을 나란히 실행한다.

## 6. Oracle 예상 결과

`tp=3, fp=1, tn=5, fn=1, precision_no_cast=0.75` — **캐스팅 없이도 정답이 나온다.**
Oracle `NUMBER`는 정수처럼 보이는 값이라도 나눗셈이 항상 완전한 정밀도로 계산되기
때문이다. (**실제 Oracle 검증 필요**)

## 7. SQL Server 예상 결과

(A) `precision_no_cast = 0` — **오답.** `INT`컬럼에서 만든 `SUM(CASE...)`은 `INT`이고,
`INT/INT`는 SQL Server에서 정수 나눗셈이라 `3/4`의 소수부가 잘려 0이 된다.
(B) `precision_cast=0.75, recall_cast=0.75, accuracy_cast=0.8` — `1.0 *`으로 실수
승격시킨 뒤에야 정답이 나온다. (**실제 SQL Server 검증 필요**)

## 8. 두 DBMS에서 같은 부분

**최종적으로 캐스팅을 올바르게 적용하면 두 DBMS 모두 같은 값(0.75, 0.75, 0.8)에
도달한다.** 정밀도·재현율·F1 공식 자체는 동일하다.

## 9. 두 DBMS에서 다른 부분 — 이 문제의 핵심: 캐스팅 없이 실행하면 실제로 값이 달라진다

이 문제는 이 폴더 전체에서 **"문법이 아니라 결과 자체가 실제로 달라지는" 가장 분명한
사례**다.

| | 캐스팅 없이 `TP/(TP+FP)` |
|---|---|
| Oracle(`NUMBER`) | `0.75` (정답) |
| SQL Server(`INT`) | `0` (오답 — 정수 나눗셈으로 소수부 소실) |

같은 논리로 작성한 같은 모양의 SQL이 자료형 하나(`NUMBER` vs `INT`) 때문에 실제로
다른 숫자를 내놓는다. 이는 [[DBMS 문법 차이(Oracle-SQLServer)]] 노트의 "정수 나눗셈"
항목이 실전에서 어떻게 사고로 이어지는지 보여주는 예다.

## 10. SQLD 출제 함정

- 혼동행렬 지표 계산 문제에서 `SUM(CASE WHEN ... THEN 1 ELSE 0 END)`으로 만든 카운트를
  나눌 때, SQL Server 환경이면 반드시 `1.0 *`(또는 `CAST(... AS FLOAT)`)을 곱해야 한다.
  이 캐스팅을 빠뜨리는 것이 SQL Server 실기에서 가장 흔한 "계산 논리는 맞는데 답이
  틀리는" 유형의 오답이다.
- Oracle 환경에 익숙한 상태로 SQL Server 문제를 풀면 이 캐스팅 습관 자체가 없어서
  틀리기 쉽다 — 반대로 SQL Server에 익숙하면 Oracle에서는 필요 없는 캐스팅을 습관적으로
  넣어도(해가 되지는 않음) 무방하다.

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| 혼동행렬 지표 | `sklearn.metrics.precision_score/recall_score/f1_score` | `caret::confusionMatrix()` |

Python/R은 애초에 부동소수점 나눗셈이 기본이라 이런 정수 나눗셈 함정이 없다 — SQL
Server SQL을 작성할 때만 특별히 조심해야 하는, DBMS 고유의 문제라는 점이 중요하다.
`분석기법/06-로지스틱회귀/03_verify.sql`, `Olist-고객데이터`의 여러 검산 쿼리에서
`1.0 * ...` 패턴을 일관되게 쓴 이유가 바로 이것이다(그 쿼리들은 SQLite 기준으로
작성됐는데, SQLite도 SQL Server와 마찬가지로 정수 나눗셈을 잘라내기 때문).

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세션에서 실제 실행 확인(`python3 run_compare.py`): **SQLite도 SQL Server와 같은
정수 나눗셈 문제를 보인다**(`3/4=0`). DuckDB와 MariaDB는 Oracle처럼 정수 나눗셈이라도
자동으로 실수 승격시켜 캐스팅 없이도 `0.75`가 나온다. 즉 이 축에서는
"Oracle·DuckDB·MariaDB(자동 승격)" 대 "SQL Server·SQLite(수동 캐스팅 필요)"로 갈린다 —
SQL Server 학습자에게는 SQLite 실습 결과가 그대로 관련 있는 경고가 된다.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
