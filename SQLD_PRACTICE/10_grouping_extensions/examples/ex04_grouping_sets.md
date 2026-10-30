# ex04 GROUPING SETS

> 근거: PDF추출본 E-31("평등한 관계", "자동으로 총계가 출력되지 않는다", "GROUPING SETS (A, B, ())나 GROUPING SETS (A, B, NULL)", "8개의 행", UNION ALL 대체) · 데이터: SCOTT EMP·DEPT · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 원하는 그룹 기준만 골라 나열한다. 총계는 `()`를 넣어야 나온다.
* ROLLUP·CUBE는 GROUPING SETS의 약식 표현이다(Q5).
* PDF의 `NULL` 표기는 Oracle에서만 총계를 만든다. SQL Server는 상수를 GROUP BY 식으로 받지 않아 Msg 164다.

## B. 입력 데이터
SCOTT EMP·DEPT

## C. 실행 SQL
[Oracle](ex04_grouping_sets_oracle.sql) · [SQL Server](ex04_grouping_sets_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 행 수와 총계 포함 여부는?
2. Q3(NULL 표기)은 두 DBMS에서 어떻게 되는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_grouping_sets_oracle.sql -->
```text
== [Q1] PDF 재현: GROUPING SETS (DNAME, JOB) = DNAME 소계 3 + JOB 소계 5 = 8행 (총계 없음)

DNAME|JOB|Total Empl|Total Sal
ACCOUNTING|(null)|3|8750
RESEARCH|(null)|5|10875
SALES|(null)|6|9400
(null)|ANALYST|2|6000
(null)|CLERK|4|4150
(null)|MANAGER|3|8275
(null)|PRESIDENT|1|5000
(null)|SALESMAN|4|5600

8 rows selected.

== [Q2] 총계를 추가: () 표기 -> 9행

DNAME|JOB|CNT
ACCOUNTING|(null)|3
RESEARCH|(null)|5
SALES|(null)|6
(null)|ANALYST|2
(null)|CLERK|4
(null)|MANAGER|3
(null)|PRESIDENT|1
(null)|SALESMAN|4
(null)|(null)|14

9 rows selected.

== [Q3] PDF 의 다른 표기 GROUPING SETS (A, B, NULL): Oracle 은 허용 (SQL Server 는 오류 -> sqlserver 파일 Q3)

DNAME|JOB|CNT
ACCOUNTING|(null)|3
RESEARCH|(null)|5
SALES|(null)|6
(null)|ANALYST|2
(null)|CLERK|4
(null)|MANAGER|3
(null)|PRESIDENT|1
(null)|SALESMAN|4
(null)|(null)|14

9 rows selected.

== [Q4] PDF: UNION ALL 로 대체 가능 — 두 번째 SELECT 의 NULL AS DNAME 은 NULL 만 써도 된다

DNAME|JOB|Total Empl|Total Sal
ACCOUNTING|(null)|3|8750
RESEARCH|(null)|5|10875
SALES|(null)|6|9400
(null)|ANALYST|2|6000
(null)|CLERK|4|4150
(null)|MANAGER|3|8275
(null)|PRESIDENT|1|5000
(null)|SALESMAN|4|5600

8 rows selected.

== [Q5] 동치 관계: ROLLUP(a, b) = GROUPING SETS ((a, b), (a), ()), CUBE(a, b) = GROUPING SETS ((a, b), (a), (b), ())

ROLLUP_ROWS|GS_ROLLUP_ROWS|CUBE_ROWS|GS_CUBE_ROWS
13|13|18|18

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_grouping_sets_sqlserver.sql -->
```text
== [Q1] GROUPING SETS (DNAME, JOB) 8행
dname|job|Total Empl|Total Sal
-----|---|----------|---------
ACCOUNTING|NULL|3|8750.00
RESEARCH|NULL|5|10875.00
SALES|NULL|6|9400.00
NULL|ANALYST|2|6000.00
NULL|CLERK|4|4150.00
NULL|MANAGER|3|8275.00
NULL|PRESIDENT|1|5000.00
NULL|SALESMAN|4|5600.00

(8 rows affected)
== [Q2] () 로 총계 추가
dname|job|cnt
-----|---|---
ACCOUNTING|NULL|3
RESEARCH|NULL|5
SALES|NULL|6
NULL|ANALYST|2
NULL|CLERK|4
NULL|MANAGER|3
NULL|PRESIDENT|1
NULL|SALESMAN|4
NULL|NULL|14

(9 rows affected)
== [Q3] PDF 표기 GROUPING SETS (A, B, NULL) -> SQL Server 는 오류
Msg 164, Level 15, State 1, Server a70f428a7f8a, Line 2
Each GROUP BY expression must contain at least one column that is not an outer reference.
== [Q4] UNION ALL 대체
dname|job|Total Empl|Total Sal
-----|---|----------|---------
NULL|ANALYST|2|6000.00
NULL|CLERK|4|4150.00
NULL|MANAGER|3|8275.00
NULL|PRESIDENT|1|5000.00
NULL|SALESMAN|4|5600.00
ACCOUNTING|NULL|3|8750.00
RESEARCH|NULL|5|10875.00
SALES|NULL|6|9400.00

(8 rows affected)
== [Q5] ROLLUP·CUBE 와 GROUPING SETS 동치
rollup_rows|gs_rollup_rows|cube_rows|gs_cube_rows
-----------|--------------|---------|------------
13|13|18|18

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 8행(부서 소계 3 + 직무 소계 5), 총계 없음. PDF와 일치한다.
* Q2 `()`로 9행. Q3 Oracle은 `NULL`로도 9행, SQL Server는 Msg 164.
* Q4: UNION ALL 두 개로 같은 8행이 나온다. 두 번째 SELECT에서 `NULL AS DNAME`의 별칭은 의미가 없다(컬럼 이름은 첫 SELECT가 정한다 — 09단원 ex02).
* Q5: ROLLUP 13 = GROUPING SETS((a,b),(a),()) 13, CUBE 18 = GROUPING SETS 4개 18.

## F. 변형 문제
1. GROUPING SETS((dname, job), dname)과 ROLLUP(dname, job)의 차이는?
2. 부서별·입사연도별 인원 소계와 총계를 GROUPING SETS 하나로 구하라.

G: [../exercises/ex04_grouping_sets.md](../exercises/ex04_grouping_sets.md)
