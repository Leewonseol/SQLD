# ex06 WHERE 절의 집계함수 금지

> 근거: PDF추출본 E-06("집계 함수 사용 불가", "WHERE 절은 각 행을 개별적으로 필터링하기 때문에 […] 집계함수의 사용이 불가능", "해당 조건은 HAVING 절에 넣어주면 된다 GROUP BY department HAVING AVG(salary) > 3000") · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* WHERE는 GROUP BY보다 먼저, 행 하나씩 평가된다. 그 시점에는 그룹도 집계값도 없다. 그래서 WHERE에 `AVG(sal)`를 쓰면 오류다.
* 그룹 조건 → HAVING. 전체 집계와 각 행을 비교 → WHERE 안의 **서브쿼리**(서브쿼리 안에서는 집계 가능).

## B. 입력 데이터
EMP. 부서 평균: 10번 2916.67, 20번 2175, 30번 1566.67. 전체 평균 2073.21.

## C. 실행 SQL
[Oracle](ex06_aggregate_in_where_oracle.sql) · [SQL Server](ex06_aggregate_in_where_sqlserver.sql)

## D. 결과 예측 문제
1. Q1은 두 DBMS에서 어떤 오류 코드를 내는가?
2. Q2 결과 부서는? Q3 결과는 몇 명인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_aggregate_in_where_oracle.sql -->
```text
== [Q1] WHERE 에 집계함수 -> 오류
SELECT deptno FROM emp WHERE AVG(sal) > 2000 GROUP BY deptno
                             *
ERROR at line 1:
ORA-00934: group function is not allowed here

== [Q2] 그룹 조건은 HAVING 으로

DEPTNO|AVG_SAL
10|2916.67
20|2175

2 rows selected.

== [Q3] 전체 집계값과 행을 비교하려면 서브쿼리 (WHERE 안에서 집계는 서브쿼리 안에서만)

ENAME|SAL
KING|5000
FORD|3000
SCOTT|3000
JONES|2975
BLAKE|2850
CLARK|2450

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_aggregate_in_where_sqlserver.sql -->
```text
== [Q1] WHERE 에 집계함수 -> 오류
Msg 147, Level 15, State 1, Server a70f428a7f8a, Line 2
An aggregate may not appear in the WHERE clause unless it is in a subquery contained in a HAVING clause or a select list, and the column being aggregated is an outer reference.
== [Q2] HAVING
deptno|avg_sal
------|-------
10|2916.670000
20|2175.000000

(2 rows affected)
== [Q3] 서브쿼리
ename|sal
-----|---
KING|5000.00
FORD|3000.00
SCOTT|3000.00
JONES|2975.00
BLAKE|2850.00
CLARK|2450.00

(6 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: Oracle ORA-00934 group function is not allowed here, SQL Server Msg 147.
* Q2: 평균이 2000을 넘는 10·20번 부서. SQL Server는 DECIMAL 평균을 소수 6자리로 계산해 ROUND 뒤에도 `2916.670000`으로 표시한다.
* Q3: 전체 평균 2073.21보다 많은 6명.

## F. 변형 문제
1. "부서 평균보다 급여가 많은 사원"은 어떻게 쓰는가? (연관 서브쿼리 → 08단원 ex04)
2. `HAVING sal > 2000`(집계 아님)은 실행되는가? (GROUP BY 컬럼이 아니면 오류)

G: [../exercises/ex06_aggregate_in_where.md](../exercises/ex06_aggregate_in_where.md)
