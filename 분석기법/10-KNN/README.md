---
type: technique
pilot: true
category: 지도학습-분류
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# KNN (K-Nearest Neighbors) — Oracle · SQL Server 중심

## 필기 공식

- 예측 방식: 새 관측치와 가장 가까운 k개 이웃의 **다수결(분류)** 또는 **평균(회귀)** 으로 예측
- 거리 척도(유클리드): `d(x,y) = sqrt(Σ(xᵢ-yᵢ)²)`
- k가 작으면 분산↑(과적합), k가 크면 편향↑(과소적합) — 편향-분산 트레이드오프
- **스케일링 필수**: 거리 기반이므로 변수 단위가 다르면 왜곡된 이웃이 선택된다 (PCA·SVM·K-means와 동일한 이유)
- 게으른 학습(Lazy Learning): 별도 학습 단계 없이 예측 시점에 전체 데이터를 탐색

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 특성 표준화, 학습/평가 분할 |
| Python (`02_analyze.py`) | `sklearn.neighbors.KNeighborsClassifier`로 k=3,5,7,9,11 각각 학습·평가 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, k별 정확도 비교, 최적 k에서의 혼동행렬 확인 |

> k 자체를 체계적으로 탐색하는 절차(후보 그리드 → 교차검증 → 최적값 선택)는
> [`16-하이퍼파라미터탐색`](../16-하이퍼파라미터탐색/README.md)에서 정식으로 다룬다.
> 이 폴더는 KNN 알고리즘 자체와 k 변화에 따른 경향을 보는 데 집중한다.

## 두 DBMS에서 같은 부분 / 다른 부분

표준화·분할 구조는 [`07-SVM`](../07-SVM/README.md)과 완전히 동일한 패턴이다
(파티션 없는 `OVER()` + `ROW_NUMBER()` 기반 분할). Oracle `STDDEV_POP`, SQL Server
`STDEVP`만 다르다 — 새로운 차이는 없다는 점 자체가 이 실습의 기록할 만한 결과다.

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
| 유클리드 거리, k개 이웃 다수결 | `KNeighborsClassifier(n_neighbors=k, metric="euclidean")` |
| 편향-분산 트레이드오프 | k값을 바꿔가며 `knn_k_comparison` 테이블의 정확도 추이 확인 |
| R 대응 | `class::knn(train, test, cl, k=5)` |
