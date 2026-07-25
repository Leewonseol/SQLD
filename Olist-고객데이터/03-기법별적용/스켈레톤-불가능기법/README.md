---
type: skeleton-index
pilot: true
status: not-executable-yet
---

# 스켈레톤: 이 저장소 데이터로는 지금 실행할 수 없는 기법

`02-관계파일확인/README.md`에서 확인했듯 이 저장소에는 `olist_customers_dataset.csv`
외의 Olist 파일이 없다. 아래 기법들은 요청 사항 원문 그대로는 수행할 수 없으며, 억지로
`customer_id`/`zip_code_prefix`를 연속형 변수로 만들거나 가짜 수치를 생성해 구현 개수를
채우지 않는다. 대신 **왜 불가능한지, 어떤 파일/컬럼이 있으면 가능한지, 그 파일이 생기면
그대로 실행할 골격**을 기록한다.

| 기법 | 필요한 추가 파일(예상 컬럼) | 골격 파일 |
|---|---|---|
| 기술통계(고객별 주문액·주문수·평균결제액) | `orders`(order_id, customer_id), `order_payments`(order_id, payment_value) | `01_기술통계_결측치_이상치_스켈레톤.sql` |
| 결측치(배송일·리뷰·상품속성) | `orders`(order_delivered_customer_date), `order_reviews`(review_score), `products`(product_category_name 등) | `01_기술통계_결측치_이상치_스켈레톤.sql` |
| 이상치(고액주문·배송기간·배송비) | `order_payments`(payment_value), `orders`(구매/배송일시), `order_items`(freight_value) | `01_기술통계_결측치_이상치_스켈레톤.sql` |
| 랜덤포레스트(배송지연·저평점 예측) | `orders`(주문/배송 일시), `order_reviews`(review_score) | `02_랜덤포레스트_예측_스켈레톤.py` |
| PCA(고객별 구매·결제·배송 특성) | `orders`, `order_items`, `order_payments` | `03_PCA_고객특성_스켈레톤.py` |
| 연관규칙(동일 주문 내 상품 범주 동시구매) | `order_items`(order_id, product_id), `products`(product_category_name) | `04_연관규칙_스켈레톤.py` |
| 시계열·ARIMA(일/주/월별 주문량·매출) | `orders`(order_purchase_timestamp), `order_items`(price) 또는 `order_payments`(payment_value) | `05_시계열ARIMA_스켈레톤.py` |

모든 골격 파일에서 실제 쿼리·모델 코드는 **주석 처리**되어 있다(필요 테이블이 없어 그대로
실행하면 `sqlite3.OperationalError: no such table` 또는 `FileNotFoundError`가 나기 때문).
대신 각 파일을 실행하면 필요한 테이블이 실제로 없다는 것을 `sqlite_master` 조회나
`FileNotFoundError`로 명시적으로 확인해준다. 자료가 추가되면 주석을 해제하고 실제 헤더에 맞춰 열 이름을 수정한
뒤 사용한다.

이미 실행 가능한 실데이터 버전은 다음을 참고하라.

- 기술통계/결측치/이상치의 "고객 파일 자체" 버전 → `01-기본탐색/`
- 랜덤포레스트/SVM/KNN의 "재구매 여부" 버전 → `../C-분류모델비교-교차검증-성능지표/`
- PCA의 "주(state) 단위 집계" 버전 → `../D-지역프로파일-PCA-Kmeans-보너스/`
