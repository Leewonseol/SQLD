---
type: technique
pilot: true
category: 차원축소·행렬분해
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# SVD · NMF (행렬분해) — Oracle · SQL Server 중심

## 필기 공식

- 특이값분해(SVD): `A = U Σ Vᵀ`
  - `U`: 좌특이벡터(행 개체 축), `Σ`: 특이값 대각행렬, `Vᵀ`: 우특이벡터(열 개체 축)
  - 상위 k개 특이값만 사용한 절단(truncated) SVD로 원행렬을 근사: `A ≈ Uₖ Σₖ Vₖᵀ`
- 비음수행렬분해(NMF): `A ≈ W H` (단, `A, W, H`의 모든 원소 ≥ 0)
  - 음수가 없는 데이터(구매금액, 평점 등)에 적합, 해석하기 쉬운 "부분 기반" 표현을 만든다
- 재구성 오차: `||A - Â||` (보통 Frobenius norm, RMSE로 요약)

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | `customer_category_spend`(롱포맷)를 고객×카테고리 wide 행렬로 PIVOT |
| Python (`02_analyze.py`) | `numpy.linalg.svd`로 SVD, `sklearn.decomposition.NMF`로 NMF 수행, 인자행렬·특이값·재구성오차를 테이블로 저장 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 특이값 크기·기여율 조회, 셀 단위 재구성 오차 요약 |

## 두 DBMS에서 같은 부분

- **둘 다 `PIVOT` 연산자를 네이티브로 지원한다**(Oracle 11g+, SQL Server 2005+) —
  SQLite처럼 `SUM(CASE WHEN category='전자제품' THEN amount ELSE 0 END)`을 카테고리
  개수만큼 반복해서 손으로 풀 필요가 없다. 이 저장소의 [[PIVOT·UNPIVOT]] 개념 노트가
  다루는 문법이 바로 이것이다.
- **PIVOT 결과가 NULL을 채운다는 점도 두 DBMS가 같다.** 어떤 고객이 특정 카테고리를
  한 번도 사지 않았다면 PIVOT은 그 셀을 `0`이 아니라 `NULL`로 채운다(SQLite의
  `SUM(CASE...ELSE 0)`은 애초에 0을 채워 이 문제가 없었다) — 그래서 두 스크립트 모두
  `NVL`/`ISNULL`로 결과를 감싸 NMF의 비음수 제약(값이 없는 것과 0인 것은 다르다)을
  지킨다.

## 두 DBMS에서 다른 부분 — PIVOT 세부 문법

| 항목 | Oracle | SQL Server |
|---|---|---|
| 값 목록 표기 | `FOR category IN ('전자제품' AS 전자제품, ...)` — 원본값과 별칭을 `AS`로 짝지음 | `FOR category IN ([전자제품], ...)` — 별칭 없이 컬럼명이 될 값만 나열, 대괄호 필수 |
| 컬럼명 규칙 | 큰따옴표 없으면 대문자로 저장(자료형 노트 참고) | 대괄호로 감싸면 대소문자·특수문자 그대로 유지 |

## SQLD 출제 함정

- `PIVOT`을 "Oracle 전용"으로 잘못 아는 경우가 많다 — SQL Server도 지원하며, 오히려
  **SQLite·초기 MySQL이 PIVOT을 지원하지 않는 쪽**이다(19-연관규칙에서도 같은 논리가
  반복된다).

## 실행

```bash
# Oracle / SQL Server: *_oracle.sql, *_sqlserver.sql을 각 환경에 복사해 실행 (이 저장소에서 실행 불가)
python3 02_analyze.py

# 보조(SQLite, 이 저장소에서 실제 실행 확인됨):
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| `U, Σ, Vᵀ` | `numpy.linalg.svd(A, full_matrices=False)` |
| 절단 SVD `Uₖ Σₖ Vₖᵀ` | `U[:, :k] @ np.diag(S[:k]) @ Vt[:k, :]` |
| `A ≈ W H` (NMF) | `NMF(n_components=k).fit_transform(A)` → `W`, `.components_` → `H` |
| 재구성 오차 | `np.linalg.norm(A - A_hat)` / RMSE |
| R 대응 | `svd(A)`, `NMF::nmf(A, rank=k)` |
