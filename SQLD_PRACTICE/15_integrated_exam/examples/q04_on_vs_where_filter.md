# Q4. 기준 테이블 조건을 ON에 둘 것인가 WHERE에 둘 것인가

> 출제 의도: ON과 WHERE의 조건 배치 차이 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
GOLD 등급 고객만 대상으로 찜 목록 크기를 본다.

## ③ 요구되는 조회 결과
GOLD 등급 고객의 찜 수를 구하라(찜이 없으면 0). 열: cust_id, wish_cnt

| cust_id | wish_cnt |
|---|---|
| C2 | 2 |
| C3 | 0 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id AND c.grade = 'GOLD' GROUP BY c.cust_id;
```
**보기 ②**
```sql
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
```
**보기 ③**
```sql
SELECT c.cust_id, COUNT(s.content_id) FROM x15_customer c JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
```
**보기 ④**
```sql
SELECT c.cust_id, COUNT(*) FROM x15_customer c LEFT JOIN x15_wish s ON s.cust_id = c.cust_id WHERE c.grade = 'GOLD' GROUP BY c.cust_id;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q04_on_vs_where_filter_oracle.sql -->
```text
== [보기 ①]

View created.

CUST_ID|WISH_CNT
C1|0
C2|2
C3|0
C4|0

4 rows selected.

== [보기 ②]

View created.

CUST_ID|WISH_CNT
C2|2
C3|0

2 rows selected.

== [보기 ③]

View created.

CUST_ID|WISH_CNT
C2|2

1 row selected.

== [보기 ④]

View created.

CUST_ID|WISH_CNT
C2|2
C3|1

2 rows selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|4|DIFF
②|2|MATCH
③|1|DIFF
④|2|DIFF

4 rows selected.

15-Q4-answer-2: CHECK_PASS (2행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q04_on_vs_where_filter_sqlserver.sql -->
```text
== [보기 ①]
cust_id|wish_cnt
-------|--------
C1|0
C2|2
C3|0
C4|0

(4 rows affected)
== [보기 ②]
cust_id|wish_cnt
-------|--------
C2|2
C3|0

(2 rows affected)
== [보기 ③]
cust_id|wish_cnt
-------|--------
C2|2

(1 rows affected)
== [보기 ④]
cust_id|wish_cnt
-------|--------
C2|2
C3|1

(2 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|4|DIFF
②|2|MATCH
③|1|DIFF
④|2|DIFF

(4 rows affected)
Warning: Null value is eliminated by an aggregate or other SET operation.
Warning: Null value is eliminated by an aggregate or other SET operation.
15-Q4-answer-2: CHECK_PASS (2행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ②** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: 기준(왼쪽) 테이블 조건을 ON에 두면 짝짓기만 막고 행은 거르지 않는다 → VIP C1(0)·등급 없는 C4(0)까지 4행.
* 보기 ②: **정답.** 대상 고객은 WHERE로 거르고, 짝짓기는 ON으로 한다.
* 보기 ③: INNER JOIN이라 찜이 없는 C3가 빠진다.
* 보기 ④: COUNT(*)는 C3의 NULL 행을 세어 1이 된다.

## 변형 문제 (외우지 말고 다시 풀기)
등급이 NULL인 C4도 'GOLD가 아닌 고객'으로 함께 보려면 WHERE를 어떻게 쓰는가? (`WHERE c.grade <> 'GOLD' OR c.grade IS NULL`)
