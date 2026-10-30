# Q5. EXISTS·NOT EXISTS — 고객ID만 비교 vs 고객ID+컨텐츠ID 비교

> 출제 의도: EXISTS와 NOT EXISTS, 고객ID만 비교하는 경우와 고객ID+컨텐츠ID를 비교하는 경우 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
찜(X15_WISH)만 해 두고 아직 보지 않은 콘텐츠가 있는 고객에게 알림을 보내려 한다.

## ③ 요구되는 조회 결과
찜한 콘텐츠 가운데 **그 고객이** 아직 시청하지 않은 콘텐츠가 하나라도 있는 고객을 구하라. 열: cust_id

| cust_id |
|---|
| C1 |
| C2 |
| C4 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT c.cust_id FROM x15_customer c WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.cust_id = c.cust_id)
 AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.cust_id = c.cust_id);
```
**보기 ②**
```sql
SELECT c.cust_id FROM x15_customer c WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.cust_id = c.cust_id
 AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.cust_id = s.cust_id AND w.content_id = s.content_id));
```
**보기 ③**
```sql
SELECT c.cust_id FROM x15_customer c WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.cust_id = c.cust_id
 AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.content_id = s.content_id));
```
**보기 ④**
```sql
SELECT DISTINCT s.cust_id FROM x15_wish s JOIN x15_watch w ON w.cust_id = s.cust_id AND w.content_id = s.content_id;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q05_exists_customer_vs_content_oracle.sql -->
```text
== [보기 ①]

View created.

CUST_ID
C4

1 row selected.

== [보기 ②]

View created.

CUST_ID
C1
C2
C4

3 rows selected.

== [보기 ③]

View created.

CUST_ID
C4

1 row selected.

== [보기 ④]

View created.

CUST_ID
C1
C2

2 rows selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|1|DIFF
②|3|MATCH
③|1|DIFF
④|2|DIFF

4 rows selected.

15-Q5-answer-2: CHECK_PASS (3행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q05_exists_customer_vs_content_sqlserver.sql -->
```text
== [보기 ①]
cust_id
-------
C4

(1 rows affected)
== [보기 ②]
cust_id
-------
C1
C2
C4

(3 rows affected)
== [보기 ③]
cust_id
-------
C4

(1 rows affected)
== [보기 ④]
cust_id
-------
C1
C2

(2 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|1|DIFF
②|3|MATCH
③|1|DIFF
④|2|DIFF

(4 rows affected)
15-Q5-answer-2: CHECK_PASS (3행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ②** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: 고객ID만 비교했다. '아무것도 시청하지 않은 고객'이 되어 C4만 나온다. C1은 T3를, C2는 T1을 보지 않았는데도 빠진다.
* 보기 ②: **정답.** (고객ID, 컨텐츠ID) 쌍으로 비교해 '그 고객이 그 콘텐츠를 본 기록이 없는' 찜이 있는지 확인한다.
* 보기 ③: 컨텐츠ID만 비교했다. '누구도 시청하지 않은 콘텐츠'를 찜한 고객이 되어, T4를 찜한 C4만 나온다. C1의 T3는 C3가 봤기 때문에 빠진다.
* 보기 ④: 찜한 콘텐츠를 **시청한** 고객(C1·C2)이다. 요구와 반대다.

## 변형 문제 (외우지 말고 다시 풀기)
'찜한 콘텐츠를 **모두** 시청한 고객'을 구하라. (찜이 있고 NOT EXISTS(찜 중 미시청)인 고객 → 이 데이터에서는 0명. 찜이 없는 C3를 포함할지는 업무 정의에 달려 있다)
