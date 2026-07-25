---
type: technique
pilot: true
category: 비지도학습-군집
---

# K-means

## 필기 공식

- 목적함수(군집내 제곱합, WCSS/Inertia 최소화):
  `Σₖ Σ_{x∈Cₖ} ||x - μₖ||²` (`μₖ`: k번째 군집 중심)
- 알고리즘(반복):
  1. k개 중심을 초기화
  2. 각 관측치를 가장 가까운 중심에 배정
  3. 각 군집의 새 중심(평균) 계산
  4. 배정이 바뀌지 않을 때까지 2~3 반복
- 최적 k 선택
  - 엘보우(Elbow) 기법: k에 따른 inertia 감소가 완만해지는 지점
  - 실루엣 계수: `-1~1`, 클수록 군집이 잘 분리됨
- **스케일링 필수**: 유클리드 거리 기반이므로 표준화가 선행되어야 한다

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 표준화 데이터 준비(`kmeans_input`) |
| Python (`02_analyze.py`) | k=2..8 엘보우 곡선 계산, 최종 k=4로 `sklearn.cluster.KMeans` 학습, 군집라벨·중심 저장 |
| SQL (`03_verify.sql`) | 군집별 고객 수·중심(원 척도)·주요 특성 분포 집계 |

## DBMS별 SQL 차이

표준화는 [`01-PCA`](../01-PCA/README.md)와 동일한 `SQRT(AVG(x*x)-AVG(x)*AVG(x))` 패턴을 쓴다.
군집별 집계(`GROUP BY cluster`)는 표준 SQL이라 DBMS 차이가 없다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| WCSS/Inertia | `model.inertia_` |
| 군집 중심 μₖ | `model.cluster_centers_` |
| 군집 라벨 | `model.labels_` / `model.predict(X)` |
| 엘보우 기법 | `kmeans_elbow` 테이블(k, inertia) |
| R 대응 | `kmeans(x, centers=4)` |
