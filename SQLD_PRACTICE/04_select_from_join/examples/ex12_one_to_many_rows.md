# ex12 1:N 조인과 결과 행 수 증가 (중복 합계 함정)

> 근거: 요구목록 §9(1:N 관계에서 결과 행 수 증가) · 데이터: 학습용 가상 데이터 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇이 일어나는가**: 1쪽(ORDERS) 한 행이 N쪽(ORDER_LINE) k행과 짝지어지면 결과에 k번 나온다. 조인 결과의 행 수는 N쪽 행 수를 따른다.
* **함정**: 1쪽 컬럼(amount)을 조인 뒤에 SUM 하면 k배로 커진다. 오류가 나지 않아 발견하기 어렵다.
* **해결**: (1) 1쪽만으로 집계한다. (2) N쪽을 먼저 집계해 주문당 1행으로 만든 뒤 조인한다(인라인 뷰 → 08단원). (3) 값이 고유하면 `SUM(DISTINCT)`를 쓸 수 있지만, 금액이 우연히 같은 주문이 있으면 틀린다. 권하지 않는다.

## B. 입력 데이터 (학습용 가상 데이터)
ORDERS(order_id PK, cust_id FK, amount): 1001 C01 30000 / 1002 C01 12000 / 1003 C02 50000 / 1004 C03 8000
ORDER_LINE(order_id FK + line_no = PK, item, qty): 1001 3행, 1002 1행, 1003 2행, 1004 1행 = 7행

## C. 실행 SQL
[Oracle](ex12_one_to_many_rows_oracle.sql) · [SQL Server](ex12_one_to_many_rows_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 행 수는?
2. Q2에서 C01의 wrong_sum은 얼마인가? (30000×3 + 12000×1)
3. Q5 행 수와 결과에서 빠지는 고객은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex12_one_to_many_rows_oracle.sql -->
```text
== [Q1] 주문(1) - 주문상세(N) 조인: 결과 행 수 = 주문상세 행 수 7

ORDER_ID|CUST_ID|AMOUNT|LINE_NO|ITEM
1001|C01|30000|1|펜
1001|C01|30000|2|노트
1001|C01|30000|3|자
1002|C01|12000|1|펜
1003|C02|50000|1|가방
1003|C02|50000|2|펜
1004|C03|8000|1|자

7 rows selected.

== [Q2] 함정: 조인 후 주문 금액(1쪽 값)을 SUM 하면 상세 행 수만큼 중복 합산된다

CUST_ID|WRONG_SUM
C01|102000
C02|100000
C03|8000

3 rows selected.

== [Q3] 바른 합계: 1쪽 테이블만으로 집계

CUST_ID|RIGHT_SUM
C01|42000
C02|50000
C03|8000

3 rows selected.

== [Q4] 상세 정보가 함께 필요하면 N쪽을 먼저 집계한 뒤(1행으로 만든 뒤) 조인

CUST_ID|AMOUNT_SUM|LINE_CNT
C01|42000|4
C02|50000|2
C03|8000|1

3 rows selected.

== [Q5] 고객-주문 조인 행 수: 주문 4행. 주문 없는 C04 는 빠지고 C01 은 두 번 나온다

CUST_ID|CUST_NAME|ORDER_ID
C01|가나|1001
C01|가나|1002
C02|다라|1003
C03|마바|1004

4 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex12_one_to_many_rows_sqlserver.sql -->
```text
== [Q1] 주문(1) - 주문상세(N) 조인: 결과 행 수 = 주문상세 행 수 7
order_id|cust_id|amount|line_no|item
--------|-------|------|-------|----
1001|C01|30000|1|펜
1001|C01|30000|2|노트
1001|C01|30000|3|자
1002|C01|12000|1|펜
1003|C02|50000|1|가방
1003|C02|50000|2|펜
1004|C03|8000|1|자

(7 rows affected)
== [Q2] 함정: 조인 후 주문 금액(1쪽 값)을 SUM 하면 상세 행 수만큼 중복 합산된다
cust_id|wrong_sum
-------|---------
C01|102000
C02|100000
C03|8000

(3 rows affected)
== [Q3] 바른 합계: 1쪽 테이블만으로 집계
cust_id|right_sum
-------|---------
C01|42000
C02|50000
C03|8000

(3 rows affected)
== [Q4] 상세 정보가 함께 필요하면 N쪽을 먼저 집계한 뒤(1행으로 만든 뒤) 조인
cust_id|amount_sum|line_cnt
-------|----------|--------
C01|42000|4
C02|50000|2
C03|8000|1

(3 rows affected)
== [Q5] 고객-주문 조인 행 수: 주문 4행. 주문 없는 C04 는 빠지고 C01 은 두 번 나온다
cust_id|cust_name|order_id
-------|---------|--------
C01|가나|1001
C01|가나|1002
C02|다라|1003
C03|마바|1004

(4 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 7행 = ORDER_LINE 행 수. 1001의 amount 30000이 3번 반복된다.
* Q2: C01 = 30000×3 + 12000 = 102000(정답 42000), C02 = 50000×2 = 100000(정답 50000). C03만 상세가 1행이라 우연히 맞는다.
* Q4: N쪽을 주문 단위로 먼저 줄였으니 금액이 한 번씩만 더해진다.
* Q5: 고객(1)–주문(N). C01이 2번 나오고, 주문이 없는 C04는 INNER JOIN에서 빠진다 → 4행.

## F. 변형 문제
1. 1001에 상세 행 1개를 추가하면 Q2의 C01 wrong_sum은?
2. `COUNT(*)`와 `COUNT(DISTINCT o.order_id)`로 고객별 주문 수를 구해 비교하라.
3. PK·FK가 없어 ORDER_LINE에 같은 (order_id, line_no)가 두 번 들어가면 Q1의 행 수는? (15단원 Q1)

G: [exercises/ex12_one_to_many_rows.md](../exercises/ex12_one_to_many_rows.md)
