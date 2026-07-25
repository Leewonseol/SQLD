---
type: index
pilot: true
---

# 분석기법 (빅데이터분석기사 실기 연계)

이 폴더는 SQLD 저장소의 SQL 학습 범위를 넘어, **빅데이터분석기사 실기 범위**에 포함되거나
필기·실기 교집합으로 확인되는 분석기법을 다룬다. "SQL로 모델을 직접 학습하기 어렵다"는
이유로 기법을 빼지 않고, 대신 **역할을 세 층으로 나눠** SQL과 Python이 각자 잘하는 부분을
담당하게 하고 하나의 실습으로 연결한다.

## 3층 구현 원칙

| 층 | 담당 | 예시 |
|---|---|---|
| 1. SQL로 직접 수행 | 집계, 표준화, 거리/상관 계산, 결과 검산 | `AVG() OVER()`로 표준화, `SQRT(SUM(POWER(...)))`로 거리행렬 |
| 2. SQL로 입력·중간 통계량 준비 | 분석 테이블, 더미변수, fold/그리드 테이블 | 학습용 wide 테이블, K-Fold 배정 테이블, 하이퍼파라미터 후보 테이블 |
| 3. Python/R로 모델 학습 | 실제 알고리즘 적합·예측 | `sklearn`, `statsmodels`, `mlxtend` |

SQL만으로 알고리즘 전체를 억지로 구현하지 않는다. 대신 Python이 만든 결과(계수, 성분점수,
군집 라벨, 예측값 등)를 **다시 DB 테이블에 저장**하고, SQL로 재조회·집계·검산하는 것까지가
한 실습의 끝이다.

## 실습 흐름 (기법 폴더마다 동일)

```
필기 공식·예상문제         (README.md 상단)
  → SQL 데이터 준비          (01_prepare.sql)
  → DBMS별 SQL 차이 체험      (README.md 내 Oracle/SQL Server 비교 표)
  → Python 분석 실행          (02_analyze.py)
  → 분석 결과를 테이블로 저장   (02_analyze.py 마지막 단계, to_sql)
  → SQL로 결과 검산·비교       (03_verify.sql)
  → 필기 공식과 실기 코드 논리 연결 (README.md 하단 "필기 vs 실기" 절)
```

## 공통 데이터셋

`_data/build_db.py` 를 실행하면 `_data/bigdata_exam.db` (SQLite)가 생성된다. 모든 기법
폴더는 이 DB를 공통 입력으로 쓴다. `olist_customers_dataset.csv`에서 고객 1,000명을
추출하고, 그 위에 재현 가능한(seed=42) 합성 특성·타깃·시계열·거래 데이터를 얹은
"이커머스 고객·매출 분석" 하나의 스토리로 구성했다.

```bash
pip install pandas numpy scikit-learn scipy statsmodels mlxtend
python3 분석기법/_data/build_db.py
```

주요 테이블은 `_data/schema.sql`에 문서화되어 있다. 핵심 테이블:

- `customers`, `customer_features` — 고객 인구통계/행동 특성 (PCA·군집·회귀·분류 공통 입력)
- `customer_labels` — 연속형 타깃(`next_month_spend`), 이진 타깃(`churned`)
- `customer_category_spend` — 고객×카테고리 구매금액 롱포맷 (SVD·NMF)
- `customer_survey` — 만족도 설문 6문항 (요인분석)
- `monthly_sales` — 48개월 월별 매출 (이동평균·지수평활·ARIMA)
- `basket_transactions` — 장바구니 거래 내역 (연관규칙)
- `branch_scores` / `paired_scores` / `ab_test` — 가설검정용 표본
- `raw_customer_intake` — 결측·이상치·표기 불일치가 섞인 원본 (전처리·변수변환)

각 기법 폴더는 이 DB 위에서 `CREATE VIEW`/`CREATE TABLE ... AS SELECT`로 자신만의 분석
테이블을 만들고(01_prepare.sql), 결과 테이블(`*_result` 접미사)을 새로 적재한다. 기법
폴더를 몇 번을 다시 실행해도 같은 결과가 나오도록 01_prepare.sql / 02_analyze.py는
기존 산출 테이블을 `DROP TABLE IF EXISTS` 후 재생성한다.

## 구현 대상 기법 (20개)

| # | 기법 | 폴더 |
|---|---|---|
| 1 | 주성분분석(PCA) | `01-PCA` |
| 2 | SVD·NMF | `02-SVD-NMF` |
| 3 | 요인분석 | `03-요인분석` |
| 4 | 다차원척도법(MDS) | `04-MDS` |
| 5 | 선형회귀·다중회귀 | `05-회귀분석` |
| 6 | 로지스틱 회귀 | `06-로지스틱회귀` |
| 7 | SVM | `07-SVM` |
| 8 | 의사결정나무 | `08-의사결정나무` |
| 9 | 랜덤 포레스트 | `09-랜덤포레스트` |
| 10 | KNN | `10-KNN` |
| 11 | K-means | `11-Kmeans` |
| 12 | 계층적 군집분석 | `12-계층적군집분석` |
| 13 | 시계열 이동평균·지수평활 | `13-시계열-이동평균-지수평활` |
| 14 | AR·MA·ARMA·ARIMA | `14-ARIMA` |
| 15 | 교차검증 | `15-교차검증` |
| 16 | 하이퍼파라미터 탐색 | `16-하이퍼파라미터탐색` |
| 17 | 모델 평가 지표 | `17-모델평가지표` |
| 18 | 가설검정 | `18-가설검정` |
| 19 | 연관규칙 | `19-연관규칙` |
| 20 | 데이터 전처리와 변수 변환 | `20-데이터전처리와변수변환` |

## 1차 구현 제외 (인공신경망 계열)

기본 인공신경망, CNN, RNN, LSTM, GAN, 딥러닝 역전파 구현은 이번 1차 구현에서 제외한다.
영구 제외가 아니라 **재검토 대상**이며, 자세한 사유와 재검토 조건은
[`21-제외기법-인공신경망/README.md`](./21-제외기법-인공신경망/README.md)에 기록한다.

## 추가 모듈 (20개 목록 이후 별도 편입)

- **`22-KNN결측값대체`** — 최초 20개 목록에는 없던, Oracle/SQL Server NULL 문법
  차이를 "kNN 결측값 대체"라는 하나의 실제 분석 문제로 통합한 실습. 근거 논문과
  전체 설계는 [`22-KNN결측값대체/README.md`](./22-KNN결측값대체/README.md) 참고.
  `10-KNN`(분류)과는 다른 기법이며 서로 대체하지 않는다.

## 폴더 구조 (기법 폴더 공통)

```
NN-기법이름/
  README.md        # 필기 공식, SQL/Python 역할 분담, DBMS 차이, 필기-실기 연결
  01_prepare.sql    # SQL: 분석 테이블/뷰 생성, 표준화, 더미변수, 거리행렬 등
  02_analyze.py     # Python: 모델 적합, 결과를 DB에 저장
  03_verify.sql     # SQL: 결과 검산·재조회
```

## 전체 실행

`sqlite3` CLI가 있다면 `<` 리다이렉션으로, 없다면 `_data/run_sql.py`로 동일하게 실행할 수 있다.

```bash
cd 분석기법
python3 _data/build_db.py
for d in 0*-*/ 1*-*/; do
  echo "=== $d ==="
  sqlite3 _data/bigdata_exam.db < "$d/01_prepare.sql"   # 또는: python3 _data/run_sql.py "$d/01_prepare.sql"
  python3 "$d/02_analyze.py"
  sqlite3 _data/bigdata_exam.db < "$d/03_verify.sql"    # 또는: python3 _data/run_sql.py "$d/03_verify.sql"
done
```
