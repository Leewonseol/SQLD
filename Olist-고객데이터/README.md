---
type: index
pilot: true
---

# Olist 고객 데이터 실습

이 폴더는 `olist_customers_dataset.csv` **하나**를 중심 테이블로 삼아, 실제로 확인된
열·값만 사용해 데이터 사전 작성부터 분석기법 적용까지 정직하게 수행한 실습이다.
`분석기법/`(전 저장소 전반의 20개 기법 실습, 합성 데이터 사용)과는 별개로,
"가짜 변수를 만들지 않고 실데이터의 한계를 있는 그대로 보고한다"는 원칙을 지킨다.

## 원칙

1. 실제 CSV 헤더만 사용한다 — 예상 열 이름이 아니라 확인된 열 이름.
2. `customer_id`/`customer_unique_id`/`customer_zip_code_prefix`는 식별·지역 코드이지
   연속형 분석변수가 아니다. 크기 비교·회귀 입력으로 쓰지 않는다.
3. 이 파일에 없는 변수(주문액·배송기간·평점 등)는 만들어내지 않는다. 필요한 기법은
   "불가능"으로 보고하고, 어떤 Olist 테이블이 있으면 가능한지 명시한 뒤 골격 코드만 남긴다.
4. 저장소에 다른 Olist 파일이 실제로 있는지부터 확인하고, 없으면 없다고 보고한다
   (추측하지 않는다).

## 폴더 구성

| 폴더 | 내용 |
|---|---|
| [`00-데이터사전/`](./00-데이터사전/README.md) | 실제 헤더·행수·dtype·중복·결측·유일성 조사 결과 |
| [`01-기본탐색/`](./01-기본탐색/README.md) | 고객 데이터로 직접 수행하는 16개 기본 SQL/Python 실습 |
| [`02-관계파일확인/`](./02-관계파일확인/README.md) | 다른 Olist 파일(orders 등) 존재 여부 조사 결과 + 관계 골격 |
| [`03-기법별적용/`](./03-기법별적용/README.md) | 요청된 분석기법 14개를 4단계(가능/부분가능/불가능/보너스)로 판정하고 실행 |
| `_lib/` | 공용 SQL 실행 헬퍼 (`sqlite3` CLI 없는 환경용) |

## 핵심 결론 요약

- 원본 CSV는 5개 열(`customer_id`, `customer_unique_id`, `customer_zip_code_prefix`,
  `customer_city`, `customer_state`), 99,441행이며 결측·빈 문자열이 전혀 없다.
- `customer_unique_id`가 2회 이상 나타나는 고객 2,997명(3.12%)은 Olist 스키마 설계상
  "재구매 고객"으로 해석할 수 있는, 유일하게 이 파일만으로 정당화되는 파생 지표다.
- 저장소에 `olist_customers_dataset.csv` 외 다른 Olist 파일은 없다. 따라서 주문액·배송·
  리뷰·상품 기반 분석(기술통계 일부, 이상치 일부, 랜덤포레스트 원 요청, 고객단위 PCA,
  연관규칙, 시계열/ARIMA)은 **실행할 수 없으며**, 그대로 실행 가능한 골격 코드만 남겼다.
  (`03-기법별적용/스켈레톤-불가능기법/`)
- 재구매 여부를 지역(state) 정보만으로 예측하면 로지스틱회귀 McFadden R² ≈ 0.0005,
  분류모델 ROC-AUC ≈ 0.50~0.52로 사실상 무작위 수준이다 — 이는 데이터 자체의 정직한
  한계이며, 이 실습에서 억지로 "잘 작동하는 모델"을 만들지 않았다는 증거이기도 하다.

## 실행 순서

```bash
cd 00-데이터사전 && python3 profile.py && cd ..
cd 01-기본탐색 && python3 01_load.py \
  && python3 ../_lib/run_sql.py olist.db 02_explore_basic.sql \
  && python3 ../_lib/run_sql.py olist.db 03_clean_and_normalize.sql \
  && python3 ../_lib/run_sql.py olist.db 04_encode_and_consolidate.sql \
  && python3 ../_lib/run_sql.py olist.db 05_rank_cumulative_concentration.sql \
  && python3 ../_lib/run_sql.py olist.db 06_sampling_and_fold.sql \
  && python3 07_verify_with_python.py && cd ..
cd 03-기법별적용 \
  && python3 ../_lib/run_sql.py ../01-기본탐색/olist.db _shared/01_prepare_features.sql
for d in A-가설검정 B-로지스틱회귀-재구매예측 "C-분류모델비교-교차검증-성능지표" "D-지역프로파일-PCA-Kmeans-보너스"; do
  python3 ../_lib/run_sql.py ../01-기본탐색/olist.db "$d/01_prepare.sql"
  python3 "$d/02_analyze.py"
  python3 ../_lib/run_sql.py ../01-기본탐색/olist.db "$d/03_verify.sql"
done
```
