# Q7. GROUP BY와 윈도우 함수의 차이

> 출제 의도: GROUP BY와 윈도우 함수의 차이 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
시청 기록 상세 화면에 그 고객의 총 시청 횟수를 함께 보여 준다.

## ③ 요구되는 조회 결과
모든 시청 기록(5행)마다 고객ID·콘텐츠ID·시청일(YYYY-MM-DD 문자열)과 그 고객의 전체 시청 기록 수를 구하라. 열: cust_id, content_id, watch_ymd, cust_cnt

| cust_id | content_id | watch_ymd | cust_cnt |
|---|---|---|---|
| C1 | T1 | 2024-03-01 | 3 |
| C1 | T1 | 2024-03-05 | 3 |
| C1 | T2 | 2024-03-02 | 3 |
| C2 | T2 | 2024-03-03 | 1 |
| C3 | T3 | 2024-03-04 | 1 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT cust_id, MAX(content_id), TO_CHAR(MAX(watch_dt), 'YYYY-MM-DD'), COUNT(*) FROM x15_watch GROUP BY cust_id;
```
SQL Server 문법
```sql
SELECT cust_id, MAX(content_id), CONVERT(CHAR(10), MAX(watch_dt), 23), COUNT(*) FROM x15_watch GROUP BY cust_id;
```
**보기 ②**
```sql
SELECT cust_id, content_id, TO_CHAR(watch_dt, 'YYYY-MM-DD'), COUNT(*) FROM x15_watch GROUP BY cust_id, content_id, watch_dt;
```
SQL Server 문법
```sql
SELECT cust_id, content_id, CONVERT(CHAR(10), watch_dt, 23), COUNT(*) FROM x15_watch GROUP BY cust_id, content_id, watch_dt;
```
**보기 ③**
```sql
SELECT cust_id, content_id, TO_CHAR(watch_dt, 'YYYY-MM-DD'), COUNT(*) OVER (PARTITION BY cust_id) FROM x15_watch;
```
SQL Server 문법
```sql
SELECT cust_id, content_id, CONVERT(CHAR(10), watch_dt, 23), COUNT(*) OVER (PARTITION BY cust_id) FROM x15_watch;
```
**보기 ④**
```sql
SELECT w.cust_id, w.content_id, TO_CHAR(w.watch_dt, 'YYYY-MM-DD'), (SELECT COUNT(*) FROM x15_watch x WHERE x.content_id = w.content_id) FROM x15_watch w;
```
SQL Server 문법
```sql
SELECT w.cust_id, w.content_id, CONVERT(CHAR(10), w.watch_dt, 23), (SELECT COUNT(*) FROM x15_watch x WHERE x.content_id = w.content_id) FROM x15_watch w;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q07_group_by_vs_window_oracle.sql -->
```text
== [보기 ①]

View created.

CUST_ID|CONTENT_ID|WATCH_YMD|CUST_CNT
C1|T2|2024-03-05|3
C2|T2|2024-03-03|1
C3|T3|2024-03-04|1

3 rows selected.

== [보기 ②]

View created.

CUST_ID|CONTENT_ID|WATCH_YMD|CUST_CNT
C1|T1|2024-03-01|1
C1|T1|2024-03-05|1
C1|T2|2024-03-02|1
C2|T2|2024-03-03|1
C3|T3|2024-03-04|1

5 rows selected.

== [보기 ③]

View created.

CUST_ID|CONTENT_ID|WATCH_YMD|CUST_CNT
C1|T1|2024-03-01|3
C1|T1|2024-03-05|3
C1|T2|2024-03-02|3
C2|T2|2024-03-03|1
C3|T3|2024-03-04|1

5 rows selected.

== [보기 ④]

View created.

CUST_ID|CONTENT_ID|WATCH_YMD|CUST_CNT
C1|T1|2024-03-01|2
C1|T1|2024-03-05|2
C1|T2|2024-03-02|2
C2|T2|2024-03-03|2
C3|T3|2024-03-04|1

5 rows selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|3|DIFF
②|5|DIFF
③|5|MATCH
④|5|DIFF

4 rows selected.

15-Q7-answer-3: CHECK_PASS (5행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q07_group_by_vs_window_sqlserver.sql -->
```text
== [보기 ①]
cust_id|content_id|watch_ymd|cust_cnt
-------|----------|---------|--------
C1|T2|2024-03-05|3
C2|T2|2024-03-03|1
C3|T3|2024-03-04|1

(3 rows affected)
== [보기 ②]
cust_id|content_id|watch_ymd|cust_cnt
-------|----------|---------|--------
C1|T1|2024-03-01|1
C1|T1|2024-03-05|1
C1|T2|2024-03-02|1
C2|T2|2024-03-03|1
C3|T3|2024-03-04|1

(5 rows affected)
== [보기 ③]
cust_id|content_id|watch_ymd|cust_cnt
-------|----------|---------|--------
C1|T1|2024-03-01|3
C1|T1|2024-03-05|3
C1|T2|2024-03-02|3
C2|T2|2024-03-03|1
C3|T3|2024-03-04|1

(5 rows affected)
== [보기 ④]
cust_id|content_id|watch_ymd|cust_cnt
-------|----------|---------|--------
C1|T1|2024-03-01|2
C1|T1|2024-03-05|2
C1|T2|2024-03-02|2
C2|T2|2024-03-03|2
C3|T3|2024-03-04|1

(5 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|3|DIFF
②|5|DIFF
③|5|MATCH
④|5|DIFF

(4 rows affected)
15-Q7-answer-3: CHECK_PASS (5행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ③** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: GROUP BY cust_id는 고객마다 1행으로 줄여 3행이 된다. MAX로 고른 콘텐츠·시청일은 실제 기록 한 건이 아니라 서로 다른 행의 값을 섞은 것이다.
* 보기 ②: PK 전체로 묶으면 그룹마다 1행이라 COUNT가 모두 1이다.
* 보기 ③: **정답.** 윈도우 함수는 행 수(5)를 유지하면서 파티션(고객) 집계를 붙인다.
* 보기 ④: 연관 조건을 content_id로 잘못 걸어 '콘텐츠별' 시청 수가 된다(T2 2). 스칼라 서브쿼리로도 풀 수 있지만 조건은 x.cust_id = w.cust_id다.

## 변형 문제 (외우지 말고 다시 풀기)
각 시청 기록에 '그 고객의 몇 번째 시청인지'(시청일 순)를 붙여라. (ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY watch_dt))
