---
type: investigation-report
pilot: true
checked_at: 2026-07-25
---

# 다른 Olist 파일 존재 여부 확인

## 조사 방법

저장소 전체를 대상으로 다음을 확인했다.

1. 파일명 검색: `order`, `payment`, `review`, `product`, `seller`, `geolocation`,
   `category*translation` 키워드를 포함하는 파일
2. 확장자 검색: `.csv`, `.xlsx`, `.xls`, `.json`, `.parquet`, `.tsv`, `.db`, `.sqlite` 전체 스캔

```bash
find . -not -path "./.git/*" -type f | grep -iE "\.(csv|xlsx|xls|json|parquet|tsv|db|sqlite)$"
```

## 결과

**저장소에는 `olist_customers_dataset.csv` 외에 다른 Olist 데이터 파일이 존재하지 않는다.**
(`분석기법/_data/bigdata_exam.db`, `Olist-고객데이터/01-기본탐색/olist.db`는 이 저장소
내에서 직접 생성한 SQLite 산출물이지 원본 Olist 파일이 아니다.)

`빅분기로 sql1.pdf`, `빅분기로 sql2.pdf`, `박분기로 sql3.pdf`, `빅분기로 sql 예상문제.pdf`는
시험 학습용 PDF 문서이며 Olist 데이터 파일이 아니다.

## 따라서

- customers → orders → order_items → products → payments → reviews로 이어지는 결합은
  **지금은 수행할 수 없다.**
- 이 폴더의 나머지 파일은 (1) 의도한 관계 구조를 문서화하고, (2) 해당 파일들이 추가되었을 때
  **그대로 실행할 수 있는** SQL/Python 골격만 제공한다. 골격 코드는 실제 열 이름을 확인하지
  않은 상태로 작성되었으므로, 파일이 추가되면 반드시 실제 헤더를 다시 확인하고 골격의 열 이름을
  맞춰야 한다 — Olist Kaggle 배포판의 일반적인 스키마를 가정으로 표기했을 뿐 이 저장소에서
  검증된 것은 아니다.

## 의도한 관계 구조 (미검증, 추가 시 확인 필요)

```
customers (customer_id PK, customer_unique_id)
    │  customer_id
    ▼
orders (order_id PK, customer_id FK, order_purchase_timestamp, order_status, ...)
    │  order_id                              │  order_id
    ▼                                        ▼
order_items (order_id FK, order_item_id,     order_payments (order_id FK,
             product_id FK, seller_id FK,                    payment_type,
             price, freight_value)                            payment_value, ...)
    │  product_id        │  seller_id        order_reviews (order_id FK,
    ▼                    ▼                                review_score, ...)
products (product_id PK, ...)   sellers (seller_id PK, ...)
    │  product_category_name
    ▼
product_category_name_translation (한글/영문 매핑, PK 아님 — 참조용 매핑 테이블)

geolocation (zip_code_prefix, lat, lng, city, state) — customers/sellers의
    zip_code_prefix와 N:M 관계(같은 zip prefix에 여러 좌표가 존재할 수 있음)
```

## JOIN 전후 반드시 검증할 목록 (파일이 추가되면 체크리스트로 사용)

- [ ] 각 테이블의 관측 단위(grain) 확인 — 예: `order_items`는 "주문×상품" 단위, `orders`는 "주문" 단위
- [ ] 후보 PK 확인 — `SELECT COUNT(*), COUNT(DISTINCT 후보키) FROM 테이블` 일치 여부
- [ ] 후보 FK 확인 — 참조 무결성(FK 값이 부모 PK에 실제로 존재하는지)
- [ ] 관계 종류(1:1 / 1:N / N:M) 판단 — 조인 키 기준 그룹 크기 분포로 확인
- [ ] JOIN 전 각 테이블 행수 기록
- [ ] JOIN 후 행수 기록 — 예상과 다르면 원인 파악(중복 증식 또는 유실)
- [ ] 중복 증식(fan-out) 여부 — 1:N 관계를 잘못 이해해 상위 테이블 행이 부풀려지는지
- [ ] 미매칭 행 수 — INNER JOIN 대신 LEFT JOIN으로 먼저 확인
- [ ] JOIN으로 인한 신규 NULL 발생 여부
- [ ] 집계 단위 왜곡 여부 — 예: `order_items` 단위로 집계한 매출을 `orders` 단위 집계와 혼동하지 않기

## 골격 코드

- `skeleton_load_other_tables.py` — 위 6개 테이블이 추가되면 SQLite로 적재하는 골격
- `skeleton_join_checks.sql` — 위 체크리스트를 SQL로 수행하는 골격 (customers ⟷ orders 조인부터)

두 파일 모두 지금 이 저장소 상태에서는 **실행 대상 파일이 없어 실행할 수 없다.** 파일이
추가된 뒤 실제 헤더에 맞춰 열 이름을 수정하고 실행해야 한다.
