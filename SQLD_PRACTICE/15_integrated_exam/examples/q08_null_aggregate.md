# Q8. NULL이 집계 결과를 바꾸는 경우

> 출제 의도: NULL이 결과를 바꾸는 경우 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
결제 대기(amount NULL)는 아직 금액이 정해지지 않은 건이다. 비회원 결제도 결제 금액에는 포함한다.

## ③ 요구되는 조회 결과
금액이 확정된 결제 건의 평균 금액을 구하라(결제 대기 건은 평균 계산에서 아예 제외한다). 열: avg_amt

| avg_amt |
|---|
| 7000 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT SUM(amount) / COUNT(*) FROM x15_payment;
```
**보기 ②**
```sql
SELECT AVG(NVL(amount, 0)) FROM x15_payment;
```
SQL Server 문법
```sql
SELECT AVG(ISNULL(amount, 0)) FROM x15_payment;
```
**보기 ③**
```sql
SELECT AVG(amount) FROM x15_payment;
```
**보기 ④**
```sql
SELECT AVG(amount) FROM x15_payment p JOIN x15_customer c ON p.cust_id = c.cust_id;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q08_null_aggregate_oracle.sql -->
```text
== [보기 ①]

View created.

AVG_AMT
5600

1 row selected.

== [보기 ②]

View created.

AVG_AMT
5600

1 row selected.

== [보기 ③]

View created.

AVG_AMT
7000

1 row selected.

== [보기 ④]

View created.

AVG_AMT
8333.33333

1 row selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|1|DIFF
②|1|DIFF
③|1|MATCH
④|1|DIFF

4 rows selected.

15-Q8-answer-3: CHECK_PASS (1행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q08_null_aggregate_sqlserver.sql -->
```text
== [보기 ①]
avg_amt
-------
5600

(1 rows affected)
== [보기 ②]
avg_amt
-------
5600

(1 rows affected)
== [보기 ③]
avg_amt
-------
7000

(1 rows affected)
== [보기 ④]
avg_amt
-------
8333

(1 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|1|DIFF
②|1|DIFF
③|1|MATCH
④|1|DIFF

(4 rows affected)
Warning: Null value is eliminated by an aggregate or other SET operation.
Warning: Null value is eliminated by an aggregate or other SET operation.
15-Q8-answer-3: CHECK_PASS (1행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ③** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: 분모 COUNT(*)가 결제 대기까지 세어 28000 / 5 = 5600이다.
* 보기 ②: NULL을 0으로 바꿔 평균에 포함시켰다 → 5600.
* 보기 ③: **정답.** AVG는 NULL을 제외하고 (10000 + 10000 + 5000 + 3000) / 4 = 7000을 계산한다.
* 보기 ④: 고객과 INNER JOIN 하면서 비회원 결제(3000)가 빠져 25000 / 3 = 8333.33…이다(SQL Server는 INT 평균이라 8333).

## 변형 문제 (외우지 말고 다시 풀기)
x15_payment.amount가 INT인 SQL Server에서 결제 금액이 10000, 5000, 3000 세 건뿐이라면 AVG(amount)는? (18000 / 3 = 6000으로 나누어떨어진다. 10001이 섞이면 정수 평균이라 소수가 버려진다 — 06단원 ex01)
