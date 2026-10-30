# ex05 ORDER BY 와 NULL 정렬

> 근거: PDF추출본 E-08 · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* ORDER BY가 **없으면 출력 순서는 정해져 있지 않다**(PDF: "ORDER BY 절을 명시해야 데이터 정렬이 수행된다"). 같은 쿼리도 실행 계획에 따라 순서가 바뀔 수 있다.
* 기본은 ASC다. 여러 키는 왼쪽부터 우선한다. 키마다 ASC/DESC를 따로 정할 수 있다. 별칭·위치 번호·표현식을 쓸 수 있다.
* **NULL 위치**: Oracle은 NULL을 가장 큰 값으로 본다(ASC에서 마지막). SQL Server는 가장 작은 값으로 본다(ASC에서 처음). Oracle만 `NULLS FIRST | NULLS LAST`를 지원한다.
* 정렬할 수 있는 컬럼
  * 일반 SELECT: SELECT에 없는 컬럼도 된다.
  * SELECT DISTINCT: SELECT 목록에 있는 것만 된다(ORA-01791 / Msg 145).
  * GROUP BY 뒤: 그룹 컬럼과 집계만 된다. **SELECT에 없어도 된다.** PDF E-08은 "SELECT 절에 있는 컬럼만 가능"이라고 썼지만, 두 DBMS 모두 Q8을 실행한다.
* 동점이면 순서가 정해지지 않는다. 결과를 확정하려면 고유한 2차 키를 붙인다.

## B. 입력 데이터
EMP 30번 부서 comm: ALLEN 300, WARD 500, MARTIN 1400, BLAKE NULL, TURNER 0, JAMES NULL.

## C. 실행 SQL
[Oracle](ex05_order_by_oracle.sql) · [SQL Server](ex05_order_by_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(ASC)에서 BLAKE·JAMES는 두 DBMS에서 각각 어디에 오는가?
2. Q6, Q7은 왜 오류인가?
3. Q8은 실행되는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_order_by_oracle.sql -->
```text
== [Q1] ASC 기본: Oracle 은 NULL 을 가장 큰 값으로 보아 맨 뒤에

ENAME|COMM
TURNER|0
ALLEN|300
WARD|500
MARTIN|1400
BLAKE|(null)
JAMES|(null)

6 rows selected.

== [Q2] DESC: NULL 이 맨 앞

ENAME|COMM
BLAKE|(null)
JAMES|(null)
MARTIN|1400
WARD|500
ALLEN|300
TURNER|0

6 rows selected.

== [Q3] NULLS FIRST / NULLS LAST 로 위치 지정 (PDF 의 "NULL LAST | NULL FISRT" 는 오기, 정확한 키워드는 NULLS)

ENAME|COMM
BLAKE|(null)
JAMES|(null)
TURNER|0
ALLEN|300
WARD|500
MARTIN|1400

6 rows selected.

ENAME|COMM
MARTIN|1400
WARD|500
ALLEN|300
TURNER|0
BLAKE|(null)
JAMES|(null)

6 rows selected.

== [Q4] 별칭·위치 번호·표현식, 여러 키와 서로 다른 방향

DEPTNO|ENAME|ANNUAL
20|SMITH|9600
20|ADAMS|13200
20|JONES|35700
20|FORD|36000
20|SCOTT|36000
10|MILLER|15600
10|CLARK|29400
10|KING|60000

8 rows selected.

== [Q5] SELECT 에 없는 컬럼으로 정렬 (GROUP BY·DISTINCT 가 없으면 허용)

ENAME
KING
CLARK
MILLER

3 rows selected.

== [Q6] DISTINCT 와 SELECT 에 없는 컬럼 정렬 -> 오류
SELECT DISTINCT job FROM emp ORDER BY sal
                                      *
ERROR at line 1:
ORA-01791: not a SELECTed expression

== [Q7] GROUP BY 후 그룹 컬럼도 집계도 아닌 컬럼으로 정렬 -> 오류
SELECT deptno, COUNT(*) FROM emp GROUP BY deptno ORDER BY ename
                                                          *
ERROR at line 1:
ORA-00979: not a GROUP BY expression

== [Q8] GROUP BY 후 SELECT 에 없는 '그룹 컬럼'이나 '집계'로 정렬 -> 허용 (PDF E-08 서술과 비교)

DEPTNO|CNT
20|2
10|1
20|2
30|1

4 rows selected.

DEPTNO
30
20
10

3 rows selected.

== [Q9] 인라인 뷰 안의 ORDER BY: Oracle 은 허용

ENAME|SAL
KING|5000
SCOTT|3000

2 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_order_by_sqlserver.sql -->
```text
== [Q1] ASC: SQL Server 는 NULL 을 가장 작은 값으로 보아 맨 앞에
ename|comm
-----|----
BLAKE|NULL
JAMES|NULL
TURNER|.00
ALLEN|300.00
WARD|500.00
MARTIN|1400.00

(6 rows affected)
== [Q2] DESC: NULL 이 맨 뒤
ename|comm
-----|----
MARTIN|1400.00
WARD|500.00
ALLEN|300.00
TURNER|.00
BLAKE|NULL
JAMES|NULL

(6 rows affected)
== [Q3] NULLS LAST 키워드 없음 -> 구문 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near 'NULLS'.
== [Q3b] CASE 로 NULLS FIRST / NULLS LAST 흉내
ename|comm
-----|----
BLAKE|NULL
JAMES|NULL
TURNER|.00
ALLEN|300.00
WARD|500.00
MARTIN|1400.00

(6 rows affected)
ename|comm
-----|----
MARTIN|1400.00
WARD|500.00
ALLEN|300.00
TURNER|.00
BLAKE|NULL
JAMES|NULL

(6 rows affected)
== [Q4] 별칭·위치 번호·여러 키
deptno|ename|annual
------|-----|------
20|SMITH|9600.00
20|ADAMS|13200.00
20|JONES|35700.00
20|FORD|36000.00
20|SCOTT|36000.00
10|MILLER|15600.00
10|CLARK|29400.00
10|KING|60000.00

(8 rows affected)
== [Q5] SELECT 에 없는 컬럼으로 정렬
ename
-----
KING
CLARK
MILLER

(3 rows affected)
== [Q6] DISTINCT + SELECT 에 없는 컬럼 정렬 -> 오류
Msg 145, Level 15, State 1, Server a70f428a7f8a, Line 2
ORDER BY items must appear in the select list if SELECT DISTINCT is specified.
== [Q7] GROUP BY + 비그룹 컬럼 정렬 -> 오류
Msg 8127, Level 16, State 1, Server a70f428a7f8a, Line 2
Column "emp.ename" is invalid in the ORDER BY clause because it is not contained in either an aggregate function or the GROUP BY clause.
== [Q8] GROUP BY + SELECT 에 없는 그룹 컬럼·집계 정렬 -> 허용
deptno|cnt
------|---
20|2
10|1
20|2
30|1

(4 rows affected)
deptno
------
30
20
10

(3 rows affected)
== [Q9] 파생 테이블 안의 ORDER BY (TOP 없이) -> 오류
Msg 1033, Level 15, State 1, Server a70f428a7f8a, Line 2
The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
```
<!-- /RESULT -->

**이유**
* Q1·Q2: Oracle은 ASC에서 NULL이 마지막, DESC에서 처음이다. SQL Server는 반대다. PDF E-08과 일치한다.
* Q3: Oracle `NULLS FIRST/LAST`. SQL Server는 구문 오류라서 `CASE WHEN comm IS NULL THEN 0 ELSE 1 END`를 첫 번째 정렬 키로 넣어 흉내 낸다(Q3b).
* Q4: 1번 위치(deptno) DESC → annual ASC → ename. 36000 동점(FORD·SCOTT)은 ename으로 정했다.
* Q6: DISTINCT 뒤에는 job 하나에 sal 값이 여러 개라 정렬 기준을 정할 수 없다. Q7: ename도 같은 이유다.
* Q8: job은 GROUP BY 컬럼이고, MAX(sal)는 집계다. 둘 다 SELECT에 없어도 정렬된다.
* Q9: Oracle은 인라인 뷰 안의 ORDER BY를 허용한다(TOP-N 패턴). SQL Server는 TOP·OFFSET이 없으면 Msg 1033이다. 3000 동점인 SCOTT·FORD 중 SCOTT이 나온 것은 이번 실행의 우연이다.
* 표시 차이: SQL Server DECIMAL 0은 sqlcmd에서 `.00`으로 표시된다.

## F. 변형 문제
1. Oracle에서 `ORDER BY comm DESC NULLS LAST`와 SQL Server 기본 `ORDER BY comm DESC`의 결과는 같은가?
2. `ORDER BY 3`인데 SELECT 목록이 2개뿐이면? (Oracle ORA-01785, SQL Server Msg 108 — 미실행·문법 검토)
3. 문자열 정렬에서 대소문자가 섞이면 두 DBMS의 순서는? (04단원 ex09 Q5)

G: [../exercises/ex05_order_by.md](../exercises/ex05_order_by.md)
