---
type: technique-application
pilot: true
feasibility: partial-real-data
---

# C. 분류모델 비교(RF·SVM·KNN) + 교차검증 + 성능지표 (실데이터 기반)

## 요청된 항목과 실제 가능 범위

원래 요청: "랜덤 포레스트: 배송 지연 또는 저평점 예측", "SVM·KNN: 고객 또는 주문 분류",
"교차검증: 고객 또는 주문 단위 fold 분할", "성능지표: 실제값·예측값 테이블 기반 계산".

배송지연·저평점 예측은 데이터가 없어 불가능하다. 대신 [B]와 같은 종속변수
(`is_repeat_customer`)와 독립변수(주 더미)로 랜덤포레스트·SVM·KNN 세 모델을 비교하고,
**고객(customer_unique_id) 단위 fold**로 교차검증하며, 결과로 실제 성능지표를 계산한다.
fold는 `01-기본탐색/06_sampling_and_fold.sql`이 만든 `customer_fold`를 그대로 재사용한다
(동일인이 여러 fold에 나뉘어 들어가는 leakage가 없음을 이미 검증한 테이블).

## 미리 밝히는 예상 결과

`is_repeat_customer`의 비율은 3.1%(2,997/96,096)로 심하게 불균형하고, 예측변수는 지역
정보(주 6개 더미)뿐이다. 이 조합에서는 분류기가 사실상 항상 "재구매 아님(0)"을 예측하는
**퇴화(degenerate) 분류기**가 될 가능성이 높다 — 재현율(recall)이 0에 가깝게 나온다면
이는 모델 구현 오류가 아니라, **행동·구매 이력 변수가 없는 데이터로는 재구매를 예측할
근거가 사실상 없다는 정직한 결론**이다. 이 폴더의 목적은 "높은 정확도의 예측모형"이
아니라 SQL fold 생성 -> Python 모델 3종 비교 -> SQL 성능지표 검산이라는 절차 자체를
실데이터로 연습하는 것이다.

## 실행 후 확인된 사실

실제로 돌려보면 예측대로 퇴화한다: `KNN`(균형 조정 없음)은 항상 0을 예측해 재현율 0,
`RandomForest`/`SVM(Linear)`(`class_weight="balanced"`)는 재현율을 0.60~0.75까지 올리지만
그 대가로 정밀도가 0.03대까지 떨어지고 ROC-AUC는 0.50~0.52로 사실상 무작위 수준이다.
독립변수가 주(state) 더미 6개뿐이라 **입력 특성의 조합이 7가지(6개 주 + 기타)밖에 없다** —
즉 모델이 아무리 복잡해도(RF·SVM·KNN 무엇을 쓰든) 결국 "이 주에서 재구매 비율이 얼마였는가"
이상의 정보를 뽑아낼 수 없다는 뜻이다. 모델 선택의 문제가 아니라 **입력 데이터가 가진
정보량의 한계**임을 확인하는 것이 이 실습의 실질적 결론이다.

## 역할 분담

| 층 | 내용 |
|---|---|
| SQL (`01_prepare.sql`) | state 더미 + `customer_fold`를 결합한 `clf_input` 생성 |
| Python (`02_analyze.py`) | RandomForest/SVM/KNN을 5-fold로 각각 학습·평가, fold별 정확도/정밀도/재현율/F1/ROC-AUC 계산 |
| SQL (`03_verify.sql`) | 모델별 평균 성능 비교, 혼동행렬을 SQL로 재집계해 sklearn 결과와 대조 |

## 실행

`01-기본탐색/01_load.py`와 `06_sampling_and_fold.sql`, `_shared/01_prepare_features.sql`이
먼저 실행되어 있어야 한다.

```bash
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 01_prepare.sql
python3 02_analyze.py
python3 ../../_lib/run_sql.py ../../01-기본탐색/olist.db 03_verify.sql
```
