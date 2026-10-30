# ex09 서브쿼리 주의사항 2: 기본키가 2개 이상인 테이블

> 근거: PDF추출본 E-23(order_items, PRIMARY KEY(order_id, product_id), "조인할 테이블들의 기본키가 2개 이상이라면 WHERE 절에서 조인(=)에 사용되는 기본키에도 두 키를 모두 사용"). '주의사항 1'은 추출본에 없다 · 데이터: ORDER_ITEMS — 구조는 PDF, 값은 학습용 가상 데이터 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 복합 PK(order_id, product_id)에서 한 행을 정확히 찾으려면 두 키를 **모두** 비교한다.
* 키 하나만 비교하면 같은 주문의 여러 품목이 걸린다. 집계가 있으면 '행 금액'이 '주문 합계'로 바뀌고(의미 오류, 오류 메시지 없음), 집계가 없으면 2행 이상이라 오류가 난다.

## B. 입력 데이터
ORDER_ITEMS — 구조는 PDF, 값은 학습용 가상 데이터 (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex09_composite_key_subquery_oracle.sql) · [SQL Server](ex09_composite_key_subquery_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 각 행의 total_amount는?
2. Q2 order_id 1의 값은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex09_composite_key_subquery_oracle.sql -->
```text
== [Q1] PDF 쿼리: 두 키(order_id, product_id)를 모두 비교 -> 각 행의 금액 (자기 행 하나만 합산)

ORDER_ID|PRODUCT_ID|QUANTITY|PRICE|TOTAL_AMOUNT
1|10|2|1000|2000
1|20|1|5000|5000
2|10|3|1000|3000
2|30|1|2500|2500
3|20|2|5000|10000

5 rows selected.

== [Q2] 키 하나(order_id)만 비교 -> 같은 주문의 모든 품목이 합산되어 '주문 합계'가 된다 (의미가 바뀜)

ORDER_ID|PRODUCT_ID|ORDER_TOTAL
1|10|7000
1|20|7000
2|10|5500
2|30|5500
3|20|10000

5 rows selected.

== [Q3] 집계 없이 단일 값을 가져오는 스칼라 서브쿼리에서 키 하나만 비교 -> 2행 이상 -> 오류
SELECT a.order_id, a.product_id, (SELECT b.quantity FROM order_items b WHERE b.order_id = a.order_id) AS q FROM order_items a
                                  *
ERROR at line 1:
ORA-01427: single-row subquery returns more than one row
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex09_composite_key_subquery_sqlserver.sql -->
```text
== [Q1] 두 키 모두 비교
order_id|product_id|quantity|price|total_amount
--------|----------|--------|-----|------------
1|10|2|1000.00|2000.00
1|20|1|5000.00|5000.00
2|10|3|1000.00|3000.00
2|30|1|2500.00|2500.00
3|20|2|5000.00|10000.00

(5 rows affected)
== [Q2] 키 하나만 비교
order_id|product_id|order_total
--------|----------|-----------
1|10|7000.00
1|20|7000.00
2|10|5500.00
2|30|5500.00
3|20|10000.00

(5 rows affected)
== [Q3] 키 하나 + 집계 없음 -> 오류
Msg 512, Level 16, State 1, Server a70f428a7f8a, Line 2
Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
```
<!-- /RESULT -->

**이유**
* Q1: 자기 행 하나만 합산 → quantity × price.
* Q2: 주문 1의 두 품목 2000 + 5000 = 7000이 두 행에 똑같이 붙는다.
* Q3: 집계 없는 스칼라 서브쿼리 → ORA-01427 / Msg 512.

## F. 변형 문제
1. 주문별 합계와 품목 금액을 함께 출력하되, 주문 합계는 키 하나 비교로 의도적으로 구하라. 열 이름으로 의미를 구별하라.
2. 04단원 ex12(1:N 중복 합계)와 이 실습의 공통 원인을 한 문장으로 설명하라.

G: [../exercises/ex09_composite_key_subquery.md](../exercises/ex09_composite_key_subquery.md)
