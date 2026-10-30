# ex01 ROLLUP

> 근거: PDF추출본 E-28(ROLLUP 인수 순서, ANIMAL_HOTEL 결과표), E-29(ROLLUP(DNAME, JOB) 결과표) · 데이터: SCOTT EMP·DEPT / ANIMAL_HOTEL 8행(학습용 가상 데이터: PDF 원본 행이 추출본에 없음) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `GROUP BY ROLLUP(A, B)` = `GROUPING SETS((A, B), (A), ())`. 오른쪽 인수부터 하나씩 빼면서 **계층적 소계**를 만든다. 인수 n개 → 그룹 기준 n+1개.
* 인수 **순서가 의미를 정한다**. ROLLUP(species, breed)는 종별 소계, ROLLUP(breed, species)는 품종별 소계다.
* 소계 행의 사라진 컬럼은 NULL이다. PDF처럼 NVL(…, '합계')로 이름을 붙이면 원래 NULL인 데이터와 섞일 수 있다(ex02).

## B. 입력 데이터
SCOTT EMP·DEPT / ANIMAL_HOTEL 8행(학습용 가상 데이터: PDF 원본 행이 추출본에 없음)

## C. 실행 SQL
[Oracle](ex01_rollup_oracle.sql) · [SQL Server](ex01_rollup_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 행 수는? 각 부서 소계 행의 job 값은?
2. Q2와 Q3의 행 수는? 총계 평균은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_rollup_oracle.sql -->
```text
== [Q1] PDF E-29 데이터 재현: ROLLUP(DNAME, JOB) = (DNAME,JOB) 9 + DNAME 소계 3 + 총계 1 = 13행

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
(null)|(null)|14|29025

13 rows selected.

== [Q2] PDF E-28 구조(학습용 가상 데이터): ROLLUP(species, breed) -> 소계 기준 = species

SPECIES_L|BREED_L|AVG_AGE|CNT
강아지|말티즈|6|2
강아지|푸들|6.5|2
강아지|합계|6.25|4
고양이|샴|3.5|2
고양이|페르시안|5|1
고양이|합계|4|3
토끼|미니렉스|2|1
토끼|합계|2|1
합계|합계|4.88|8

9 rows selected.

== [Q3] 인수 순서를 바꾸면 ROLLUP(breed, species) -> 소계 기준 = breed. 행 집합 자체가 달라진다

SPECIES_L|BREED_L|AVG_AGE|CNT
강아지|말티즈|6|2
합계|말티즈|6|2
토끼|미니렉스|2|1
합계|미니렉스|2|1
고양이|샴|3.5|2
합계|샴|3.5|2
고양이|페르시안|5|1
합계|페르시안|5|1
강아지|푸들|6.5|2
합계|푸들|6.5|2
합계|합계|4.88|8

11 rows selected.

== [Q4] ROLLUP(A, B) = (A,B) 그룹 UNION ALL (A) 그룹 UNION ALL 전체 — 집합 차이 0행이면 같다

DIFF_ROWS
0

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_rollup_sqlserver.sql -->
```text
== [Q1] ROLLUP(DNAME, JOB) 13행
dname|job|Total Empl|Total Sal
-----|---|----------|---------
NULL|NULL|14|29025.00
ACCOUNTING|NULL|3|8750.00
ACCOUNTING|CLERK|1|1300.00
ACCOUNTING|MANAGER|1|2450.00
ACCOUNTING|PRESIDENT|1|5000.00
RESEARCH|NULL|5|10875.00
RESEARCH|ANALYST|2|6000.00
RESEARCH|CLERK|2|1900.00
RESEARCH|MANAGER|1|2975.00
SALES|NULL|6|9400.00
SALES|CLERK|1|950.00
SALES|MANAGER|1|2850.00
SALES|SALESMAN|4|5600.00

(13 rows affected)
== [Q2] ROLLUP(species, breed) (ISNULL 로 합계 표시)
species_l|breed_l|avg_age|cnt
---------|-------|-------|---
강아지|말티즈|6.000000|2
강아지|푸들|6.500000|2
강아지|합계|6.250000|4
고양이|샴|3.500000|2
고양이|페르시안|5.000000|1
고양이|합계|4.000000|3
토끼|미니렉스|2.000000|1
토끼|합계|2.000000|1
합계|합계|4.880000|8

(9 rows affected)
== [Q3] ROLLUP(breed, species)
species_l|breed_l|avg_age|cnt
---------|-------|-------|---
강아지|말티즈|6.000000|2
합계|말티즈|6.000000|2
토끼|미니렉스|2.000000|1
합계|미니렉스|2.000000|1
고양이|샴|3.500000|2
합계|샴|3.500000|2
고양이|페르시안|5.000000|1
합계|페르시안|5.000000|1
강아지|푸들|6.500000|2
합계|푸들|6.500000|2
합계|합계|4.880000|8

(11 rows affected)
== [Q4] ROLLUP = UNION ALL 세 개 (집합 차이 0행)
diff_rows
---------
0

(1 rows affected)
== [Q5] SQL Server 옛 문법 WITH ROLLUP (같은 결과)
species|cnt
-------|---
강아지|4
고양이|3
토끼|1
NULL|8

(4 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 13행 = (부서, 직무) 9 + 부서 소계 3 + 총계 1. 소계 행의 job은 NULL이다. PDF E-29의 값과 일치한다. 소계 행의 위치가 다른 것은 NULL 정렬 차이(Oracle 마지막, SQL Server 처음)다.
* Q2 9행 = (종, 품종) 5 + 종 소계 3 + 총계 1. Q3 11행 = (품종, 종) 5 + 품종 소계 5 + 총계 1. 총계 평균 39/8 = 4.875 → 4.88.
* Q4: ROLLUP과 UNION ALL 세 개의 결과가 같다(차집합 0행). PDF E-30의 "UNION ALL을 통해서 표현할 수 있다"와 일치한다.
* SQL Server AVG(DECIMAL)은 소수 6자리로 표시한다.

## F. 변형 문제
1. ROLLUP(dname, job, mgr)은 그룹 기준이 몇 개인가?
2. `GROUP BY dname, ROLLUP(job)`(부분 ROLLUP)은 어떤 소계를 만드는가? 총계가 있는가?

G: [../exercises/ex01_rollup.md](../exercises/ex01_rollup.md)
