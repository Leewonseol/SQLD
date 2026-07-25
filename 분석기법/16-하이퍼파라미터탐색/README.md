---
type: technique
pilot: true
category: 모델검증
---

# 하이퍼파라미터 탐색

## 필기 공식

- 하이퍼파라미터: 학습 전에 사람이 지정하는 값(예: 트리 `max_depth`, KNN의 `k`, SVM의 `C`)
  — 학습으로 추정되는 모델 파라미터(계수 등)와 구분된다
- 그리드서치(Grid Search): 후보 값의 모든 조합을 전수 평가
- 랜덤서치(Random Search): 후보 공간에서 무작위로 일부만 샘플링해 평가 (조합이 많을 때 효율적)
- 각 후보 조합은 **교차검증**으로 평가해야 특정 fold에 과적합된 선택을 피할 수 있다
  → [`15-교차검증`](../15-교차검증/README.md)과 이어지는 절차

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | `max_depth × min_samples_leaf` 후보 조합 테이블(그리드)과 5-fold 배정 테이블 생성 |
| Python (`02_analyze.py`) | 각 조합을 5-fold 교차검증으로 평가(그리드서치), 조합별 평균·표준편차 저장 |
| SQL (`03_verify.sql`) | 최적 조합과 결과 순위 조회, 상위/하위 조합 성능 차이 확인 |

## DBMS별 SQL 차이 (그리드 생성)

여러 후보 값을 상수 테이블로 만들고 `CROSS JOIN`하면 모든 조합(그리드)을 SQL만으로
생성할 수 있다. Oracle/SQL Server/SQLite 모두 `UNION ALL`+`CROSS JOIN` 조합은 동일하게 동작한다.

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 그리드서치 | SQL `hp_grid` 테이블을 순회하며 `DecisionTreeClassifier(**params)` 반복 학습 |
| 교차검증으로 평가 | 각 조합마다 5-fold 평균 정확도 계산 |
| 최적 조합 선택 | `hp_search_results`에서 `mean_accuracy` 최댓값 조합 |
| sklearn 대응 도구 | `GridSearchCV(estimator, param_grid, cv=5)` — 이 실습은 원리를 보기 위해 수동 구현 |
| R 대응 | `caret::train(..., tuneGrid=expand.grid(...))` |
