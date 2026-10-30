# ex06 TOP-N 과 행 제한

> 근거: PDF추출본 E-36(ROWNUM 잘못된 사용 1·2, 올바른 사용, "예외: TOP-N 분석"), 요구목록 §7(TOP-N과 행 제한) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **Oracle ROWNUM**: 행을 읽어 WHERE를 통과할 때마다 1, 2, 3…을 붙이는 가상 컬럼이다. WHERE 단계에서 붙고, ORDER BY보다 **먼저** 붙는다.
  * `ROWNUM > 1`, `ROWNUM = 3`은 0행이다. 첫 행이 1을 받고 탈락하면 다음 행이 다시 1을 받는다(PDF E-36).
  * 상위 N개를 구하려면 인라인 뷰에서 먼저 정렬한 뒤 바깥에서 `ROWNUM <= N`을 건다.
* **Oracle 12c+**: `ORDER BY … FETCH FIRST n ROWS ONLY | WITH TIES`, `FETCH FIRST n PERCENT ROWS ONLY`, `OFFSET m ROWS FETCH NEXT n ROWS ONLY`.
* **SQL Server**: `TOP (n)`, `TOP (n) WITH TIES`(ORDER BY 필수), `TOP (n) PERCENT`, `ORDER BY … OFFSET m ROWS FETCH NEXT n ROWS ONLY`(ORDER BY 필수).
* 행 제한은 논리적 처리의 **마지막** 단계다. ORDER BY가 없거나 동점이 있으면 어떤 행이 남는지 단정할 수 없다.
* 윈도우 함수(ROW_NUMBER·RANK)를 쓴 TOP-N은 11단원 ex03.

## B. 입력 데이터
EMP 급여 순: KING 5000, SCOTT·FORD 3000(동점), JONES 2975, BLAKE 2850, CLARK 2450, …

## C. 실행 SQL
[Oracle](ex06_top_n_oracle.sql) · [SQL Server](ex06_top_n_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 `ROWNUM > 1`, Q2 `ROWNUM = 3`의 건수는?
2. Q5(PDF의 잘못된 상위 3명 쿼리)는 KING을 포함하는가?
3. `FETCH FIRST 2 ROWS WITH TIES`는 몇 행인가? 20 PERCENT는 몇 행인가(14 × 0.2 = 2.8)?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_top_n_oracle.sql -->
```text
== [Q1] WHERE ROWNUM > 1 : 오류는 없지만 0행 (첫 행이 ROWNUM 1 이라 탈락 -> 다음 행이 다시 1 ...)

CNT
0

1 row selected.

== [Q2] WHERE ROWNUM = 3 : 0행 (1, 2 가 먼저 부여되지 않으면 3 에 도달하지 못한다)

CNT
0

1 row selected.

== [Q3] WHERE ROWNUM >= 1 : 전체 14행 / ROWNUM = 1 : 1행

GE1|EQ1
14|1

1 row selected.

== [Q4] ROWNUM <= 3 : 3행. 어떤 3행인지는 읽는 순서(실행 계획)에 달려 있다 -> 단정 불가

ROWNUM|ENAME|SAL
1|SMITH|800
2|ALLEN|1600
3|WARD|1250

3 rows selected.

== [Q5] PDF 의 '잘못된 상위 3명' 쿼리: ROWNUM 이 ORDER BY 보다 먼저 -> 먼저 읽힌 3행을 정렬할 뿐

ENAME|SAL
ALLEN|1600
WARD|1250
SMITH|800

3 rows selected.

== [Q6] 올바른 TOP-N: 인라인 뷰에서 먼저 정렬(동점은 ename 으로 결정) -> 바깥에서 ROWNUM

RN|ENAME|SAL
1|KING|5000
2|FORD|3000
3|SCOTT|3000

3 rows selected.

== [Q7] 12c 이상: FETCH FIRST n ROWS ONLY / WITH TIES / PERCENT / OFFSET

ENAME|SAL
KING|5000
FORD|3000
SCOTT|3000

3 rows selected.

ENAME|SAL
KING|5000
SCOTT|3000
FORD|3000

3 rows selected.

PCT20_ROWS
3

1 row selected.

ENAME|SAL
JONES|2975
BLAKE|2850
CLARK|2450

3 rows selected.

== [Q8] 페이지 처리(4~6위)를 ROWNUM 으로: 안쪽에서 ROWNUM 을 별칭으로 고정해야 바깥에서 > 비교 가능

RN|ENAME|SAL
4|JONES|2975
5|BLAKE|2850
6|CLARK|2450

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_top_n_sqlserver.sql -->
```text
== [Q1] ROWNUM 은 없는 컬럼 -> 오류
Msg 207, Level 16, State 1, Server a70f428a7f8a, Line 2
Invalid column name 'ROWNUM'.
== [Q4] ORDER BY 없는 TOP 3 : 어떤 3행인지 단정 불가
ename|sal
-----|---
SMITH|800.00
ALLEN|1600.00
WARD|1250.00

(3 rows affected)
== [Q6] TOP 3 + ORDER BY (동점은 ename)
ename|sal
-----|---
KING|5000.00
FORD|3000.00
SCOTT|3000.00

(3 rows affected)
== [Q7] TOP 2 WITH TIES / TOP 20 PERCENT / OFFSET-FETCH
ename|sal
-----|---
KING|5000.00
FORD|3000.00
SCOTT|3000.00

(3 rows affected)
pct20_rows
----------
3

(1 rows affected)
ename|sal
-----|---
JONES|2975.00
BLAKE|2850.00
CLARK|2450.00

(3 rows affected)
== [Q9] WITH TIES 에 ORDER BY 없음 -> 오류
Msg 1062, Level 15, State 1, Server a70f428a7f8a, Line 2
The TOP N WITH TIES clause is not allowed without a corresponding ORDER BY clause.
== [Q10] OFFSET-FETCH 에 ORDER BY 없음 -> 구문 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near '3'.
Msg 153, Level 15, State 2, Server a70f428a7f8a, Line 2
Invalid usage of the option NEXT in the FETCH statement.
```
<!-- /RESULT -->

**이유**
* Q1·Q2 0행, Q3 `>= 1` 14행 / `= 1` 1행. PDF E-36과 일치한다.
* Q4: ORDER BY가 없는 ROWNUM/TOP은 "먼저 읽힌" 3행이다. 이번 실행에서는 두 DBMS 모두 입력 순서(SMITH·ALLEN·WARD)였지만 **보장되지 않는다.**
* Q5: 먼저 읽힌 3행(SMITH·ALLEN·WARD)을 정렬했을 뿐이다 → ALLEN 1600, WARD 1250, SMITH 800. PDF 결과표와 같다. KING이 없다.
* Q6: 정렬한 뒤 ROWNUM → KING, FORD, SCOTT.
* Q7 WITH TIES: 2번째 행(3000)과 같은 값인 행까지 포함해 3행이다. 동점 두 행의 순서는 Oracle SCOTT→FORD, SQL Server FORD→SCOTT로 **다르게 나왔다.** 20 PERCENT는 2.8을 올림해 3행이다(두 DBMS 같음). OFFSET 3 FETCH 3 = 4~6위(JONES·BLAKE·CLARK).
* Q8: ROWNUM으로 4~6위를 구하려면 안쪽에서 `ROWNUM AS rn`으로 값을 고정해야 한다. 바깥에서 `rn > 3`으로 거른다.
* SQL Server: ROWNUM은 없는 컬럼(Msg 207), WITH TIES·OFFSET은 ORDER BY 없이 오류(Msg 1062, Msg 102·153).

## F. 변형 문제
1. 급여 하위 3명을 두 DBMS 문법으로 각각 구하라.
2. `WHERE ROWNUM <= 3 AND deptno = 20`은 "20번 부서의 처음 3명"인가 "처음 3명 중 20번 부서"인가?
3. 동점을 포함한 상위 2개 급여 "값"(KING, 3000 동점자 전부)을 구하는 세 가지 방법(WITH TIES, DENSE_RANK, 서브쿼리)을 비교하라.

G: [../exercises/ex06_top_n.md](../exercises/ex06_top_n.md)
