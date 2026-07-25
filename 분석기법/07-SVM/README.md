---
type: technique
pilot: true
category: 지도학습-분류
---

# SVM (Support Vector Machine)

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
| SQL (`01_prepare.sql`) | 특성 표준화(z-score), 학습/평가 분할(`split` 컬럼, 80/20) |
| Python (`02_analyze.py`) | `sklearn.svm.SVC(kernel="rbf")` 학습·예측, 서포트벡터 개수 확인 |
| SQL (`03_verify.sql`) | 실제값·예측값 비교, 오류 사례 집계, 클래스별 정확도 조회 |

## DBMS별 SQL 차이

학습/평가 분할은 결정적(deterministic) 방식으로 만든다. `ROWID`(SQLite 내부 행 번호)로
나머지 연산을 하면 재현 가능한 분할을 얻는다.

| DBMS | 결정적 분할 키 |
|---|---|
| Oracle | `ROWNUM` 또는 `ORA_HASH(customer_id)` |
| SQL Server | `ROW_NUMBER() OVER(ORDER BY customer_id)` 또는 `CHECKSUM(customer_id)` |
| SQLite | `ROWID` |

## 실행

```bash
sqlite3 ../_data/bigdata_exam.db < 01_prepare.sql   # 또는: python3 ../_data/run_sql.py 01_prepare.sql
python3 02_analyze.py
sqlite3 ../_data/bigdata_exam.db < 03_verify.sql    # 또는: python3 ../_data/run_sql.py 03_verify.sql
```

## 필기 공식 ↔ 실기 코드 연결

| 필기 개념 | 실기(Python) 대응 |
|---|---|
| 마진 최대화, 커널 | `SVC(kernel="rbf", C=1.0, probability=True)` |
| 서포트벡터 | `model.support_vectors_`, `model.n_support_` |
| 소프트마진 파라미터 C | `SVC(C=...)` — `16-하이퍼파라미터탐색`에서 탐색 |
| R 대응 | `e1071::svm(churned ~ ., data=df, kernel="radial")` |
