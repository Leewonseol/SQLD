# Q3. LEFT JOIN과 WHERE 조건의 상호작용

> 출제 의도: LEFT JOIN과 WHERE 조건의 상호작용 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
고객별 MOVIE 장르 시청 실적을 보고 싶다.

## ③ 요구되는 조회 결과
모든 고객의 MOVIE 장르 시청 기록 수를 구하라. 시청하지 않은 고객은 0이다. 열: cust_id, movie_cnt

| cust_id | movie_cnt |
|---|---|
| C1 | 1 |
| C2 | 1 |
| C3 | 0 |
| C4 | 0 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT c.cust_id, COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_watch w ON w.cust_id = c.cust_id LEFT JOIN x15_content t ON t.content_id = w.content_id WHERE t.genre = 'MOVIE' GROUP BY c.cust_id;
```
**보기 ②**
```sql
SELECT c.cust_id, COUNT(m.content_id) FROM x15_customer c LEFT JOIN (SELECT w.cust_id, w.content_id FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE') m ON m.cust_id = c.cust_id GROUP BY c.cust_id;
```
**보기 ③**
```sql
SELECT c.cust_id, COUNT(w.content_id) FROM x15_customer c LEFT JOIN x15_watch w ON w.cust_id = c.cust_id LEFT JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE' GROUP BY c.cust_id;
```
**보기 ④**
```sql
SELECT c.cust_id, COUNT(*) FROM x15_customer c LEFT JOIN (SELECT w.cust_id, w.content_id FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id AND t.genre = 'MOVIE') m ON m.cust_id = c.cust_id GROUP BY c.cust_id;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q03_left_join_where_oracle.sql -->
```text
== [보기 ①]

View created.

CUST_ID|MOVIE_CNT
C1|1
C2|1

2 rows selected.

== [보기 ②]

View created.

CUST_ID|MOVIE_CNT
C1|1
C2|1
C3|0
C4|0

4 rows selected.

== [보기 ③]

View created.

CUST_ID|MOVIE_CNT
C1|3
C2|1
C3|1
C4|0

4 rows selected.

== [보기 ④]

View created.

CUST_ID|MOVIE_CNT
C1|1
C2|1
C3|1
C4|1

4 rows selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|2|DIFF
②|4|MATCH
③|4|DIFF
④|4|DIFF

4 rows selected.

15-Q3-answer-2: CHECK_PASS (4행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q03_left_join_where_sqlserver.sql -->
```text
== [보기 ①]
cust_id|movie_cnt
-------|---------
C1|1
C2|1

(2 rows affected)
== [보기 ②]
cust_id|movie_cnt
-------|---------
C1|1
C2|1
C3|0
C4|0

(4 rows affected)
== [보기 ③]
cust_id|movie_cnt
-------|---------
C1|3
C2|1
C3|1
C4|0

(4 rows affected)
== [보기 ④]
cust_id|movie_cnt
-------|---------
C1|1
C2|1
C3|1
C4|1

(4 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|2|DIFF
②|4|MATCH
③|4|DIFF
④|4|DIFF

(4 rows affected)
Warning: Null value is eliminated by an aggregate or other SET operation.
Warning: Null value is eliminated by an aggregate or other SET operation.
15-Q3-answer-2: CHECK_PASS (4행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ②** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: WHERE t.genre = 'MOVIE'가 짝이 없는 행(t.genre NULL)을 지워 C3·C4가 사라진다 → LEFT JOIN이 INNER JOIN처럼 된다.
* 보기 ②: **정답.** MOVIE 시청만 먼저 골라 낸 집합을 LEFT JOIN 하고, COUNT(m.content_id)로 NULL을 0으로 센다.
* 보기 ③: 장르 조건은 content 조인에만 걸려 있고 watch 행은 그대로 남는다. 그래서 COUNT(w.content_id)가 모든 시청(C1 3)을 센다. COUNT(t.content_id)로 고치면 정답이 된다(변형 문제).
* 보기 ④: COUNT(*)는 NULL로 채워진 행도 세어 C3·C4가 1이 된다.

## 변형 문제 (외우지 말고 다시 풀기)
보기 ③의 COUNT(w.content_id)를 COUNT(t.content_id)로 바꾸면 정답이 되는가? (된다. 장르 조건을 통과한 content 쪽 컬럼을 세기 때문이다)
