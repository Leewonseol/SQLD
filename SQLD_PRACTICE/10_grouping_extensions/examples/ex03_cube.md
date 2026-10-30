# ex03 CUBE

> 근거: PDF추출본 E-30("결합 가능한 모든 값에 대하여 다차원 집계", "시스템에 많은 부담", "인수의 순서가 바뀌어도 […] 결과는 같다", "18개의 행", "UNION ALL […] 총 4개의 SELECT") · 데이터: SCOTT EMP·DEPT · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `CUBE(A, B)` = `GROUPING SETS((A, B), (A), (B), ())`. 인수 n개 → 그룹 기준 2ⁿ개.
* 인수가 서로 **대등**하다. 순서를 바꿔도 행 집합은 같다(출력 순서만 다를 수 있다).
* 그룹 기준이 지수적으로 늘어 비용이 크다.

## B. 입력 데이터
SCOTT EMP·DEPT

## C. 실행 SQL
[Oracle](ex03_cube_oracle.sql) · [SQL Server](ex03_cube_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 행 수는?
2. CUBE(deptno, job, mgr)의 그룹 기준 수는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_cube_oracle.sql -->
```text
== [Q1] PDF 재현: CUBE(DNAME, JOB) = (DNAME,JOB) 9 + DNAME 3 + JOB 5 + 총계 1 = 18행

DNAME|JOB|Total Empl|Total Sal
ACCOUNTING|CLERK|1|1300
ACCOUNTING|MANAGER|1|2450
ACCOUNTING|PRESIDENT|1|5000
ACCOUNTING|(null)|3|8750
RESEARCH|ANALYST|2|6000
RESEARCH|CLERK|2|1900
RESEARCH|MANAGER|1|2975
RESEARCH|(null)|5|10875
SALES|CLERK|1|950
SALES|MANAGER|1|2850
SALES|SALESMAN|4|5600
SALES|(null)|6|9400
(null)|ANALYST|2|6000
(null)|CLERK|4|4150
(null)|MANAGER|3|8275
(null)|PRESIDENT|1|5000
(null)|SALESMAN|4|5600
(null)|(null)|14|29025

18 rows selected.

== [Q2] CUBE(JOB, DNAME) 과 행 집합이 같은가: 차집합 양방향 0행

DIFF_ROWS
0

1 row selected.

== [Q3] 인수 n개 CUBE 의 그룹 조합 수 = 2^n (ROLLUP 은 n+1)

CUBE_SETS
8

1 row selected.

CUBE3_ROWS
52

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_cube_sqlserver.sql -->
```text
== [Q1] CUBE(DNAME, JOB) 18행
dname|job|Total Empl|Total Sal
-----|---|----------|---------
ACCOUNTING|CLERK|1|1300.00
ACCOUNTING|MANAGER|1|2450.00
ACCOUNTING|PRESIDENT|1|5000.00
ACCOUNTING|NULL|3|8750.00
RESEARCH|ANALYST|2|6000.00
RESEARCH|CLERK|2|1900.00
RESEARCH|MANAGER|1|2975.00
RESEARCH|NULL|5|10875.00
SALES|CLERK|1|950.00
SALES|MANAGER|1|2850.00
SALES|SALESMAN|4|5600.00
SALES|NULL|6|9400.00
NULL|ANALYST|2|6000.00
NULL|CLERK|4|4150.00
NULL|MANAGER|3|8275.00
NULL|PRESIDENT|1|5000.00
NULL|SALESMAN|4|5600.00
NULL|NULL|14|29025.00

(18 rows affected)
== [Q2] CUBE 인수 순서 바꿔도 같은 행 집합
diff_rows
---------
0

(1 rows affected)
== [Q3] 3개 인수 CUBE 의 그룹 조합 수와 행 수
cube_sets
---------
8

(1 rows affected)
cube3_rows
----------
52

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 18행 = 9 + 3 + 5 + 1. ROLLUP과 달리 JOB 소계 5행이 추가된다. PDF와 일치한다.
* Q2 차집합 0행 → 순서가 달라도 결과 집합이 같다.
* Q3 그룹 기준 2³ = 8, 실제 행 수 52(조합마다 존재하는 그룹 수의 합).

## F. 변형 문제
1. CUBE(dname, job)에서 JOB 소계만 남기는 HAVING 조건을 써라.
2. CUBE와 같은 결과를 내는 UNION ALL 네 개를 작성하라.

G: [../exercises/ex03_cube.md](../exercises/ex03_cube.md)
