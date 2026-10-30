# Q6. 결제 기록이 없는 고객 — NOT IN과 NULL

> 출제 의도: NULL이 결과를 바꾸는 경우, EXISTS와 NOT EXISTS (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
비회원 결제(cust_id NULL)와 결제 대기(amount NULL)가 섞여 있다.

## ③ 요구되는 조회 결과
결제 기록(금액과 관계없이)이 한 건도 없는 회원 고객을 구하라. 열: cust_id

| cust_id |
|---|
| C4 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT cust_id FROM x15_customer WHERE cust_id NOT IN (SELECT cust_id FROM x15_payment);
```
**보기 ②**
```sql
SELECT c.cust_id FROM x15_customer c WHERE NOT EXISTS (SELECT 1 FROM x15_payment p WHERE p.cust_id = c.cust_id);
```
**보기 ③**
```sql
SELECT c.cust_id FROM x15_customer c LEFT JOIN x15_payment p ON p.cust_id = c.cust_id WHERE p.amount IS NULL;
```
**보기 ④**
```sql
SELECT cust_id FROM x15_customer WHERE cust_id NOT IN (SELECT cust_id FROM x15_payment WHERE amount IS NOT NULL);
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q06_not_in_null_oracle.sql -->
```text
== [보기 ①]

View created.

no rows selected

== [보기 ②]

View created.

CUST_ID
C4

1 row selected.

== [보기 ③]

View created.

CUST_ID
C2
C4

2 rows selected.

== [보기 ④]

View created.

no rows selected

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|0|DIFF
②|1|MATCH
③|2|DIFF
④|0|DIFF

4 rows selected.

15-Q6-answer-2: CHECK_PASS (1행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q06_not_in_null_sqlserver.sql -->
```text
== [보기 ①]
cust_id
-------

(0 rows affected)
== [보기 ②]
cust_id
-------
C4

(1 rows affected)
== [보기 ③]
cust_id
-------
C2
C4

(2 rows affected)
== [보기 ④]
cust_id
-------

(0 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|0|DIFF
②|1|MATCH
③|2|DIFF
④|0|DIFF

(4 rows affected)
15-Q6-answer-2: CHECK_PASS (1행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ②** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: 결제의 cust_id 목록에 NULL(비회원 결제)이 있어 NOT IN이 항상 UNKNOWN이 된다 → 0행.
* 보기 ②: **정답.** NOT EXISTS는 NULL과 상관없다.
* 보기 ③: '짝이 없는 행' 판정을 amount로 했다. 결제 대기 C2(amount NULL)까지 나온다 → C2, C4. 판정은 반대쪽 PK(p.pay_id IS NULL)로 한다.
* 보기 ④: amount IS NOT NULL로 C2의 대기 건을 뺐지만 비회원 결제(cust_id NULL, amount 3000)는 남아 목록에 NULL이 들어간다 → 0행.

## 변형 문제 (외우지 말고 다시 풀기)
비회원 결제 행(pay_id 5)이 없다면 보기 ①은? (C4가 나와 정답과 같아진다. 데이터 한 행이 SQL의 정오를 바꾼다)
