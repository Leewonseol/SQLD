---
type: technique
pilot: true
category: 지도학습-분류
---

# KNN (K-Nearest Neighbors)

## 필기 공식

- 예측 방식: 새 관측치와 가장 가까운 k개 이웃의 **다수결(분류)** 또는 **평균(회귀)** 으로 예측
- 거리 척도(유클리드): `d(x,y) = sqrt(Σ(xᵢ-yᵢ)²)`
- k가 작으면 분산↑(과적합), k가 크면 편향↑(과소적합) — 편향-분산 트레이드오프
- **스케일링 필수**: 거리 기반이므로 변수 단위가 다르면 왜곡된 이웃이 선택된다 (PCA·SVM·K-means와 동일한 이유)
- 게으른 학습(Lazy Learning): 별도 학습 단계 없이 예측 시점에 전체 데이터를 탐색

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 특성 표준화, 학습/평가 분할 |
| Python (`02_analyze.py`) | `sklearn.neighbors.KNeighborsClassifier`로 k=3,5,7,9,11 각각 학습·평가 |
| SQL (`03_verify.sql`) | k별 정확도 비교, 최적 k에서의 혼동행렬 확인 |

> k 자체를 체계적으로 탐색하는 절차(후보 그리드 → 교차검증 → 최적값 선택)는
> [`16-하이퍼파라미터탐색`](../16-하이퍼파라미터탐색/README.md)에서 정식으로 다룬다.
> 이 폴더는 KNN 알고리즘 자체와 k 변화에 따른 경향을 보는 데 집중한다.

## DBMS별 SQL 차이

표준화 방식은 [`01-PCA`](../01-PCA/README.md)와 동일하다. SQLite는 `STDDEV` 내장함수가
없어 `SQRT(AVG(x*x)-AVG(x)*AVG(x))`로 직접 계산하며, Oracle/SQL Server는 `STDDEV`/`STDEV`로
대체 가능하다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 유클리드 거리, k개 이웃 다수결 | `KNeighborsClassifier(n_neighbors=k, metric="euclidean")` |
| 편향-분산 트레이드오프 | k값을 바꿔가며 `knn_k_comparison` 테이블의 정확도 추이 확인 |
| R 대응 | `class::knn(train, test, cl, k=5)` |
