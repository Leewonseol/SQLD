# Q2. 1:N 관계 두 개를 함께 조인할 때의 행 수 증가

> 출제 의도: 1:N 관계에서 결과 행 수 증가 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
고객은 결제를 여러 번 하고(X15_PAYMENT) 시청도 여러 번 한다(X15_WATCH). 결제와 시청은 서로 관계가 없다.

## ③ 요구되는 조회 결과
회원 고객별 결제 총액(결제 대기 NULL은 합계에서 제외)과 시청 기록 수를 한 행에 구하라. 결제나 시청이 없는 고객도 0으로 나와야 한다. 열: cust_id, pay_sum, watch_cnt

| cust_id | pay_sum | watch_cnt |
|---|---|---|
| C1 | 20000 | 3 |
| C2 | 0 | 1 |
| C3 | 5000 | 1 |
| C4 | 0 | 0 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT c.cust_id, NVL(SUM(p.amount), 0), COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
```
SQL Server 문법
```sql
SELECT c.cust_id, ISNULL(SUM(p.amount), 0), COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
```
**보기 ②**
```sql
SELECT c.cust_id, NVL(SUM(DISTINCT p.amount), 0), COUNT(DISTINCT w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
```
SQL Server 문법
```sql
SELECT c.cust_id, ISNULL(SUM(DISTINCT p.amount), 0), COUNT(DISTINCT w.content_id) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
```
**보기 ③**
```sql
SELECT c.cust_id, NVL(p.s, 0), NVL(w.n, 0) FROM x15_customer c
 LEFT JOIN (SELECT cust_id, SUM(amount) s FROM x15_payment GROUP BY cust_id) p ON p.cust_id = c.cust_id
 LEFT JOIN (SELECT cust_id, COUNT(*) n FROM x15_watch GROUP BY cust_id) w ON w.cust_id = c.cust_id;
```
SQL Server 문법
```sql
SELECT c.cust_id, ISNULL(p.s, 0), ISNULL(w.n, 0) FROM x15_customer c
 LEFT JOIN (SELECT cust_id, SUM(amount) s FROM x15_payment GROUP BY cust_id) p ON p.cust_id = c.cust_id
 LEFT JOIN (SELECT cust_id, COUNT(*) n FROM x15_watch GROUP BY cust_id) w ON w.cust_id = c.cust_id;
```
**보기 ④**
```sql
SELECT c.cust_id, NVL(SUM(p.amount), 0), COUNT(*) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
```
SQL Server 문법
```sql
SELECT c.cust_id, ISNULL(SUM(p.amount), 0), COUNT(*) FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id LEFT JOIN x15_watch w ON w.cust_id = c.cust_id GROUP BY c.cust_id;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q02_one_to_many_double_count_oracle.sql -->
```text
== [보기 ①]

View created.

CUST_ID|PAY_SUM|WATCH_CNT
C1|60000|6
C2|0|1
C3|5000|1
C4|0|0

4 rows selected.

== [보기 ②]

View created.

CUST_ID|PAY_SUM|WATCH_CNT
C1|10000|2
C2|0|1
C3|5000|1
C4|0|0

4 rows selected.

== [보기 ③]

View created.

CUST_ID|PAY_SUM|WATCH_CNT
C1|20000|3
C2|0|1
C3|5000|1
C4|0|0

4 rows selected.

== [보기 ④]

View created.

CUST_ID|PAY_SUM|WATCH_CNT
C1|60000|6
C2|0|1
C3|5000|1
C4|0|1

4 rows selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|4|DIFF
②|4|DIFF
③|4|MATCH
④|4|DIFF

4 rows selected.

15-Q2-answer-3: CHECK_PASS (4행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q02_one_to_many_double_count_sqlserver.sql -->
```text
== [보기 ①]
cust_id|pay_sum|watch_cnt
-------|-------|---------
C1|60000|6
C2|0|1
C3|5000|1
C4|0|0

(4 rows affected)
== [보기 ②]
cust_id|pay_sum|watch_cnt
-------|-------|---------
C1|10000|2
C2|0|1
C3|5000|1
C4|0|0

(4 rows affected)
== [보기 ③]
cust_id|pay_sum|watch_cnt
-------|-------|---------
C1|20000|3
C2|0|1
C3|5000|1
C4|0|0

(4 rows affected)
== [보기 ④]
cust_id|pay_sum|watch_cnt
-------|-------|---------
C1|60000|6
C2|0|1
C3|5000|1
C4|0|1

(4 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|4|DIFF
②|4|DIFF
③|4|MATCH
④|4|DIFF

(4 rows affected)
Warning: Null value is eliminated by an aggregate or other SET operation.
Warning: Null value is eliminated by an aggregate or other SET operation.
15-Q2-answer-3: CHECK_PASS (4행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ③** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: C1은 결제 2건 × 시청 3건 = 6행으로 늘어 결제 합계가 60000, 시청 수가 6이 된다(C2도 결제 1 × 시청 1이라 우연히 맞다).
* 보기 ②: SUM(DISTINCT)는 같은 금액(10000·10000)을 한 번만 더해 C1이 10000이 된다. COUNT(DISTINCT content_id)는 시청 기록이 아니라 콘텐츠 수(C1 2)다.
* 보기 ③: **정답.** 두 N쪽을 각각 고객 단위로 먼저 집계(1행)한 뒤 조인하면 행이 늘지 않는다. 결제 대기(NULL)는 SUM에서 빠져 C2가 0(NVL)이 된다.
* 보기 ④: 보기 ①과 같은 곱셈 문제가 있고, COUNT(*)는 짝이 없는 행도 세어 C4가 1이 된다.

## 변형 문제 (외우지 말고 다시 풀기)
C1의 시청이 1건뿐이라면 보기 ①은 정답과 같은 결과가 나오는가? (예. 데이터가 우연히 맞으면 오답 SQL도 맞는 결과를 낸다. 시험 데이터 하나로 SQL을 검증하면 안 되는 이유다)
