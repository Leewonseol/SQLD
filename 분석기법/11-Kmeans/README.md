---
type: technique
pilot: true
category: 비지도학습-군집
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# K-means — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 표준화 데이터 준비(`kmeans_input`), [`01-PCA`](../01-PCA/README.md)와 동일한 윈도우 함수 패턴 |
| Python (`02_analyze.py`) | k=2..8 엘보우 곡선 계산, 최종 k=4로 `sklearn.cluster.KMeans` 학습, 군집라벨·중심 저장 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 군집별 고객 수·중심(원 척도)·주요 특성 분포 집계 |

## 두 DBMS에서 같은 부분 / 다른 부분

표준화는 [`01-PCA`](../01-PCA/README.md)와 동일한 `STDDEV_POP`(Oracle)/`STDEVP`(SQL
Server) 윈도우 함수 패턴을 쓴다. 군집별 집계(`GROUP BY cluster`)는 실제 컬럼 기준이라
두 DBMS 모두 동일하게 동작한다. 유일한 실수 나눗셈 주의점은 `churn_rate` 계산에서
SQL Server의 `l.churned`가 `INT`일 때 `1.0 *`이 필요하다는 것뿐이다.

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
| WCSS/Inertia | `model.inertia_` |
| 군집 중심 μₖ | `model.cluster_centers_` |
| 군집 라벨 | `model.labels_` / `model.predict(X)` |
| 엘보우 기법 | `kmeans_elbow` 테이블(k, inertia) |
| R 대응 | `kmeans(x, centers=4)` |
