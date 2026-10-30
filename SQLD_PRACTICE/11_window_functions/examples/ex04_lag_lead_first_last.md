# ex04 LAG · LEAD · FIRST_VALUE · LAST_VALUE

> 근거: PDF추출본 E-34("LAG(SAL, N, NULL 대체값)", FIRST_VALUE·LAST_VALUE, "(SQL Server AIX)", LAST_VALUE의 기본 프레임 설명 V1·MAX·MIN) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `LAG(x, n, d)`: n행 **앞**의 x. 없으면 d(생략하면 NULL). `LEAD`: n행 **뒤**. 파티션 경계를 넘지 않는다.
* `FIRST_VALUE(x)`: 프레임의 첫 값. `LAST_VALUE(x)`: 프레임의 마지막 값.
  * **함정**: ORDER BY가 있으면 기본 프레임 끝이 '현재 행'이라 LAST_VALUE는 현재 행 자신의 값이 된다. 파티션 전체의 마지막 값을 원하면 프레임을 `… UNBOUNDED FOLLOWING`까지 늘린다.
* `IGNORE NULLS`: NULL을 건너뛴 값. Oracle은 괄호 안(`LAG(c IGNORE NULLS)`), SQL Server 2022는 괄호 밖(`LAG(c) IGNORE NULLS OVER`)에 쓴다.

## B. 입력 데이터
EMP

## C. 실행 SQL
[Oracle](ex04_lag_lead_first_last_oracle.sql) · [SQL Server](ex04_lag_lead_first_last_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 ALLEN의 PREV_SAL과 PREV_OR0은?
2. Q4 V1 열의 값은?
3. SQL Server 2022에서 FIRST_VALUE·LAST_VALUE는 실행되는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_lag_lead_first_last_oracle.sql -->
```text
== [Q1] LAG(col, n, 기본값): n행 앞 값, 없으면 기본값(생략 시 NULL) / LEAD: n행 뒤

ENAME|HIREDATE|SAL|PREV_SAL|PREV_OR0|NEXT_SAL|NEXT2
ALLEN|1981-02-20|1600|(null)|0|1250|2850
WARD|1981-02-22|1250|1600|1600|2850|1500
BLAKE|1981-05-01|2850|1250|1250|1500|1250
TURNER|1981-09-08|1500|2850|2850|1250|950
MARTIN|1981-09-28|1250|1500|1500|950|(null)
JAMES|1981-12-03|950|1250|1250|(null)|(null)

6 rows selected.

== [Q2] PARTITION BY 와 LAG: 각 파티션의 첫 행은 이전 값이 없어 NULL

DEPTNO|ENAME|SAL|PREV_IN_DEPT
10|MILLER|1300|(null)
10|CLARK|2450|1300
10|KING|5000|2450
20|SMITH|800|(null)
20|ADAMS|1100|800
20|JONES|2975|1100
20|FORD|3000|2975
20|SCOTT|3000|3000

8 rows selected.

== [Q3] FIRST_VALUE: 정렬 순서상 첫 값 -> 부서 최저(ASC)·최고(DESC) 급여

DEPTNO|ENAME|SAL|MIN_SAL|MAX_SAL
10|MILLER|1300|1300|5000
10|CLARK|2450|1300|5000
10|KING|5000|1300|5000

3 rows selected.

== [Q4] PDF 함정: LAST_VALUE 의 기본 프레임은 '처음 ~ 현재 행' -> 현재 행 값(V1)이 나온다

DEPTNO|ENAME|SAL|V1|MAX_SAL|MIN_SAL
10|MILLER|1300|1300|5000|1300
10|CLARK|2450|2450|5000|1300
10|KING|5000|5000|5000|1300

3 rows selected.

== [Q5] PDF 예: FIRST_VALUE(ENAME) ... ROWS UNBOUNDED PRECEDING -> 부서 최고 급여자 이름

ENAME|DEPTNO|SAL|ENAME_FV
KING|10|5000|KING
CLARK|10|2450|KING
MILLER|10|1300|KING
FORD|20|3000|FORD
SCOTT|20|3000|FORD
JONES|20|2975|FORD
ADAMS|20|1100|FORD
SMITH|20|800|FORD

8 rows selected.

== [Q6] IGNORE NULLS: comm 이 NULL 이 아닌 직전 값

ENAME|COMM|LAG_IGN|LAST_NONNULL
ALLEN|300|(null)|300
WARD|500|300|500
MARTIN|1400|500|1400
BLAKE|(null)|1400|1400
TURNER|0|1400|0
JAMES|(null)|0|0

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_lag_lead_first_last_sqlserver.sql -->
```text
== [Q1] LAG / LEAD
ename|hiredate|sal|prev_sal|prev_or0|next_sal|next2
-----|--------|---|--------|--------|--------|-----
ALLEN|1981-02-20|1600.00|NULL|.00|1250.00|2850.00
WARD|1981-02-22|1250.00|1600.00|1600.00|2850.00|1500.00
BLAKE|1981-05-01|2850.00|1250.00|1250.00|1500.00|1250.00
TURNER|1981-09-08|1500.00|2850.00|2850.00|1250.00|950.00
MARTIN|1981-09-28|1250.00|1500.00|1500.00|950.00|NULL
JAMES|1981-12-03|950.00|1250.00|1250.00|NULL|NULL

(6 rows affected)
== [Q2] PARTITION BY 와 LAG
deptno|ename|sal|prev_in_dept
------|-----|---|------------
10|MILLER|1300.00|NULL
10|CLARK|2450.00|1300.00
10|KING|5000.00|2450.00
20|SMITH|800.00|NULL
20|ADAMS|1100.00|800.00
20|JONES|2975.00|1100.00
20|FORD|3000.00|3000.00
20|SCOTT|3000.00|2975.00

(8 rows affected)
== [Q3] FIRST_VALUE (SQL Server 2012+ 지원)
deptno|ename|sal|min_sal|max_sal
------|-----|---|-------|-------
10|MILLER|1300.00|1300.00|5000.00
10|CLARK|2450.00|1300.00|5000.00
10|KING|5000.00|1300.00|5000.00

(3 rows affected)
== [Q4] LAST_VALUE 기본 프레임 함정
deptno|ename|sal|v1|max_sal|min_sal
------|-----|---|--|-------|-------
10|MILLER|1300.00|1300.00|5000.00|1300.00
10|CLARK|2450.00|2450.00|5000.00|1300.00
10|KING|5000.00|5000.00|5000.00|1300.00

(3 rows affected)
== [Q5] FIRST_VALUE(ENAME) ROWS UNBOUNDED PRECEDING
ename|deptno|sal|ename_fv
-----|------|---|--------
KING|10|5000.00|KING
CLARK|10|2450.00|KING
MILLER|10|1300.00|KING
FORD|20|3000.00|FORD
SCOTT|20|3000.00|FORD
JONES|20|2975.00|FORD
ADAMS|20|1100.00|FORD
SMITH|20|800.00|FORD

(8 rows affected)
== [Q6] IGNORE NULLS (SQL Server 2022 부터)
ename|comm|lag_ign|last_nonnull
-----|----|-------|------------
ALLEN|300.00|NULL|300.00
WARD|500.00|300.00|500.00
MARTIN|1400.00|500.00|1400.00
BLAKE|NULL|1400.00|1400.00
TURNER|.00|1400.00|.00
JAMES|NULL|.00|.00

(6 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 30번 부서 입사일 순. 첫 행 ALLEN은 이전이 없어 NULL / 기본값 0. LEAD(…, 2)는 두 행 뒤 값이다.
* Q2: 부서가 바뀌면 다시 NULL에서 시작한다. 20번 부서 FORD·SCOTT은 sal 동점이다. Oracle은 FORD→SCOTT, SQL Server는 SCOTT→FORD 순으로 처리해 prev 값이 **서로 바뀌었다**(동점 정렬은 단정할 수 없다).
* Q4: V1 = 1300, 2450, 5000(현재 행). PDF와 일치한다. 프레임을 늘리면 MAX 5000, DESC로 바꾸면 MIN 1300.
* SQL Server에서 FIRST_VALUE·LAST_VALUE가 실행되었다. PDF E-34의 "SQL Server 지원X"는 **SQL Server 2012 이상에는 맞지 않는다.**
* Q6: BLAKE(NULL)의 이전 NULL 아닌 값은 MARTIN 1400이다.

## F. 변형 문제
1. 각 사원의 직전 입사자와의 급여 차이를 구하라(첫 사원은 0).
2. 부서별 최저 급여자 이름을 LAST_VALUE로 구하라(프레임 지정 필수).

G: [../exercises/ex04_lag_lead_first_last.md](../exercises/ex04_lag_lead_first_last.md)
