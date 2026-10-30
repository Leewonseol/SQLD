# ex07 반정규화와 중복 데이터 관리

> 근거: 요구목록 §6(반정규화와 중복 데이터 관리). 추출본 본문 없음 · 데이터: N03_ORD(주문, 합계) · N03_OLINE(주문상세) — 학습용 가상 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **반정규화**: 조회 성능이나 단순화를 위해 정규화 원칙을 일부러 어겨 중복을 허용하는 것이다. 예: 파생 컬럼(주문 합계), 중복 컬럼(주문에 고객명 복사), 테이블 병합, 이력 요약 테이블.
* 중복이 생기면 **갱신 이상이 다시 생긴다.** 그래서 반정규화에는 동기화 방법이 반드시 따라야 한다. 방법은 트리거, 같은 트랜잭션에서 함께 갱신하는 응용 로직, 배치 재계산, (Oracle) 구체화 뷰 등이다.
* 반정규화 전에 인덱스·뷰·쿼리 개선으로 해결할 수 있는지 먼저 검토한다.

## B. 입력 데이터
N03_ORD(주문, 합계) · N03_OLINE(주문상세) — 학습용 가상

## C. 실행 SQL
[Oracle](ex07_denormalization_oracle.sql) · [SQL Server](ex07_denormalization_sqlserver.sql)

## D. 결과 예측 문제
1. 상세 금액만 바꾸면 불일치 행은 몇 개인가?
2. 트리거를 둔 뒤 상세를 바꾸고 추가하면 합계는?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex07_denormalization_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

Table created.

1 row created.

1 row created.

1 row created.

1 row updated.

Commit complete.

== [Q1] 반정규화 값과 원천 값의 일치 검사 쿼리 (불일치 행 수)

MISMATCHES
0

1 row selected.

== [Q2] 상세만 바꾸고 합계를 갱신하지 않으면 불일치가 생긴다 (갱신 이상의 재등장)

1 row updated.

MISMATCHES
1

1 row selected.

Rollback complete.

== [Q3] 트리거로 동기화: 상세가 바뀌면 합계를 다시 계산 (문장 단위 트리거)

Trigger created.

1 row updated.

1 row created.

ORD_ID|TOTAL_AMT
1|650

1 row selected.

MISMATCHES
0

1 row selected.

Rollback complete.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex07_denormalization_sqlserver.sql -->
```text
(1 rows affected)

(2 rows affected)

(1 rows affected)
== [Q1] 일치 검사
mismatches
----------
0

(1 rows affected)
== [Q2] 상세만 바꾸면 불일치

(1 rows affected)
mismatches
----------
1

(1 rows affected)
== [Q3] 트리거로 동기화

(1 rows affected)

(1 rows affected)
ord_id|total_amt
------|---------
1|650

(1 rows affected)
mismatches
----------
0

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 처음에는 0. Q2: 상세만 바꾸자 불일치 1 → 갱신 이상.
* Q3: 트리거가 합계를 다시 계산해 100 + 500 + 50 = 650, 불일치 0.
* 실행 방식 차이: Oracle은 문장 단위 트리거로 모든 주문을 다시 계산했다(단순하지만 비효율적). SQL Server는 inserted/deleted 의사 테이블로 바뀐 주문만 다시 계산했다.

## F. 변형 문제
1. 주문 테이블에 고객명을 중복 저장했다면 고객명이 바뀔 때 무엇을 해야 하는가?
2. 트리거 대신 '조회할 때 계산하는 뷰'를 쓰면 무엇을 얻고 무엇을 잃는가?

G: [../exercises/ex07_denormalization.md](../exercises/ex07_denormalization.md)
