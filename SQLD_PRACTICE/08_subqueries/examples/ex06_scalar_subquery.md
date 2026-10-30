# ex06 스칼라 서브쿼리

> 근거: PDF추출본 E-20(paintings·artists 예, "OUTER JOIN 연산을 사용한 결과와 같다", "매칭되는 데이터가 없는 경우 […] NULL로 표현 (생략되는 게 아님)", DEPT 이름 예, SUM(SAL) 총계 예) · 데이터: PAINTINGS 8행, ARTISTS 5행 — PDF 원문 값 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* SELECT 절에서 **행마다 값 1개**(1행 1열)를 돌려주는 서브쿼리다.
* 짝이 없으면 NULL이다. 행이 사라지지 않으므로 결과는 LEFT OUTER JOIN과 같다(작가 쪽 키가 PK라 짝이 최대 1개일 때).
* 2행 이상 → ORA-01427 / Msg 512. 2개 컬럼 → ORA-00913 / Msg 116.
* 집계 결과를 행마다 붙일 때도 쓴다(Q4). 같은 일을 윈도우 함수 `SUM(sal) OVER ()`로도 할 수 있다(11단원).

## B. 입력 데이터
PAINTINGS 8행, ARTISTS 5행 — PDF 원문 값 (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex06_scalar_subquery_oracle.sql) · [SQL Server](ex06_scalar_subquery_sqlserver.sql)

## D. 결과 예측 문제
1. 108 여행(작가 10번)의 artist_name은? 결과에서 빠지는가?
2. Q3(두 결과의 차집합 행 수)은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_scalar_subquery_oracle.sql -->
```text
== [Q1] PDF 예: 각 그림의 작가 이름을 스칼라 서브쿼리로 (108 여행은 작가 10번이 없어 NULL)

ID|NAME|PRICE|ARTIST_NAME
101|숲과나|1100000|이지현
102|밤의 도시|1350000|이지현
103|파도|470000|황현석
104|Pop!|750000|박성진
105|너|640000|백에서
106|밤비|920000|정하나
107|기억|380000|정하나
108|여행|150000|(null)

8 rows selected.

== [Q2] PDF: "스칼라 서브쿼리는 OUTER JOIN 결과와 같다" -> LEFT JOIN

ID|NAME|PRICE|ARTIST_NAME
101|숲과나|1100000|이지현
102|밤의 도시|1350000|이지현
103|파도|470000|황현석
104|Pop!|750000|박성진
105|너|640000|백에서
106|밤비|920000|정하나
107|기억|380000|정하나
108|여행|150000|(null)

8 rows selected.

== [Q3] 두 결과가 같은지 집합 연산으로 검증 (차집합 0행이면 같음)

DIFF_ROWS
0

1 row selected.

== [Q4] PDF 예: 사원 정보와 전체 급여 합계를 한 행에 (집계를 스칼라 값으로)

EMPNO|ENAME|DEPTNO|SAL|TOTAL_SAL
7782|CLARK|10|2450|29025
7839|KING|10|5000|29025
7934|MILLER|10|1300|29025

3 rows selected.

== [Q5] 스칼라 서브쿼리가 2행 이상을 돌려주면 오류
SELECT d.dname, (SELECT e.ename FROM emp e WHERE e.deptno = d.deptno) AS ename FROM dept d
                 *
ERROR at line 1:
ORA-01427: single-row subquery returns more than one row

== [Q6] 스칼라 서브쿼리가 2개 컬럼을 돌려주면 오류
SELECT d.dname, (SELECT MIN(e.sal), MAX(e.sal) FROM emp e WHERE e.deptno = d.deptno) AS x FROM dept d
                 *
ERROR at line 1:
ORA-00913: too many values
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_scalar_subquery_sqlserver.sql -->
```text
== [Q1] 스칼라 서브쿼리
id|name|price|artist_name
--|----|-----|-----------
101|숲과나|1100000|이지현
102|밤의 도시|1350000|이지현
103|파도|470000|황현석
104|Pop!|750000|박성진
105|너|640000|백에서
106|밤비|920000|정하나
107|기억|380000|정하나
108|여행|150000|NULL

(8 rows affected)
== [Q2] LEFT JOIN
id|name|price|artist_name
--|----|-----|-----------
101|숲과나|1100000|이지현
102|밤의 도시|1350000|이지현
103|파도|470000|황현석
104|Pop!|750000|박성진
105|너|640000|백에서
106|밤비|920000|정하나
107|기억|380000|정하나
108|여행|150000|NULL

(8 rows affected)
== [Q3] 두 결과 비교
diff_rows
---------
0

(1 rows affected)
== [Q4] 전체 급여 합계를 한 행에
empno|ename|deptno|sal|total_sal
-----|-----|------|---|---------
7782|CLARK|10|2450.00|29025.00
7839|KING|10|5000.00|29025.00
7934|MILLER|10|1300.00|29025.00

(3 rows affected)
== [Q5] 스칼라 서브쿼리 2행 이상 -> 오류
Msg 512, Level 16, State 1, Server a70f428a7f8a, Line 2
Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
== [Q6] 스칼라 서브쿼리 2개 컬럼 -> 오류
Msg 116, Level 16, State 1, Server a70f428a7f8a, Line 2
Only one expression can be specified in the select list when the subquery is not introduced with EXISTS.
```
<!-- /RESULT -->

**이유**
* Q1·Q2 8행. 108은 NULL로 남는다. PDF 결과표와 일치한다.
* Q3 0: 스칼라 서브쿼리와 LEFT JOIN의 결과가 같다(외부검증으로 PDF 서술 확인).
* Q4: 사원별로 전체 합계 29025가 붙는다.
* Q5: 부서마다 사원이 여러 명이라 오류. Q6: 두 컬럼이라 오류.

## F. 변형 문제
1. 작가 테이블에 같은 id가 두 번 들어간다면(PK가 없다면) Q1과 Q2는 각각 어떻게 되는가?
2. 각 사원 옆에 자기 부서의 평균 급여를 스칼라 서브쿼리로 붙여라.

G: [../exercises/ex06_scalar_subquery.md](../exercises/ex06_scalar_subquery.md)
