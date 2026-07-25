---
type: technique
pilot: true
category: 차원축소·시각화
---

# 다차원척도법 (MDS)

## 필기 공식

- 목적: 객체 간 거리(비유사도) 행렬만으로 객체를 저차원(보통 2차원) 공간에 배치해 원래
  거리 구조를 최대한 보존한다.
- Stress(적합도 지표): `Stress = sqrt( Σ(dᵢⱼ - d̂ᵢⱼ)² / Σ dᵢⱼ² )`
  - `dᵢⱼ`: 원래 거리, `d̂ᵢⱼ`: 저차원 공간에서 재현된 거리
  - Stress가 작을수록(관례적으로 0.05~0.1 이하) 저차원 배치가 원래 거리 구조를 잘 보존
- Classical MDS: 거리행렬을 이중중심화(double centering) 후 고유값분해로 좌표 산출
  (PCoA와 동일한 원리)
- Metric/Non-metric MDS: 반복적 최적화(stress 최소화)로 좌표를 찾음

## 이번 실습의 분석 단위

고객 개별이 아니라 **지역(주/state)** 을 객체로 삼는다. 주별 고객 특성 평균(소득, 평균
주문액, 만족도, 주문건수, 가입기간)을 표준화한 뒤 지역 간 유클리드 거리를 구하고, 이를
2차원 지도로 압축한다.

> 주의: 고객 수가 적은 주(예: 5~8명)는 평균이 표본오차에 민감해 좌표가 튈 수 있다.
> `01_prepare.sql`의 `HAVING COUNT(*) >= 5` 조건으로 최소 표본 크기를 걸러내지만,
> 실무에서는 지역별 표본 크기 자체도 함께 보고해야 한다(`region_profile.n_customers`).

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 주별 고객 특성 평균을 집계·표준화하고, 지역 쌍 간 거리행렬을 SQL로 직접 계산 |
| Python (`02_analyze.py`) | `sklearn.manifold.MDS(dissimilarity="precomputed")`로 2차원 좌표 추정 |
| SQL (`03_verify.sql`) | 좌표와 stress 결과 조회, 원 특성과 2차원 좌표의 관계 확인 |

## DBMS별 SQL 차이

거리행렬은 자기조인(self-join)으로 만든다. Oracle/SQL Server/SQLite 모두
`SQRT()`, `POWER()` 표준 함수로 동일하게 작성할 수 있다. 차이는 반올림 함수 정도다.

| DBMS | 거듭제곱/제곱근 |
|---|---|
| Oracle | `POWER(x,2)`, `SQRT(x)` |
| SQL Server | `POWER(x,2)`, `SQRT(x)` |
| SQLite | `x*x` 또는 `POWER(x,2)`(3.35+), `SQRT(x)`(수학 확장 활성화 시) — 이 실습은 `x*x`로 이식성을 높임 |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 거리행렬 `D` | `01_prepare.sql`의 `region_distance` (SQL에서 미리 계산) |
| 좌표 추정 | `MDS(n_components=2, dissimilarity="precomputed").fit_transform(D)` |
| Stress | `mds.stress_` |
| R 대응 | `cmdscale(D)`(classical), `MASS::isoMDS(D)`(non-metric) |
