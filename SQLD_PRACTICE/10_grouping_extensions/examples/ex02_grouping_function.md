# ex02 GROUPING 함수

> 근거: PDF추출본 E-29("DECODE(GROUPING(DNAME), 1, 'All Departments', DNAME)") · 데이터: SCOTT / AH_NULL(학습용 가상 데이터: A 종에 breed NULL 행 포함) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `GROUPING(col)`: 그 행에서 col이 소계·총계로 집계되어 사라졌으면 1, 실제 그룹 값이면 0이다(값이 NULL이어도 0).
* 소계 이름 붙이기: Oracle `DECODE(GROUPING(c), 1, '소계', c)`, 공통 `CASE WHEN GROUPING(c) = 1 THEN …`.
* `GROUPING_ID(a, b)` = GROUPING(a)×2 + GROUPING(b). 그룹 수준을 숫자 하나로 표시한다.

## B. 입력 데이터
SCOTT / AH_NULL(학습용 가상 데이터: A 종에 breed NULL 행 포함)

## C. 실행 SQL
[Oracle](ex02_grouping_function_oracle.sql) · [SQL Server](ex02_grouping_function_sqlserver.sql)

## D. 결과 예측 문제
1. AH_NULL에서 ROLLUP(species, breed)를 NVL(breed, '소계')로 보이면 A 종의 '소계'는 몇 행인가?
2. Q4에서 gid = 2인 행은 어떤 수준의 집계인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_grouping_function_oracle.sql -->
```text
== [Q1] PDF 쿼리: GROUPING(col) = 1 이면 그 컬럼이 집계되어(소계·총계로) 사라진 행

DNAME|JOB|Total Empl|Total Sal
ACCOUNTING|CLERK|1|1300
ACCOUNTING|MANAGER|1|2450
ACCOUNTING|PRESIDENT|1|5000
ACCOUNTING|All Jobs|3|8750
RESEARCH|ANALYST|2|6000
RESEARCH|CLERK|2|1900
RESEARCH|MANAGER|1|2975
RESEARCH|All Jobs|5|10875
SALES|CLERK|1|950
SALES|MANAGER|1|2850
SALES|SALESMAN|4|5600
SALES|All Jobs|6|9400
All Departments|All Jobs|14|29025

13 rows selected.

== [Q2] NVL 로 이름을 붙이면 '진짜 NULL 값 그룹'과 '소계'를 구별하지 못한다 (AH_NULL: A 에 breed NULL 행 있음)

SPECIES|BREED_NVL|S
A|x|1
A|소계|3
A|소계|4
B|y|5
B|소계|5
(null)|소계|9

6 rows selected.

== [Q3] GROUPING 으로 구별: 실제 NULL 은 GROUPING = 0, 소계는 1

SPECIES|BREED|G_SP|G_BR|LABEL|S
A|x|0|0|x|1
A|(null)|0|0|(NULL값)|3
A|(null)|0|1|소계|4
B|y|0|0|y|5
B|(null)|0|1|소계|5
(null)|(null)|1|1|총계|9

6 rows selected.

== [Q4] GROUPING_ID(a, b) = GROUPING(a)*2 + GROUPING(b) (비트 벡터)

SPECIES|BREED|GID|S
A|x|0|1
A|(null)|0|3
B|y|0|5
A|(null)|1|4
B|(null)|1|5
(null)|x|2|1
(null)|y|2|5
(null)|(null)|2|3
(null)|(null)|3|9

9 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_grouping_function_sqlserver.sql -->
```text
== [Q1] CASE GROUPING(...)
dname|job|Total Empl|Total Sal
-----|---|----------|---------
ACCOUNTING|CLERK|1|1300.00
ACCOUNTING|MANAGER|1|2450.00
ACCOUNTING|PRESIDENT|1|5000.00
ACCOUNTING|All Jobs|3|8750.00
RESEARCH|ANALYST|2|6000.00
RESEARCH|CLERK|2|1900.00
RESEARCH|MANAGER|1|2975.00
RESEARCH|All Jobs|5|10875.00
SALES|CLERK|1|950.00
SALES|MANAGER|1|2850.00
SALES|SALESMAN|4|5600.00
SALES|All Jobs|6|9400.00
All Departments|All Jobs|14|29025.00

(13 rows affected)
== [Q2] ISNULL 로 이름 붙이기의 함정
species|breed_isnull|s
-------|------------|-
NULL|??|9
A|??|3
A|??|4
A|x|1
B|??|5
B|y|5

(6 rows affected)
== [Q3] GROUPING 으로 구별
species|breed|g_sp|g_br|label|s
-------|-----|----|----|-----|-
A|NULL|0|0|(NULL|3
A|x|0|0|x|1
A|NULL|0|1|소계|4
B|y|0|0|y|5
B|NULL|0|1|소계|5
NULL|NULL|1|1|총계|9

(6 rows affected)
== [Q4] GROUPING_ID
species|breed|gid|s
-------|-----|---|-
A|NULL|0|3
A|x|0|1
B|y|0|5
A|NULL|1|4
B|NULL|1|5
NULL|NULL|2|3
NULL|x|2|1
NULL|y|2|5
NULL|NULL|3|9

(9 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: PDF E-29 쿼리. 소계에 'All Jobs', 총계에 'All Departments'가 붙는다.
* Q2: A 종에 '소계'가 두 번 나온다. 하나는 breed가 실제 NULL인 그룹(3), 하나는 진짜 소계(4)다. **구별할 수 없다.**
* Q3: GROUPING(breed)가 실제 NULL에서는 0, 소계에서는 1이라 구별된다.
* Q4: gid 0 = (종, 품종), 1 = 종 소계, 2 = 품종 소계(종이 집계됨), 3 = 총계.
* SQL Server Q2: breed가 VARCHAR(5)라 `ISNULL(breed, N'소계')`의 결과도 VARCHAR(5)다. 한글이 '??'로 깨졌다. Q3의 `ISNULL(breed, N'(NULL값)')`도 5자로 잘려 '(NULL'이 되었다(07단원 ex05 Q7과 같은 원인). Oracle NVL은 첫 인수 형을 따르지만 VARCHAR2가 AL32UTF8이라 깨지지 않았다.

## F. 변형 문제
1. GROUPING을 써서 ROLLUP 결과에서 소계 행만 남겨라(HAVING GROUPING(job) = 1).
2. SQL Server Q2를 '??' 없이 고쳐라(CAST(breed AS NVARCHAR(10)) 또는 CASE).

G: [../exercises/ex02_grouping_function.md](../exercises/ex02_grouping_function.md)
