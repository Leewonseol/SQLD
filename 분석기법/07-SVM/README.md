---
type: technique
pilot: true
category: 지도학습-분류
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# SVM (Support Vector Machine) — Oracle · SQL Server 중심

## 필기 공식

- 목적: 두 클래스를 가장 넓은 마진(margin)으로 분리하는 초평면(hyperplane)을 찾는다.
- 초평면: `wᵀx + b = 0`, 마진 폭: `2 / ||w||`
- 최적화: `min (1/2)||w||²` , 제약 `yᵢ(wᵀxᵢ+b) ≥ 1` (하드마진)
- 소프트마진(오분류 허용): `min (1/2)||w||² + C·Σξᵢ` — `C`가 클수록 오분류에 더 민감(과적합 위험↑)
- 커널 트릭: 선형으로 분리 안 되는 데이터를 고차원으로 매핑 (`linear`, `rbf`, `poly` 등)
- **스케일링 필수**: 거리·마진 기반 알고리즘이므로 변수 스케일이 다르면 특정 변수가
  결과를 지배한다. PCA·KNN·K-means와 같은 이유로 표준화가 선행되어야 한다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare_oracle.sql` / `01_prepare_sqlserver.sql`) | 특성 표준화(z-score), 학습/평가 분할(`split` 컬럼, 80/20) |
| Python (`02_analyze.py`) | `sklearn.svm.SVC(kernel="rbf")` 학습·예측, 서포트벡터 개수 확인 |
| SQL (`03_verify_oracle.sql` / `03_verify_sqlserver.sql`) | 결과 테이블 DDL, 실제값·예측값 비교, 오류 사례 집계, 클래스별 정확도 |

## 두 DBMS에서 같은 부분

- 표준화 구조(파티션 없는 `OVER()`)와 최종 서포트벡터·정확도 값은 동일하다.

## 두 DBMS에서 다른 부분

- 결정적 분할 키: `ROWID % 5`(SQLite 전용) 대신 두 DBMS 모두
  `ROW_NUMBER() OVER (ORDER BY customer_id)`를 쓴다. Oracle의 `ROWNUM`은 정렬 전에
  매겨지는 값이라 `ORDER BY`와 함께 쓰면 "정렬 후 몇 번째"가 아니라 "저장 순서상 몇
  번째"가 되어 분할이 매번 달라질 위험이 있다 — 결정적 분할에는 `ROWNUM`보다
  `ROW_NUMBER() OVER(ORDER BY ...)`가 안전하다(09-랜덤포레스트, 08-의사결정나무와
  동일한 결론).
- 클래스별 정확도 계산에서 SQL Server는 `actual`/`predicted`가 `INT`라 `1.0 *`이
  필요하지만 Oracle `NUMBER`는 필요 없다.

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
| 마진 최대화, 커널 | `SVC(kernel="rbf", C=1.0, probability=True)` |
| 서포트벡터 | `model.support_vectors_`, `model.n_support_` |
| 소프트마진 파라미터 C | `SVC(C=...)` — `16-하이퍼파라미터탐색`에서 탐색 |
| R 대응 | `e1071::svm(churned ~ ., data=df, kernel="radial")` |
