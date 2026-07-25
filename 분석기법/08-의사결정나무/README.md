---
type: technique
pilot: true
category: 지도학습-분류
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 의사결정나무 (Decision Tree) — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 학습 데이터 구성(원 척도 그대로), 파생변수(`recency_bucket`), train/test 분할 |
| Python (`02_analyze.py`) | `sklearn.tree.DecisionTreeClassifier` 학습, 변수중요도·예측값 저장 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 변수중요도 순위 조회, 파생변수별 실제 이탈률과 모델 예측 비교 |

## 두 DBMS에서 같은 부분

- `CASE WHEN` 기반 구간화(`recency_bucket`)는 문법이 완전히 동일하다.
- `GROUP BY recency_bucket`은 (별칭이 아니라 `tree_input`에 저장된 실제 컬럼이므로)
  Oracle·SQL Server 모두 문제없이 동작한다 — 06-로지스틱회귀의 "GROUP BY 별칭 불가"
  함정과 겉보기엔 비슷해 보이지만 실제로는 다른 상황임을 구분해야 한다.

## 두 DBMS에서 다른 부분

- train/test 분할: `ROWID % 5`(SQLite) 대신 `ROW_NUMBER() OVER (ORDER BY customer_id)`에
  `MOD`(Oracle)/`%`(SQL Server)를 적용한다(09-랜덤포레스트와 동일한 이유).
- 자동 구간화 보조함수: Oracle `WIDTH_BUCKET(x,min,max,n)`, SQL Server
  `NTILE(n) OVER(ORDER BY x)` — 이 실습처럼 구간 경계(`30/90/180일`)를 직접 지정해야
  하는 문제에서는 두 함수 다 맞지 않아 `CASE WHEN`을 쓴다(자동 구간화는 "N등분"이지
  "특정 경계"가 아니기 때문).

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
| 지니계수 분할 | `DecisionTreeClassifier(criterion="gini")` |
| 가지치기(max_depth) | `DecisionTreeClassifier(max_depth=4)` |
| 변수중요도 | `model.feature_importances_` |
| R 대응 | `rpart(churned ~ ., data=df, method="class")` |
