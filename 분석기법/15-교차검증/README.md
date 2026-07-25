---
type: technique
pilot: true
category: 모델검증
---

# 교차검증 (Cross-Validation)

## 필기 공식

- K-Fold 교차검증: 데이터를 k개 fold로 나눠, 매번 1개 fold를 검증셋으로 나머지 k-1개를
  학습셋으로 사용 — 총 k번 반복해 k개의 성능 지표를 얻는다
- 평균 성능: `(1/k) Σ scoreᵢ`, 분산(안정성 지표): `(1/k) Σ (scoreᵢ - 평균)²`
- 목적: 단일 train/test 분할보다 데이터 활용도가 높고, 성능 추정의 분산을 줄인다
- 층화 K-Fold(Stratified K-Fold): 클래스 비율이 불균형할 때 각 fold의 클래스 비율을
  원본과 동일하게 유지

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 고객마다 fold 번호(1~5)를 결정적으로 배정한 `cv_folds` 테이블 생성, fold별 클래스 비율 확인(층화 여부 점검) |
| Python (`02_analyze.py`) | fold를 SQL이 정한 대로 그대로 사용해 `DecisionTreeClassifier`를 5번 학습·평가 |
| SQL (`03_verify.sql`) | fold별 성능 집계, 평균·표준편차 계산, sklearn 결과와 SQL 재계산 비교 |

## DBMS별 SQL 차이

fold 배정은 `customer_id`(문자열)의 해시값을 5로 나눈 나머지로 결정적으로 만든다.

| DBMS | 문자열 해시 |
|---|---|
| Oracle | `ORA_HASH(customer_id, 4)` (0~4, 5개 값) |
| SQL Server | `ABS(CHECKSUM(customer_id)) % 5` |
| SQLite | 내장 해시 함수 없음 → 이 실습은 `ROWID % 5` (행 생성 순서가 고정이므로 재현 가능) 사용 |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| fold 분할 | SQL이 만든 `cv_folds.fold` 컬럼을 그대로 사용(수동 K-Fold) |
| fold별 학습·평가 | `for fold in range(1,6): ...` 반복문 |
| 평균·표준편차 | `cv_fold_results.accuracy.mean()`, `.std()` |
| R 대응 | `caret::trainControl(method="cv", number=5)` |
