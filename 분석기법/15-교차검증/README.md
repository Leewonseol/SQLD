---
type: technique
pilot: true
category: 모델검증
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 교차검증 (Cross-Validation) — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 고객마다 fold 번호(1~5)를 해시 기반으로 결정적 배정, fold별 클래스 비율 확인 |
| Python (`02_analyze.py`) | fold를 SQL이 정한 대로 그대로 사용해 `DecisionTreeClassifier`를 5번 학습·평가 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, fold별 성능 집계, 평균·표준편차 계산, sklearn 결과와 SQL 재계산 비교 |

## 두 DBMS에서 같은 부분

- 최종 fold 배정(어떤 고객이 몇 번 fold인지)은 해시 함수가 다르므로 **값 자체는
  다르지만**, fold별 표본 수·이탈률의 균등성이라는 **성질**은 두 DBMS에서 동일하게
  나타난다(해시 기반 배정은 원래 어떤 해시함수를 쓰든 균등 분포를 목표로 하기 때문).

## 두 DBMS에서 다른 부분

| 항목 | Oracle | SQL Server |
|---|---|---|
| 해시 기반 fold 배정 | `ORA_HASH(customer_id, 4) + 1` — 0~4를 바로 반환 | `(ABS(CHECKSUM(customer_id)) % 5) + 1` — `CHECKSUM`이 음수를 반환할 수 있어 `ABS` 필수 |
| 컬럼명 `precision` | 예약어 충돌 위험 → `precision_metric`으로 변경 | 동일하게 `precision_metric` 사용 |

`ORA_HASH`는 버킷 개수(`max_bucket`)를 인수로 받아 그 범위 안의 값을 바로 반환하지만,
`CHECKSUM`은 임의의 부호 있는 정수를 반환하므로 버킷 개수로 나눈 나머지를 직접
계산해야 한다 — "해시 함수가 몇 버킷짜리 값을 직접 주는가, 원시 해시값만 주는가"라는
설계 차이가 그대로 SQL 코드량 차이로 이어진다.

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
| fold 분할 | SQL이 만든 `cv_folds.fold` 컬럼을 그대로 사용(수동 K-Fold) |
| fold별 학습·평가 | `for fold in range(1,6): ...` 반복문 |
| 평균·표준편차 | `cv_fold_results.accuracy.mean()`, `.std()` |
| R 대응 | `caret::trainControl(method="cv", number=5)` |
