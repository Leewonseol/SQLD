---
type: technique-application
pilot: true
feasibility: partial-real-data
---

# A. 가설검정 (실데이터 기반)

## 요청된 항목과 실제 가능 범위

원래 요청: "t-test·F-test: 두 고객 집단의 **주문액·배송기간** 비교", "카이제곱: 지역과
**주문 상태 또는 저평점 여부**의 연관성". 이 저장소에는 주문액·배송기간·주문상태·평점이
전혀 없으므로(`02-관계파일확인` 참고) **문자 그대로는 수행할 수 없다.**

대신 `customer_repeat_features`(`_shared/01_prepare_features.sql`에서 생성, 근거는
`00-데이터사전/README.md §3`)에 있는 **실제로 파생 가능한** 두 변수로 같은 통계기법을
적용한다.

| 검정 | 실데이터 기반 대체 실습 | 원래 요청과의 차이 |
|---|---|---|
| 일원배치 분산분석(F-test) | 주(state) 상위 6곳 간 `n_orders`(고객당 주문횟수) 평균 비교 | 비교 대상이 "주문액"이 아니라 "주문 횟수" |
| 카이제곱 독립성 검정 | `state`(상위 6곳 + 기타) × `is_repeat_customer` 연관성 | "저평점 여부" 대신 "재구매 여부" |

`n_orders`는 1~17 사이 정수로 강한 오른쪽 왜도를 가진다(93,099명이 1회, 소수만 다회) —
분산분석의 정규성 가정이 이상적으로 충족되지는 않는다는 점을 결과 해석 시 감안해야 한다.
이 캡션 자체가 이 실습의 정직한 결론 중 하나다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 상위 6개 주 + 기타로 그룹핑한 분석 테이블과 교차표 준비 |
| Python (`02_analyze.py`) | `scipy.stats.f_oneway`, `chi2_contingency` |
| SQL (`03_verify.sql`) | SQL 공식으로 F값·카이제곱값 직접 재계산해 대조 |

## 실행

`_shared/01_prepare_features.sql`을 먼저 실행해 `customer_repeat_features`가 있어야 한다.

```bash
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 01_prepare.sql
python3 02_analyze.py
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 03_verify.sql
```
