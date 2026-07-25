---
type: exercise-set
pilot: true
---

# 01. 기본 탐색

`olist_customers_dataset.csv` 5개 열만으로 수행 가능한 16개 기본 실습. 전부 실제 원본 열
(`customer_id`, `customer_unique_id`, `customer_zip_code_prefix`, `customer_city`,
`customer_state`)만 사용하며, 가짜 변수를 만들지 않는다.

> 실행 전 `python3 01_load.py`로 `olist.db`(SQLite)를 먼저 만들어야 한다.

## 파일 구성과 다루는 항목

| 파일 | 다루는 항목 |
|---|---|
| `01_load.py` | CSV -> `customers_raw` 테이블 적재 (원본 그대로, 파생 없음) |
| `02_explore_basic.sql` | [1] 전체 행수/고유 고객수 · [2] id/unique_id 중복 구조 · [3][4] 도시·주별 고객수/비율 · [5] 반복 등장(재구매) 여부 · [6] NULL/빈 문자열 탐색 |
| `03_clean_and_normalize.sql` | [7] 문자열 정제 · [8] 대소문자·공백 정규화 · [9] 지역 코드(zip) 형변환의 위험성 |
| `04_encode_and_consolidate.sql` | [10] 범주형 인코딩(레이블/원-핫) · [11] 희소 범주 통합 |
| `05_rank_cumulative_concentration.sql` | [12] 고객수 기준 순위 · [13] 지역별 누적 비율(파레토) · [14] 분포 편중도(HHI) |
| `06_sampling_and_fold.sql` | [15] 지역별 층화표본 · [16] 학습/검증 fold 생성 |
| `07_verify_with_python.py` | SQL 결과(순위 인코딩, HHI)를 pandas/numpy로 교차검증 + 지니계수 추가 계산 |

## 실행

```bash
python3 01_load.py
python3 ../_lib/run_sql.py olist.db 02_explore_basic.sql
python3 ../_lib/run_sql.py olist.db 03_clean_and_normalize.sql
python3 ../_lib/run_sql.py olist.db 04_encode_and_consolidate.sql
python3 ../_lib/run_sql.py olist.db 05_rank_cumulative_concentration.sql
python3 ../_lib/run_sql.py olist.db 06_sampling_and_fold.sql
python3 07_verify_with_python.py
```
(`sqlite3` CLI가 있다면 `sqlite3 olist.db < 02_explore_basic.sql`처럼 직접 실행해도 된다.)

## 핵심 발견 (00-데이터사전과 함께 읽을 것)

- **재구매 신호**: `customer_unique_id`가 2회 이상 나타나는 고객 2,997명(3.12%)이 존재한다.
  Olist 공식 스키마 설명상 이는 재구매를 의미하므로, 임의 파생이 아니라 근거 있는 해석이다.
- **결측치 없음**: 5개 열 전부 NULL 0건, 빈 문자열 0건 — "결측치 처리" 실습은 이 파일 자체에는
  적용 대상이 없다는 것 자체가 유효한 결론이다.
- **zip을 정수로 캐스팅하면 안 되는 이유가 수치로 확인된다**: `0`으로 시작하는 zip이
  23,995건(24.1%) 있고, 이들을 정수로 캐스팅했다가 되돌리면 전부 자릿수가 깨진다
  (`03_clean_and_normalize.sql` 결과 참고).
- **지역 편중**: 상위 6개 주(SP·RJ·MG·RS·PR·SC)가 전체 고객의 80%를 차지한다(HHI=0.217,
  Gini=0.742) — 전형적인 파레토 분포.
- **fold 설계**: fold는 `customer_id`가 아니라 `customer_unique_id` 기준으로 나눠야
  동일인의 재구매 기록이 학습/검증에 걸쳐 새어나가지(leak) 않는다. `06_sampling_and_fold.sql`
  마지막 쿼리에서 leak이 0건임을 직접 검증한다.
