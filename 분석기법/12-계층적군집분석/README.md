---
type: technique
pilot: true
category: 비지도학습-군집
---

# 계층적 군집분석 (Hierarchical Clustering)

## 필기 공식

- K-means와 달리 군집 개수를 미리 정하지 않고, 가장 가까운 두 개체(또는 군집)를
  순차적으로 병합해 나무 구조(덴드로그램)를 만든다.
- 병합 방식(Linkage)
  - 최단연결법(single): 두 군집 간 가장 가까운 점 사이 거리
  - 최장연결법(complete): 두 군집 간 가장 먼 점 사이 거리
  - 평균연결법(average): 모든 점 쌍 거리의 평균
  - Ward법: 병합 시 군집내 분산 증가량이 최소가 되는 쌍을 병합 (가장 널리 사용)
- 덴드로그램의 세로축(병합 거리)이 크게 튀는 지점에서 가지를 자르면 적절한 군집 개수를 정할 수 있다.

## 이번 실습의 분석 단위

덴드로그램을 눈으로 읽을 수 있도록 고객 1,000명 중 40명을 결정적으로 표본추출
(`ROWID % 25 = 0`)해 사용한다. K-means와 같은 7개 표준화 특성을 쓴다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 40명 표본 추출, 특성 표준화 |
| Python (`02_analyze.py`) | `scipy.cluster.hierarchy.linkage(method="ward")`로 병합, `fcluster`로 k=4 절단 |
| SQL (`03_verify.sql`) | 병합 단계별 거리 조회(마지막 병합일수록 거리가 커야 함), 최종 군집별 요약 |

## DBMS별 SQL 차이

특별한 DBMS 차이는 없다. 표준화는 [`01-PCA`](../01-PCA/README.md)와 동일한 방식이다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| Ward 연결법 병합 순서 | `scipy.cluster.hierarchy.linkage(X, method="ward")` |
| 덴드로그램 절단(k개 군집) | `scipy.cluster.hierarchy.fcluster(Z, t=k, criterion="maxclust")` |
| 병합 거리 | `hier_merges.distance` (linkage 행렬의 3번째 열) |
| R 대응 | `hclust(dist(x), method="ward.D2")`, `cutree(hc, k=4)` |
