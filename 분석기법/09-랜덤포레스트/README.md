---
type: technique
pilot: true
category: 지도학습-분류
---

# 랜덤 포레스트 (Random Forest)

## 필기 공식

- 앙상블 원리: 여러 개의 결정나무를 **부트스트랩 샘플링(bagging)** 으로 각각 다르게 학습시킨 뒤
  다수결(분류) 또는 평균(회귀)으로 최종 예측
- 변수 무작위 선택: 각 분할마다 전체 변수 중 일부(보통 `√p`개, `p`=변수 개수)만 후보로 사용해
  트리 간 상관을 낮춤
- OOB(Out-of-Bag) 오차: 부트스트랩에서 뽑히지 않은 표본으로 검증 → 별도 검증셋 없이도 일반화 성능 추정 가능
- 변수중요도: 각 변수가 노드 분할에서 불순도를 얼마나 줄였는지의 평균(트리 전체 합산)

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 학습 데이터 구성, 파생변수(주문액 구간) 생성 |
| Python (`02_analyze.py`) | `sklearn.ensemble.RandomForestClassifier` 학습(OOB 포함), 변수중요도·예측값 저장 |
| SQL (`03_verify.sql`) | 변수중요도 집계, 예측값 vs 실제값 교차표, 평가지표 재계산 |

## DBMS별 SQL 차이

의사결정나무와 동일하게 `CASE WHEN` 기반 구간화를 사용한다. 별도 DBMS 차이는 없으며,
[`08-의사결정나무`](../08-의사결정나무/README.md)의 표를 그대로 참고하면 된다.

## 실행

`03_verify.sql`은 [`08-의사결정나무`](../08-의사결정나무/README.md)가 만든
`tree_feature_importance`와 비교하는 쿼리를 포함하므로, 08 폴더를 먼저 실행해두면
더 풍부한 비교가 가능하다(먼저 실행하지 않아도 랜덤포레스트 자체 결과 확인에는 문제 없음).

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| Bagging(부트스트랩) | `RandomForestClassifier(n_estimators=200, bootstrap=True)` |
| OOB 오차 | `RandomForestClassifier(oob_score=True).oob_score_` |
| 변수 무작위 선택(√p) | `max_features="sqrt"` |
| 변수중요도 | `model.feature_importances_` |
| R 대응 | `randomForest::randomForest(churned ~ ., data=df, importance=TRUE)` |
