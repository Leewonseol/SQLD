---
type: technique
pilot: true
category: 모델검증
---

# 모델 평가 지표

## 필기 공식

### 분류 지표 (혼동행렬 기반)

|            | 예측 Positive | 예측 Negative |
|---|---|---|
| 실제 Positive | TP | FN |
| 실제 Negative | FP | TN |

- 정확도(Accuracy): `(TP+TN) / (TP+FP+TN+FN)`
- 정밀도(Precision): `TP / (TP+FP)` — Positive로 예측한 것 중 실제 Positive 비율
- 재현율(Recall, 민감도): `TP / (TP+FN)` — 실제 Positive 중 맞춘 비율
- F1-score: `2 · Precision · Recall / (Precision + Recall)` (정밀도·재현율의 조화평균)
- 특이도(Specificity): `TN / (TN+FP)`
- ROC-AUC: ROC 곡선(재현율 vs 1-특이도) 아래 면적, 1에 가까울수록 좋음

### 회귀 지표

- RMSE: `sqrt( (1/n)Σ(yᵢ-ŷᵢ)² )`
- MAE: `(1/n)Σ|yᵢ-ŷᵢ|`
- MAPE: `(100/n)Σ|((yᵢ-ŷᵢ)/yᵢ)|`
- R²: `1 - SS_res/SS_tot`

## 이번 실습의 분석 단위

[`06-로지스틱회귀`](../06-로지스틱회귀/README.md)의 `logistic_predictions`(분류)와
[`05-회귀분석`](../05-회귀분석/README.md)의 `regression_predictions`(회귀)를 재사용해
공식대로 지표를 계산하고 SQL로 검산한다. **05, 06 폴더를 먼저 실행해야 한다.**

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 여러 임계값(0.1~0.9)에 대한 혼동행렬을 한 번에 집계한 `eval_threshold_sweep` 생성 |
| Python (`02_analyze.py`) | `sklearn.metrics`로 정밀도·재현율·F1·ROC-AUC·RMSE·MAE·MAPE·R² 계산 |
| SQL (`03_verify.sql`) | 임계값 0.5 기준 정밀도·재현율을 SQL로 직접 재계산해 Python 결과와 대조 |

## DBMS별 SQL 차이

임계값 스윕은 상수 테이블(`UNION ALL`)과 `CROSS JOIN`으로 만든다 —
[`16-하이퍼파라미터탐색`](../16-하이퍼파라미터탐색/README.md)의 그리드 생성과 같은 패턴이며
DBMS 간 차이가 없다.

## 실행

```bash
# 사전 준비 (한 번만): 05, 06 폴더의 결과가 DB에 있어야 함
(cd ../05-회귀분석 && python3 ../_data/run_sql.py 01_prepare.sql && python3 02_analyze.py)
(cd ../06-로지스틱회귀 && python3 ../_data/run_sql.py 01_prepare.sql && python3 02_analyze.py)

sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 정밀도·재현율·F1 | `precision_score`, `recall_score`, `f1_score` |
| ROC-AUC | `roc_curve`, `auc` (또는 `roc_auc_score`) |
| RMSE·MAE·R² | `mean_squared_error(squared=False)`, `mean_absolute_error`, `r2_score` |
| R 대응 | `caret::confusionMatrix()`, `pROC::roc()`, `Metrics::rmse()` |
