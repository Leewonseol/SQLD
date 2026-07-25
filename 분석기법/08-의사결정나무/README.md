---
type: technique
pilot: true
category: 지도학습-분류
---

# 의사결정나무 (Decision Tree)

## 필기 공식

- 분할 기준(불순도 지표)
  - 지니계수: `Gini = 1 - Σ pᵢ²`
  - 엔트로피: `Entropy = -Σ pᵢ log₂ pᵢ`
  - 정보이득(Information Gain): `부모 불순도 - Σ(자식 노드 비율 × 자식 불순도)`
- 트리는 정보이득(또는 불순도 감소)이 가장 큰 변수·분할점을 재귀적으로 선택
- 가지치기(Pruning): 과적합 방지를 위해 `max_depth`, `min_samples_leaf` 등으로 트리 크기 제한
- 트리 기반 모델은 **스케일링이 필요 없다** — 분할 기준이 순서(rank)만 사용하기 때문

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 학습 데이터 구성(원 척도 그대로), 파생변수(`recency_bucket`) 생성 |
| Python (`02_analyze.py`) | `sklearn.tree.DecisionTreeClassifier` 학습, 변수중요도·예측값 저장 |
| SQL (`03_verify.sql`) | 변수중요도 순위 조회, 파생변수별 실제 이탈률과 모델 예측 비교 |

## DBMS별 SQL 차이

구간화(bucketing)는 `CASE WHEN`으로 어느 DBMS에서나 동일하게 작성 가능하다. Oracle은
`WIDTH_BUCKET`, SQL Server는 `NTILE`로 자동 구간화를 지원하지만, 구간 경계를 직접
통제하려면 이 실습처럼 `CASE WHEN`이 더 명확하다.

| DBMS | 자동 구간화 보조 함수 |
|---|---|
| Oracle | `WIDTH_BUCKET(x, min, max, n)` |
| SQL Server | `NTILE(n) OVER(ORDER BY x)` |
| SQLite | 해당 함수 없음 → `CASE WHEN`으로 직접 구간 정의 |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 지니계수 분할 | `DecisionTreeClassifier(criterion="gini")` |
| 가지치기(max_depth) | `DecisionTreeClassifier(max_depth=4)` |
| 변수중요도 | `model.feature_importances_` |
| R 대응 | `rpart(churned ~ ., data=df, method="class")` |
