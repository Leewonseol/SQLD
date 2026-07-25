---
type: technique
pilot: true
category: 차원축소
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 주성분분석 (PCA) — Oracle · SQL Server 중심

## 필기 공식

- 공분산행렬 분해: `Σv = λv` (λ: 고유값, v: 고유벡터)
- 설명분산비율(기여율): `λᵢ / Σλⱼ`
- 누적기여율: 앞 k개 성분의 기여율 누적 합 (보통 70~80% 이상을 기준으로 성분 개수 결정)
- Kaiser 기준: 고유값 `λ > 1`인 성분만 채택
- 성분점수(Score): `Z · V` (Z: 표준화된 데이터, V: 고유벡터 행렬)
- **표준화가 선행되어야 하는 이유**: 변수 간 단위·척도가 다르면 분산이 큰 변수가
  주성분을 지배하므로, PCA 전 반드시 평균 0·표준편차 1로 표준화한다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | `customer_features`의 7개 수치형 변수를 표준화하여 `pca_input` 테이블 생성 |
| Python (`02_analyze.py`) | `sklearn.decomposition.PCA`로 고유값·고유벡터(적재량)·성분점수 산출, 결과를 `pca_variance`/`pca_loadings`/`pca_scores` 테이블로 저장 (현재는 보조 SQLite DB 대상으로 구현됨 — Oracle/SQL Server 연결로 바꾸는 방법은 아래 "Python 연결 전환" 참고) |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 누적기여율 확인, 성분점수 상하위 고객 조회, 원본 행 수와 결과 행 수 일치 검산 |

## Oracle SQL

[`01_prepare_oracle.sql`](./01_prepare_oracle.sql), [`03_verify_oracle.sql`](./03_verify_oracle.sql).
핵심은 **파티션 없는 윈도우 함수**로 표준화를 한 번에 처리하는 것이다.

```sql
SELECT customer_id,
       (age - AVG(age) OVER()) / STDDEV_POP(age) OVER() AS age_z
FROM customer_features;
```

## SQL Server SQL

[`01_prepare_sqlserver.sql`](./01_prepare_sqlserver.sql), [`03_verify_sqlserver.sql`](./03_verify_sqlserver.sql).
구조는 동일하고 함수 이름만 다르다.

```sql
SELECT customer_id,
       (age - AVG(age) OVER()) / STDEVP(age) OVER() AS age_z
INTO pca_input
FROM customer_features;
```

## Oracle 예상 결과

`pca_input`의 모든 표준화 컬럼은 평균 0, 분산 1 — `mean_age_z=0, var_age_z=1, n=1000`.
(합성 데이터는 이 세션에서 실제로 만들었으므로 정확한 원본값이 존재하지만,
**Oracle 실행 자체는 검증하지 않았다**)

## SQL Server 예상 결과

Oracle과 동일: `mean_age_z=0, var_age_z=1, n=1000`. (**실제 SQL Server 검증 필요**)

## 두 DBMS에서 같은 부분

- 표준화 결과 값은 이론상 동일하다 — 정의가 DBMS와 무관한 수학 공식이기 때문.
- **둘 다 파티션 없는 `OVER()`로 표준편차를 윈도우 함수처럼 쓸 수 있어, SQL Server/
  Oracle 버전은 `optional/01_prepare_sqlite.sql`의 `CROSS JOIN` 서브쿼리 구조가
  필요 없다.** SQLite는 이 윈도우 집계를 지원하지 않아 부득이 CROSS JOIN으로
  평균·표준편차를 미리 계산한 뒤 조인했다 — Oracle/SQL Server 버전이 오히려 더
  간결하다.

## 두 DBMS에서 다른 부분

- 함수 이름: `STDDEV_POP`(Oracle) ↔ `STDEVP`(SQL Server).
- 테이블 생성 문법: Oracle `CREATE TABLE ... AS SELECT`, SQL Server `SELECT ... INTO
  ... FROM`.
- 결측치 처리 예시(이 합성 데이터엔 결측이 없지만 실기에서 있다면): Oracle `NVL(age,
  대체값)`, SQL Server `ISNULL(age, 대체값)`.
- CSV 적재: Oracle `SQL*Loader`, SQL Server `BULK INSERT` — 둘 다 문법 예시만 남기고
  이 세션에서 실행하지 않았다.

## SQLD 출제 함정

- `STDDEV_POP`/`STDEVP`처럼 "모집단" 통계량 함수를 표준화(Z-score) 공식에 써야 한다는
  점을 놓치고 표본 통계량(`STDDEV`/`STDEV`)을 쓰면, n이 작을 때 표준화 결과가 미세하게
  달라진다(`필기계산문제-멀티DBMS/문제01` 참고 — 이 문제는 표본 크기 1,000명이라
  차이가 실질적으로 작지만, 표본 크기가 작은 문제에서는 오차가 커진다).

## Python 연결 전환 (SQLite → Oracle/SQL Server)

`02_analyze.py`는 현재 `분석기법/_data/dbutil.get_conn()`으로 보조 SQLite DB에
연결한다. 실제 Oracle/SQL Server에 연결하려면:

```python
# Oracle: import oracledb; conn = oracledb.connect(...)
# SQL Server: import pyodbc; conn = pyodbc.connect(...)
```
로 `get_conn()` 호출부만 바꾸면 나머지 `pandas.read_sql`/`to_sql` 로직은 그대로
재사용할 수 있다 — `03_verify_oracle.sql`/`03_verify_sqlserver.sql` 상단의 테이블
DDL이 `to_sql`이 만들어야 할 스키마와 일치하도록 미리 맞춰 두었다.

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 고유값 λ | `pca.explained_variance_` |
| 설명분산비율 | `pca.explained_variance_ratio_` |
| 고유벡터(적재량) | `pca.components_` |
| 성분점수 | `pca.transform(Z)` |
| R 대응 | `prcomp(x, scale.=TRUE)$sdev^2`, `$rotation`, `$x` |

## 보조 DBMS (SQLite) — 이 저장소에서 실제로 실행 확인됨

`optional/01_prepare_sqlite.sql`, `optional/03_verify_sqlite.sql`이 SQLite 기준
버전이다. 이 세션에서 실제로 실행해 `PC1 eigenvalue=2.9035, 설명분산비율=0.4144`
등 구체적인 수치를 확인했다(합성 데이터가 실제로 이 저장소 안에 있기 때문에
SQLite는 유일하게 "예상 결과"가 아니라 "실측 결과"를 낼 수 있는 엔진이다).

```bash
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql
```
