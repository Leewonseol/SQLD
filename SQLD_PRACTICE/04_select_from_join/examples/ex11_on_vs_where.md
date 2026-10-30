# ex11 LEFT JOIN 에서 ON 조건과 WHERE 조건의 배치

> 근거: 요구목록 §9(ON과 WHERE의 조건 배치, LEFT JOIN과 WHERE의 상호작용). PDF E-15의 "ON: JOIN 조건, WHERE: 일반 조건"을 OUTER JOIN에 적용한 것 · 데이터: 학습용 가상 데이터 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **INNER JOIN**에서는 조건을 ON에 두든 WHERE에 두든 결과가 같다.
* **OUTER JOIN**에서는 다르다.
  * ON 조건: "어떤 행과 **짝지을지**"를 정한다. 짝이 없어도 기준(보존) 테이블 행은 남는다.
  * WHERE 조건: 조인이 끝난 뒤 행을 **거른다**. 보존 쪽에 NULL로 채워진 행이 `o.status = 'PAID'`에서 UNKNOWN이 되어 사라진다. 결과적으로 INNER JOIN처럼 된다.
* **기준 테이블 조건을 ON에 두면**(Q5) 기준 행을 거르지 못한다. 짝짓기만 막을 뿐이다. 기준 행을 거르려면 WHERE에 둔다.

## B. 입력 데이터 (학습용 가상 데이터)
* CUST(cust_id PK, cust_name, grade): C01 가나 VIP / C02 다라 GOLD / C03 마바 GOLD / C04 사아 NULL
* ORDERS(order_id PK, cust_id FK NOT NULL, order_date, status, amount): 1001 C01 PAID / 1002 C01 CANCELED / 1003 C02 PAID / 1004 C03 CANCELED

## C. 실행 SQL
[Oracle](ex11_on_vs_where_oracle.sql) · [SQL Server](ex11_on_vs_where_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(ON에 PAID)과 Q2(WHERE에 PAID)의 행 수는?
2. Q5에서 C01(VIP)은 결과에 남는가? 남는다면 order_id는?
3. Q7에서 C03의 paid_cnt와 row_cnt는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex11_on_vs_where_oracle.sql -->
```text
== [Q1] 필터를 ON 에: 고객 4명 모두 남고, PAID 주문만 짝지어진다

CUST_ID|CUST_NAME|ORDER_ID|STATUS
C01|가나|1001|PAID
C02|다라|1003|PAID
C03|마바|(null)|(null)
C04|사아|(null)|(null)

4 rows selected.

== [Q2] 필터를 WHERE 에: 짝이 없는 행(o.status 가 NULL)이 WHERE 에서 제거 -> 사실상 INNER JOIN

CUST_ID|CUST_NAME|ORDER_ID|STATUS
C01|가나|1001|PAID
C02|다라|1003|PAID

2 rows selected.

== [Q3] Oracle (+) 로 Q1 과 같은 결과: 상수 조건에도 (+) 를 붙여야 한다

CUST_ID|CUST_NAME|ORDER_ID|STATUS
C01|가나|1001|PAID
C02|다라|1003|PAID
C03|마바|(null)|(null)
C04|사아|(null)|(null)

4 rows selected.

== [Q4] (+) 를 상수 조건에서 빠뜨리면 Q2 와 같아진다

CUST_ID|CUST_NAME|ORDER_ID|STATUS
C01|가나|1001|PAID
C02|다라|1003|PAID

2 rows selected.

== [Q5] 기준(왼쪽) 테이블 조건을 ON 에 두면 왼쪽 행을 거르지 못한다: GOLD 가 아닌 고객도 그대로 남음

CUST_ID|GRADE|ORDER_ID
C01|VIP|(null)
C02|GOLD|1003
C03|GOLD|1004
C04|(null)|(null)

4 rows selected.

== [Q6] 주문이 하나도 없는 고객 (안티 조인 패턴)

CUST_ID|CUST_NAME
C04|사아

1 row selected.

== [Q7] 고객별 PAID 주문 수(0 포함): COUNT(o.order_id) 는 NULL 을 세지 않는다

CUST_ID|PAID_CNT|ROW_CNT
C01|1|1
C02|1|1
C03|0|1
C04|0|1

4 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex11_on_vs_where_sqlserver.sql -->
```text
== [Q1] 필터를 ON 에
cust_id|cust_name|order_id|status
-------|---------|--------|------
C01|가나|1001|PAID
C02|다라|1003|PAID
C03|마바|NULL|NULL
C04|사아|NULL|NULL

(4 rows affected)
== [Q2] 필터를 WHERE 에
cust_id|cust_name|order_id|status
-------|---------|--------|------
C01|가나|1001|PAID
C02|다라|1003|PAID

(2 rows affected)
== [Q5] 왼쪽 테이블 조건을 ON 에
cust_id|grade|order_id
-------|-----|--------
C01|VIP|NULL
C02|GOLD|1003
C03|GOLD|1004
C04|NULL|NULL

(4 rows affected)
== [Q6] 주문 없는 고객
cust_id|cust_name
-------|---------
C04|사아

(1 rows affected)
== [Q7] 고객별 PAID 주문 수(0 포함)
cust_id|paid_cnt|row_cnt
-------|--------|-------
C01|1|1
C02|1|1
C03|0|1
C04|0|1

(4 rows affected)
```
<!-- /RESULT -->

**행별 이유**
* Q1 4행: C01은 PAID인 1001과만 짝지어진다(1002는 ON에서 탈락). C03은 CANCELED뿐이라 짝이 없어 NULL로 남는다. C04는 주문이 없다.
* Q2 2행: 먼저 LEFT JOIN으로 C01×2, C02, C03, C04(NULL) 5행이 생긴다. WHERE `o.status='PAID'`에서 CANCELED 2행과 NULL 1행이 제거된다.
* Q3·Q4(Oracle): (+) 방식에서는 상수 조건에도 `(+)`를 붙여야 ON 조건이 된다. 빠뜨리면 WHERE 필터가 되어 Q2와 같다.
* Q5 4행: `c.grade='GOLD'`는 짝짓기 조건일 뿐이다. C01(VIP)·C04(NULL)도 남고 order_id만 NULL이다.
* Q7: `COUNT(o.order_id)`는 NULL을 세지 않아 0이 된다. `COUNT(*)`는 NULL로 채워진 행도 세어 1이다. 0건 집계에는 `COUNT(컬럼)`을 쓴다.

## F. 변형 문제
1. Q2의 WHERE를 `WHERE o.status = 'PAID' OR o.status IS NULL`로 바꾸면 Q1과 같아지는가? (아니다. C03은 CANCELED 행이 있어서 NULL 행이 생기지 않는다)
2. Q5에서 GOLD 고객만 남기려면 조건을 어디로 옮기는가?
3. RIGHT JOIN으로 바꿔서 Q1과 같은 결과를 내라.

G: [exercises/ex11_on_vs_where.md](../exercises/ex11_on_vs_where.md)
