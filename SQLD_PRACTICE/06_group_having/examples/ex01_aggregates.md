# ex01 집계 함수와 NULL

> 근거: 요구목록 §7(SUM, COUNT, AVG 등 집계). 추출본에는 집계함수 본문이 없고 E-06·E-32에 쓰임만 있다 · 데이터: G_NUM(학습용 가상 데이터), EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을**: 여러 행을 값 하나로 요약한다. COUNT·SUM·AVG·MAX·MIN·(분산·표준편차)
* **NULL 처리**: `COUNT(*)`만 NULL 행을 센다. 나머지 집계는 NULL을 **무시**한다. 그래서 AVG는 "NULL이 아닌 값의 평균"이다. NULL을 0으로 보려면 `AVG(NVL(v,0))`.
* **빈 집합**: GROUP BY가 없으면 행이 0개여도 결과는 1행이다(COUNT = 0, 나머지 = NULL). GROUP BY가 있으면 그룹이 없어 0행이다.
* **DBMS 차이**: SQL Server는 INT 컬럼의 AVG를 **INT로** 계산한다(소수 버림). 실수 평균은 `AVG(v * 1.0)`이나 `CAST`로 구한다.

## B. 입력 데이터 (학습용 가상 데이터)
G_NUM(id PK, grp, v): (1,a,1) (2,a,2) (3,b,NULL) (4,b,4) (5,NULL,4) · G_EMPTY(v): 0행. Oracle v는 NUMBER(5), SQL Server v는 INT.

## C. 실행 SQL
[Oracle](ex01_aggregates_oracle.sql) · [SQL Server](ex01_aggregates_sqlserver.sql)

## D. 결과 예측 문제
1. COUNT(*), COUNT(v), COUNT(DISTINCT v)는?
2. AVG(v)는 11/5인가 11/4인가? SQL Server에서는?
3. G_EMPTY에서 `SELECT COUNT(*), SUM(v)`는 몇 행인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_aggregates_oracle.sql -->
```text
== [Q1] COUNT(*) 는 행 수, COUNT(컬럼) 은 NULL 이 아닌 값 수, COUNT(DISTINCT) 는 서로 다른 값 수

CNT_STAR|CNT_V|CNT_DIST_V
5|4|3

1 row selected.

== [Q2] SUM·AVG·MAX·MIN 은 NULL 을 무시한다: AVG = 11 / 4 (5 가 아니다)

SUM_V|AVG_V|MAX_V|MIN_V|SUM_DIV_ALL|AVG_NVL
11|2.75|4|1|2.2|2.2

1 row selected.

== [Q3] 정수 컬럼 평균: Oracle 은 NUMBER 라 소수까지 계산 (SQL Server 결과와 비교)

AVG_V
1.5

1 row selected.

== [Q4] 행이 없는 집합의 집계: 집계 결과 1행. COUNT 는 0, 나머지는 NULL

CNT|SUM_V|AVG_V|MAX_V
0|(null)|(null)|(null)

1 row selected.

== [Q5] 같은 빈 집합에 GROUP BY 를 붙이면 그룹이 없으니 0행

no rows selected

== [Q6] 분산·표준편차 함수 이름: Oracle VARIANCE / STDDEV

VAR_SAL|STD_SAL
1398313.87|1182.5

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_aggregates_sqlserver.sql -->
```text
== [Q1] COUNT(*) / COUNT(v) / COUNT(DISTINCT v)
cnt_star|cnt_v|cnt_dist_v
--------|-----|----------
5|4|3

(1 rows affected)
== [Q2] SUM·AVG·MAX·MIN (v 가 INT 라 AVG 도 INT: 11/4 = 2)
sum_v|avg_v|max_v|min_v|sum_div_all|avg_isnull|avg_decimal
-----|-----|-----|-----|-----------|----------|-----------
11|2|4|1|2|2|2.750000

(1 rows affected)
== [Q3] 정수 평균 (1, 2) -> 1 (소수 버림)
avg_v|avg_v_float
-----|-----------
1|1.500000

(1 rows affected)
== [Q4] 빈 집합 집계
cnt|sum_v|avg_v|max_v
---|-----|-----|-----
0|NULL|NULL|NULL

(1 rows affected)
== [Q5] 빈 집합 + GROUP BY
v|cnt
-|---

(0 rows affected)
== [Q6] 분산·표준편차 함수 이름: SQL Server VAR / STDEV
var_sal|std_sal
-------|-------
1398313.8700000001|1182.5

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 5/4/3: NULL 1행 제외 → 4, 서로 다른 값 {1,2,4} → 3.
* Q2: SUM 11, AVG = 11/4 = 2.75(Oracle). `SUM/COUNT(*)` = 11/5 = 2.2 = `AVG(NVL(v,0))`. SQL Server는 정수 연산이라 AVG 2, `SUM/COUNT(*)`도 2다. DECIMAL로 바꾸면 2.750000이다.
* Q3: (1+2)/2. Oracle 1.5, SQL Server 1. **결과가 다르다.**
* Q4·Q5: 빈 집합의 집계는 1행(0, NULL, NULL, NULL)이다. GROUP BY를 붙이면 0행이다.
* Q6: 함수 이름이 다르다(VARIANCE/STDDEV vs VAR/STDEV). 값은 같다. SQL Server는 FLOAT라 `1398313.8700000001`처럼 부동소수 오차가 보인다.

## F. 변형 문제
1. v에 NULL을 하나 더 넣으면 AVG(v)와 AVG(NVL(v,0))는 각각 어떻게 바뀌는가?
2. `SUM(v) + SUM(NULL)`은? (`SUM(NULL)`은 NULL → 전체 NULL)
3. `MAX(grp)`는 NULL 그룹을 고려하는가?

G: [../exercises/ex01_aggregates.md](../exercises/ex01_aggregates.md)
