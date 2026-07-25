---
type: technique
pilot: true
category: 차원축소·행렬분해
---

# SVD · NMF (행렬분해)

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
| SQL (`01_prepare.sql`) | `customer_category_spend`(롱포맷)를 고객×카테고리 wide 행렬로 PIVOT |
| Python (`02_analyze.py`) | `numpy.linalg.svd`로 SVD, `sklearn.decomposition.NMF`로 NMF 수행, 인자행렬·특이값·재구성오차를 테이블로 저장 |
| SQL (`03_verify.sql`) | 특이값 크기·기여율 조회, 셀 단위 재구성 오차 요약, 원본 vs 재구성값 비교 |

## DBMS별 SQL 차이 (PIVOT)

| DBMS | 롱→와이드 변환 |
|---|---|
| Oracle 11g+ | `PIVOT (SUM(amount) FOR category IN ('전자제품' AS 전자제품, ...))` |
| SQL Server | `PIVOT (SUM(amount) FOR category IN ([전자제품], ...)) AS p` |
| SQLite | 내장 PIVOT 없음 → `SUM(CASE WHEN category = '전자제품' THEN amount ELSE 0 END)` 조건부 집계로 대체 |

이 저장소의 [[PIVOT·UNPIVOT]] 개념 노트와 동일한 논리이며, SQLite에서는 조건부 `SUM(CASE WHEN ...)`
패턴이 곧 수동 PIVOT이다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| `U, Σ, Vᵀ` | `numpy.linalg.svd(A, full_matrices=False)` |
| 절단 SVD `Uₖ Σₖ Vₖᵀ` | `U[:, :k] @ np.diag(S[:k]) @ Vt[:k, :]` |
| `A ≈ W H` (NMF) | `NMF(n_components=k).fit_transform(A)` → `W`, `.components_` → `H` |
| 재구성 오차 | `np.linalg.norm(A - A_hat)` / RMSE |
| R 대응 | `svd(A)`, `NMF::nmf(A, rank=k)` |
