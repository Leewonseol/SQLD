# Q1. PK 누락으로 생긴 JOIN 결과 오류

> 출제 의도: PK·FK 누락으로 발생하는 JOIN 오류 (§9) · 데이터: 학습용 가상 데이터(스트리밍 서비스, [ERD](../explanation.md)) · 검증: Oracle 21c / SQL Server 2022 실행. 각 보기의 MATCH/DIFF는 DBMS가 판정했다.

## ① ERD
[단원 안내의 ERD](../explanation.md#erd)를 본다. X15_CUSTOMER 1 : N X15_WATCH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_WISH N : 1 X15_CONTENT, X15_CUSTOMER 1 : N X15_PAYMENT(비회원 결제는 cust_id NULL).

## ② 업무 설명
콘텐츠 마스터를 이관하면서 PK를 만들지 않았다. 그 결과 X15_CONTENT_NOPK에 T1이 두 번(제목만 다르게) 들어갔다. 장르는 같다.

## ③ 요구되는 조회 결과
장르별 시청 기록 수를 구하라(시청 기록 X15_WATCH 기준, 장르는 X15_CONTENT_NOPK에서 가져온다). 열: genre, cnt

| genre | cnt |
|---|---|
| DOCU | 1 |
| EDU | 2 |
| MOVIE | 2 |

## ④ SQL 보기 (정답은 하나)
**보기 ①**
```sql
SELECT c.genre, COUNT(*) FROM x15_watch w JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
```
**보기 ②**
```sql
SELECT c.genre, COUNT(*) FROM x15_watch w JOIN (SELECT DISTINCT content_id, genre FROM x15_content_nopk) c ON w.content_id = c.content_id GROUP BY c.genre;
```
**보기 ③**
```sql
SELECT c.genre, COUNT(DISTINCT w.content_id) FROM x15_watch w JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
```
**보기 ④**
```sql
SELECT c.genre, COUNT(c.content_id) FROM x15_watch w LEFT JOIN x15_content_nopk c ON w.content_id = c.content_id GROUP BY c.genre;
```

## ⑤ 각 보기가 만드는 결과 비교 (실제 실행)
Oracle 21c XE
<!-- RESULT: q01_missing_pk_join_oracle.sql -->
```text
== [보기 ①]

View created.

GENRE|CNT
DOCU|1
EDU|4
MOVIE|2

3 rows selected.

== [보기 ②]

View created.

GENRE|CNT
DOCU|1
EDU|2
MOVIE|2

3 rows selected.

== [보기 ③]

View created.

GENRE|CNT
DOCU|1
EDU|1
MOVIE|1

3 rows selected.

== [보기 ④]

View created.

GENRE|CNT
DOCU|1
EDU|4
MOVIE|2

3 rows selected.

View created.

== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)

CHOICE|ROWS_CNT|VERDICT
①|3|DIFF
②|3|MATCH
③|3|DIFF
④|3|DIFF

4 rows selected.

15-Q1-answer-2: CHECK_PASS (3행)

PL/SQL procedure successfully completed.

View dropped.

View dropped.

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: q01_missing_pk_join_sqlserver.sql -->
```text
== [보기 ①]
genre|cnt
-----|---
DOCU|1
EDU|4
MOVIE|2

(3 rows affected)
== [보기 ②]
genre|cnt
-----|---
DOCU|1
EDU|2
MOVIE|2

(3 rows affected)
== [보기 ③]
genre|cnt
-----|---
DOCU|1
EDU|1
MOVIE|1

(3 rows affected)
== [보기 ④]
genre|cnt
-----|---
DOCU|1
EDU|4
MOVIE|2

(3 rows affected)
== [비교] 각 보기의 결과가 요구 결과와 같은가 (MATCH / DIFF)
choice|rows_cnt|verdict
------|--------|-------
①|3|DIFF
②|3|MATCH
③|3|DIFF
④|3|DIFF

(4 rows affected)
15-Q1-answer-2: CHECK_PASS (3행)
```
<!-- /RESULT -->

## ⑥ 정답과 오답 원인
**정답: 보기 ②** (위 비교표에서 MATCH가 이 보기 하나이고, lab_check가 CHECK_PASS다)

* 보기 ①: T1이 마스터에 2행이라 C1의 T1 시청 2건이 각각 2배가 된다 → EDU 4. PK가 없으면 '1쪽'이 실제로는 N쪽이 되어 행이 늘어난다.
* 보기 ②: **정답.** content_id·genre를 DISTINCT로 줄여 콘텐츠당 1행으로 만든 뒤 조인한다 → EDU 2. 근본 해결은 마스터에 PK를 만들고 중복을 정리하는 것이다.
* 보기 ③: 시청 '기록 수'가 아니라 '서로 다른 콘텐츠 수'를 센다 → EDU 1, MOVIE 1.
* 보기 ④: LEFT JOIN이어도 중복 마스터 때문에 EDU 4이고, COUNT(c.content_id)도 4를 센다.

## 변형 문제 (외우지 말고 다시 풀기)
마스터의 두 번째 T1 행의 genre가 'LIVE'였다면 보기 ②의 결과는 어떻게 되는가? (EDU 2와 LIVE 2가 함께 나와 합계가 7이 된다 → DISTINCT로도 해결되지 않는다. 데이터 정제와 PK가 필요하다)
