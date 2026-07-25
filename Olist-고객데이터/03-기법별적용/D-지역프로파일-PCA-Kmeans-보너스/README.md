---
type: technique-application
pilot: true
feasibility: bonus-real-data-aggregate
---

# D. 지역(주) 프로파일 PCA·K-means (보너스, 완전 실데이터)

## 요청된 항목과 이 실습의 성격

원래 요청은 "PCA: **고객별** 구매·결제·배송 특성 축소", "K-means: **고객** 세분화"다.
이 데이터셋에는 고객별 구매·결제·배송 변수가 없으므로 **그 문자 그대로는 수행할 수 없다**
(`스켈레톤-불가능기법`에 옵션 2로 기록). 이 폴더는 그 대체품이 아니라 **완전히 다른 분석
단위(개별 고객이 아니라 주 단위)에서, 오직 이 파일에 실제로 존재하는 열만으로 집계한
보너스 실습**이다. 개별 고객 수준 PCA/K-means로 오인하지 않도록 이름에 "보너스"를 붙였다.

## 사용하는 실제 파생 변수 (전부 GROUP BY 집계, 가상 변수 없음)

| 변수 | 정의 | 근거 |
|---|---|---|
| `n_customers` | 주별 고유고객(`customer_unique_id`) 수 | `01-기본탐색` §3~4 |
| `repeat_rate` | 주별 재구매 고객 비율 | `customer_repeat_features.is_repeat_customer` 평균 |
| `avg_n_orders` | 주별 고객당 평균 주문 횟수 | `customer_repeat_features.n_orders` 평균 |
| `n_cities` | 주 내 서로 다른 도시 수 | `customer_city` distinct count |
| `city_hhi` | 주 내 도시 분포 집중도(HHI) | `01-기본탐색`의 HHI 공식을 주 내부로 재적용 |

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 위 5개 변수를 주(state) 단위로 집계·표준화 |
| Python (`02_analyze.py`) | `sklearn.decomposition.PCA`, `sklearn.cluster.KMeans`(k=3) |
| SQL (`03_verify.sql`) | 군집별 주 목록과 원 척도 평균 재확인 |

## 실행

```bash
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 01_prepare.sql
python3 02_analyze.py
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 03_verify.sql
```
