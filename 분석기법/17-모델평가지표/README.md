---
type: technique
pilot: true
category: 모델검증
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 모델 평가 지표 — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 여러 임계값(0.1~0.9)에 대한 혼동행렬을 한 번에 집계한 `eval_threshold_sweep` 생성 |
| Python (`02_analyze.py`) | `sklearn.metrics`로 정밀도·재현율·F1·ROC-AUC·RMSE·MAE·MAPE·R² 계산 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 임계값 0.5 기준 정밀도·재현율 재계산해 대조 |

## 두 DBMS에서 같은 부분

- 임계값 스윕(상수 목록 + `CROSS JOIN`)과 `NULLIF`(0으로 나누기 방지)는 두 DBMS에서
  문법이 동일하다. `NULLIF`는 표준 SQL이라 SQLD가 다루는 다섯 DBMS 전부에서 같은
  이름으로 동작하는 몇 안 되는 함수 중 하나다.

## 두 DBMS에서 다른 부분

- **`FROM` 없는 `SELECT`**: 임계값 상수 목록(`SELECT 0.1 UNION ALL SELECT 0.2 ...`)을
  SQL Server는 `FROM` 절 없이 그대로 쓸 수 있지만, **Oracle은 `SELECT` 뒤에 반드시
  `FROM`이 있어야 해서** `SELECT 0.1 FROM DUAL`처럼 더미 테이블 `DUAL`을 명시해야
  한다 — Oracle만 가진 독특한 제약이다.
- **정수 나눗셈**: `TP`, `FP` 등이 Oracle에서는 `NUMBER`(캐스팅 불필요), SQL Server에서는
  `INT`(모든 나눗셈에 `1.0 *` 필요) — 이 실습 전체에서 반복된 패턴이 정밀도·재현율·F1
  계산에도 그대로 적용된다.

## SQLD 출제 함정

- `DUAL`은 Oracle 전용 더미 테이블이다. SQL Server에는 대응 개념이 없다는 것 자체가
  시험에서 "Oracle 전용 요소를 고르시오" 유형 문제의 단골 정답이다.

## 실행

```bash
# 사전 준비 (한 번만): 05, 06 폴더의 결과가 DB에 있어야 함 (Oracle/SQL Server 각각)
python3 02_analyze.py   # 06-로지스틱회귀, 05-회귀분석에서도 동일하게 실행

# Oracle / SQL Server: *_oracle.sql, *_sqlserver.sql을 각 환경에 복사해 실행 (이 저장소에서 실행 불가)

# 보조(SQLite, 이 저장소에서 실제 실행 확인됨):
(cd ../05-회귀분석 && python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql && python3 02_analyze.py)
(cd ../06-로지스틱회귀 && python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql && python3 02_analyze.py)
python3 ../_data/run_sql.py optional/01_prepare_sqlite.sql
python3 02_analyze.py
python3 ../_data/run_sql.py optional/03_verify_sqlite.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 정밀도·재현율·F1 | `precision_score`, `recall_score`, `f1_score` |
| ROC-AUC | `roc_curve`, `auc` (또는 `roc_auc_score`) |
| RMSE·MAE·R² | `mean_squared_error(squared=False)`, `mean_absolute_error`, `r2_score` |
| R 대응 | `caret::confusionMatrix()`, `pROC::roc()`, `Metrics::rmse()` |
