---
type: technique-application
pilot: true
feasibility: partial-real-data
---

# B. 로지스틱 회귀 — 재구매 여부 예측 (실데이터 기반)

## 요청된 항목과 실제 가능 범위

원래 요청: "로지스틱 회귀: **저평점·배송지연·재구매 여부**". 이 중 저평점·배송지연은
리뷰/주문 데이터가 없어 불가능하다(`스켈레톤-불가능기법` 참고). **재구매 여부**만
`customer_unique_id` 반복 구조로 실제 도출 가능하므로 이것만 구현한다.

## 데이터와 한계

- 종속변수: `is_repeat_customer` (0/1, `_shared/01_prepare_features.sql`에서 생성)
- 독립변수: `state`(상위 6개 주 + 기타)를 더미변수로 인코딩한 것 **뿐**이다.
  고객 행동·구매 이력 관련 변수가 이 파일에 전혀 없으므로, 모델의 설명력(예측력)이
  낮을 것으로 예상된다 — 이는 모델링 실수가 아니라 **입력 데이터 자체의 한계**다.
  이 실습의 목적은 "SQL 더미변수 생성 -> 로지스틱회귀 계수·오즈비 추정 -> SQL 검산"이라는
  절차 자체를 실데이터로 연습하는 것이지, 실전에서 쓸 만한 이탈/재구매 예측모형을
  만드는 것이 아니다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | 상위 6개 주 더미변수 생성 |
| Python (`02_analyze.py`) | `statsmodels.Logit` 계수·오즈비(`EXP(β)`)·p-value 추정 |
| SQL (`03_verify.sql`) | `EXP(β)`를 SQL로 재계산해 대조 |

## 실행

```bash
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 01_prepare.sql
python3 02_analyze.py
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 03_verify.sql
```
