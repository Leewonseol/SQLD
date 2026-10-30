# ex02 GROUP BY 규칙

> 근거: 요구목록 §7(GROUP BY). 추출본에는 GROUP BY 본문이 없고 E-05·E-06·E-08에 쓰임만 있다 · 데이터: EMP, G_NUM · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* GROUP BY는 지정한 컬럼(또는 표현식) 값이 같은 행끼리 묶어 그룹마다 **1행**을 만든다.
* GROUP BY 뒤의 SELECT·HAVING·ORDER BY에는 **그룹 컬럼, 집계함수, 상수**만 올 수 있다. 그룹 안에 여러 값이 있는 컬럼(ename)은 어느 값을 보여야 할지 정할 수 없어 오류다.
* NULL은 WHERE 비교에서는 어떤 값과도 같지 않지만, GROUP BY에서는 NULL끼리 **한 그룹**으로 모인다.
* 집계 없는 `GROUP BY job` = `SELECT DISTINCT job`(같은 행 집합).

## B. 입력 데이터
EMP, G_NUM(grp: a, a, b, b, NULL)

## C. 실행 SQL
[Oracle](ex02_group_by_rules_oracle.sql) · [SQL Server](ex02_group_by_rules_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 (deptno, job) 그룹 수는?
2. Q3 NULL grp는 결과에 몇 행으로 나오는가?
3. Q6 `SELECT ename, SUM(sal) FROM emp`의 오류 코드는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_group_by_rules_oracle.sql -->
```text
== [Q1] GROUP BY 에 없는 컬럼을 SELECT 에 쓰면 오류
SELECT deptno, ename, COUNT(*) FROM emp GROUP BY deptno
               *
ERROR at line 1:
ORA-00979: not a GROUP BY expression

== [Q2] 여러 컬럼 GROUP BY: (deptno, job) 조합마다 1행

DEPTNO|JOB|CNT|SUM_SAL
10|CLERK|1|1300
10|MANAGER|1|2450
10|PRESIDENT|1|5000
20|ANALYST|2|6000
20|CLERK|2|1900
20|MANAGER|1|2975
30|CLERK|1|950
30|MANAGER|1|2850
30|SALESMAN|4|5600

9 rows selected.

== [Q3] NULL 도 하나의 그룹이 된다 (WHERE 의 = 비교와 다르다)

GRP|CNT|SUM_V
a|2|3
b|2|4
(null)|1|4

3 rows selected.

== [Q4] 집계함수 없는 GROUP BY = DISTINCT 와 같은 행

JOB
ANALYST
CLERK
MANAGER
PRESIDENT
SALESMAN

5 rows selected.

== [Q5] 집계함수만 있고 GROUP BY 가 없으면 전체가 한 그룹

CNT|TOTAL
14|29025

1 row selected.

== [Q6] 집계함수와 일반 컬럼을 GROUP BY 없이 섞으면 오류
SELECT ename, SUM(sal) FROM emp
       *
ERROR at line 1:
ORA-00937: not a single-group group function

== [Q7] GROUP BY 에 표현식 사용

HIRE_YEAR|CNT
1980|1
1981|10
1982|1
1987|2

4 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_group_by_rules_sqlserver.sql -->
```text
== [Q1] GROUP BY 에 없는 컬럼 -> 오류
Msg 8120, Level 16, State 1, Server a70f428a7f8a, Line 2
Column 'emp.ename' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
== [Q2] 여러 컬럼 GROUP BY
deptno|job|cnt|sum_sal
------|---|---|-------
10|CLERK|1|1300.00
10|MANAGER|1|2450.00
10|PRESIDENT|1|5000.00
20|ANALYST|2|6000.00
20|CLERK|2|1900.00
20|MANAGER|1|2975.00
30|CLERK|1|950.00
30|MANAGER|1|2850.00
30|SALESMAN|4|5600.00

(9 rows affected)
== [Q3] NULL 그룹
grp|cnt|sum_v
---|---|-----
NULL|1|4
a|2|3
b|2|4

(3 rows affected)
== [Q4] 집계 없는 GROUP BY
job
---
ANALYST
CLERK
MANAGER
PRESIDENT
SALESMAN

(5 rows affected)
== [Q5] GROUP BY 없는 집계
cnt|total
---|-----
14|29025.00

(1 rows affected)
== [Q6] 집계와 일반 컬럼 혼용 -> 오류
Msg 8120, Level 16, State 1, Server a70f428a7f8a, Line 2
Column 'emp.ename' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
== [Q7] GROUP BY 에 표현식
hire_year|cnt
---------|---
1980|1
1981|10
1982|1
1987|2

(4 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: ename은 그룹 컬럼이 아니다 → ORA-00979 / Msg 8120.
* Q2: 9개 조합(ex03 DISTINCT 결과와 같다).
* Q3: NULL 그룹 1행(cnt 1, sum 4). Oracle은 NULL을 마지막에, SQL Server는 처음에 정렬한다.
* Q6: GROUP BY 없이 집계와 일반 컬럼을 섞으면 Oracle ORA-00937, SQL Server Msg 8120.
* Q7: 1981년 입사자 10명.

## F. 변형 문제
1. `GROUP BY deptno, job`과 `GROUP BY job, deptno`의 결과 행 집합은 같은가? (같다. 순서만 다를 수 있다)
2. `SELECT deptno + 0, COUNT(*) FROM emp GROUP BY deptno`는 실행되는가?
3. `GROUP BY NVL(grp, 'z')`를 쓰면 NULL 그룹은 어떻게 되는가?

G: [../exercises/ex02_group_by_rules.md](../exercises/ex02_group_by_rules.md)
