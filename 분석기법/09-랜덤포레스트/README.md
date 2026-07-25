---
type: technique
pilot: true
category: 지도학습-분류
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 랜덤 포레스트 (Random Forest) — Oracle · SQL Server 중심

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
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 학습 데이터 구성, 파생변수(주문액 구간), train/test 분할 |
| Python (`02_analyze.py`) | `sklearn.ensemble.RandomForestClassifier` 학습(OOB 포함), 변수중요도·예측값 저장 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 변수중요도 집계, 예측값 vs 실제값 교차표 |

## 두 DBMS에서 같은 부분

- `CASE WHEN` 기반 구간화(`aov_bucket`)는 Oracle·SQL Server 문법이 동일하다.
- `ROW_NUMBER() OVER (ORDER BY customer_id)`로 결정적 순번을 매기는 방식도 동일하다.

## 두 DBMS에서 다른 부분 — train/test 분할 키

`optional/01_prepare_sqlite.sql`은 `f.ROWID % 5 = 0`으로 분할했다. 이 방식은
**Oracle/SQL Server로 그대로 옮길 수 없다**:

- Oracle의 `ROWID`는 정수가 아니라 **물리 저장 주소를 인코딩한 문자열**이라
  `MOD(ROWID, 5)` 같은 산술이 불가능하다(`ROWID`끼리 순서 비교는 가능하지만 나머지
  연산 대상이 아니다).
- SQL Server에는 `ROWID` 개념 자체가 없다(Oracle 전용 의사컬럼).

두 DBMS 모두 `ROW_NUMBER() OVER (ORDER BY customer_id)`로 먼저 순번을 만든 뒤 그
순번에 `MOD`(Oracle)/`%`(SQL Server)를 적용해야 한다 — **SQLite 전용 코드를 옮길 때
"의사컬럼이 다른 DBMS에도 있을 것"이라는 가정이 가장 흔히 깨지는 지점**이다.

## SQLD 출제 함정

- `ROWID`/`ROWNUM`을 정렬·분할 키로 오해하는 문제가 자주 나온다 — `ROWID`는 저장
  위치, `ROWNUM`은 조회 시 매겨지는 순번(정렬 전에 매겨짐)이며 둘 다 "입력 순서"를
  보장하지 않는다는 점이 [문제07](../../필기계산문제-멀티DBMS/문제07-DBMS문법차이-문자열날짜LIMIT/README.md)의
  `ROWNUM` 함정과 같은 맥락이다.

## 실행

`03_verify_oracle.sql`/`03_verify_sqlserver.sql`은 [`08-의사결정나무`](../08-의사결정나무/README.md)가
만든 `tree_feature_importance`와 비교하는 쿼리를 포함하므로, 08 폴더를 먼저 실행해두면
더 풍부한 비교가 가능하다.

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
| Bagging(부트스트랩) | `RandomForestClassifier(n_estimators=200, bootstrap=True)` |
| OOB 오차 | `RandomForestClassifier(oob_score=True).oob_score_` |
| 변수 무작위 선택(√p) | `max_features="sqrt"` |
| 변수중요도 | `model.feature_importances_` |
| R 대응 | `randomForest::randomForest(churned ~ ., data=df, importance=TRUE)` |
