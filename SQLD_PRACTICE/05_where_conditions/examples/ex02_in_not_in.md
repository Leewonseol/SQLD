# ex02 IN · NOT IN 과 NULL

> 근거: PDF추출본 E-06(IN (list) "리스트에 있는 값", NOT IN "리스트에 없는 값"), 요구목록 §7 · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `x IN (a, b)`는 `x = a OR x = b`다. `x NOT IN (a, b)`는 `x <> a AND x <> b`다.
* **NULL 함정**: `x NOT IN (a, NULL)` = `x <> a AND x <> NULL`이다. `x <> NULL`은 항상 UNKNOWN이므로 전체가 TRUE가 될 수 없다. **결과는 항상 0행**이다. 서브쿼리가 NULL을 하나라도 돌려주면 똑같이 0행이 된다(08단원 ex05).
* `IN (…, NULL)`은 NULL인 행을 찾지 못한다. NULL을 찾으려면 `OR x IS NULL`을 쓴다.
* 다중 컬럼 IN `(a, b) IN ((1,'x'), …)`은 Oracle만 지원한다.

## B. 입력 데이터
EMP. mgr 값: 7698(5명), 7839(3명), 7566(2명), 7902, 7788, 7782(각 1명), NULL(KING).

## C. 실행 SQL
[Oracle](ex02_in_not_in_oracle.sql) · [SQL Server](ex02_in_not_in_sqlserver.sql)

## D. 결과 예측 문제
1. Q3 `mgr NOT IN (7839)`의 건수는 14 − 3 = 11인가?
2. Q4 `mgr NOT IN (7839, NULL)`의 건수는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_in_not_in_oracle.sql -->
```text
== [Q1] IN (목록) = OR 의 연속

ENAME|MGR
ALLEN|7698
WARD|7698
JONES|7839
MARTIN|7698
BLAKE|7839
CLARK|7839
TURNER|7698
JAMES|7698

8 rows selected.

== [Q2] IN 목록에 NULL 을 넣어도 mgr 이 NULL 인 KING 은 나오지 않는다 (NULL = NULL 은 UNKNOWN)

ENAME|MGR
JONES|7839
BLAKE|7839
CLARK|7839

3 rows selected.

== [Q3] NOT IN (7839) : mgr 이 NULL 인 KING 은 'mgr <> 7839' 가 UNKNOWN 이라 제외

CNT
10

1 row selected.

== [Q4] NOT IN 목록에 NULL 이 하나라도 있으면 결과는 항상 0행

CNT
0

1 row selected.

== [Q5] 다중 컬럼 IN (Oracle 지원)

ENAME|DEPTNO|JOB
SCOTT|20|ANALYST
FORD|20|ANALYST
MILLER|10|CLERK

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_in_not_in_sqlserver.sql -->
```text
== [Q1] IN (목록)
ename|mgr
-----|---
ALLEN|7698
WARD|7698
JONES|7839
MARTIN|7698
BLAKE|7839
CLARK|7839
TURNER|7698
JAMES|7698

(8 rows affected)
== [Q2] IN 목록의 NULL
ename|mgr
-----|---
JONES|7839
BLAKE|7839
CLARK|7839

(3 rows affected)
== [Q3] NOT IN (7839)
cnt
---
10

(1 rows affected)
== [Q4] NOT IN 목록에 NULL
cnt
---
0

(1 rows affected)
== [Q5] 다중 컬럼 IN -> SQL Server 미지원(구문 오류)
Msg 4145, Level 15, State 1, Server a70f428a7f8a, Line 2
An expression of non-boolean type specified in a context where a condition is expected, near ','.
== [Q6] 다중 컬럼 IN 대체: OR 로 풀어 쓰기
ename|deptno|job
-----|------|---
SCOTT|20|ANALYST
FORD|20|ANALYST
MILLER|10|CLERK

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 8행: 7698 부하 5명 + 7839 부하 3명.
* Q2 3행: 목록의 NULL은 아무 행과도 같지 않다. KING(mgr NULL)도 나오지 않는다.
* Q3 **10**: 11이 아니다. KING은 `NULL <> 7839`가 UNKNOWN이라 빠진다.
* Q4 **0**: 목록에 NULL이 있으면 모든 행이 UNKNOWN 또는 FALSE다.
* Q5: Oracle은 3행(SCOTT·FORD·MILLER). SQL Server는 Msg 4145이고, OR로 풀어 써야 한다(Q6).

## F. 변형 문제
1. Q3에서 KING까지 포함하려면 조건을 어떻게 바꾸는가?
2. `deptno IN (SELECT deptno FROM dept WHERE loc = 'BOSTON')`은 몇 행인가? (40번 부서에는 사원이 없다)
3. `NOT IN (SELECT mgr FROM emp)`로 "부하가 없는 사원"을 찾으면 왜 0행인가?

G: [../exercises/ex02_in_not_in.md](../exercises/ex02_in_not_in.md)
