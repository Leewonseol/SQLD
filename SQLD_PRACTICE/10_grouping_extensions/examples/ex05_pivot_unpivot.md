# ex05 PIVOT · UNPIVOT

> 근거: 요구목록 §7(PIVOT·UNPIVOT). **추출본에서 확인되지 않은 항목** · 데이터: SCOTT EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **PIVOT**: 행 값(deptno 10·20·30)을 열로 돌리며 집계한다. FOR 뒤 컬럼과 집계 대상 외의 **나머지 컬럼이 모두 그룹 기준**이 된다. 그래서 필요한 컬럼만 담은 인라인 뷰를 먼저 만든다(Q3 함정).
* **UNPIVOT**: 열을 행으로 바꾼다. NULL 칸은 기본적으로 제외한다(Oracle은 `INCLUDE NULLS`로 포함할 수 있다. SQL Server는 항상 제외한다).
* 같은 일을 `SUM(CASE WHEN … THEN … END)`로도 할 수 있다(이식성이 가장 좋다).
* 문법 차이: Oracle `IN (10 AS d10, …)`, SQL Server `IN ([10], [20], [30])` + 파생 테이블 별칭 필수.

## B. 입력 데이터
SCOTT EMP

## C. 실행 SQL
[Oracle](ex05_pivot_unpivot_oracle.sql) · [SQL Server](ex05_pivot_unpivot_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 결과는 몇 행 몇 열인가? CLERK의 30번 칸은?
2. Q3(인라인 뷰 없이 EMP 전체로 PIVOT)의 행 수는?
3. Q4 UNPIVOT은 몇 행인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_pivot_unpivot_oracle.sql -->
```text
== [Q1] PIVOT: 직무별 행, 부서별 열 (급여 합계). 원본에서 쓰지 않은 컬럼은 인라인 뷰로 미리 제거

JOB|D10|D20|D30
ANALYST|(null)|6000|(null)
CLERK|1300|1900|950
MANAGER|2450|2975|2850
PRESIDENT|5000|(null)|(null)
SALESMAN|(null)|(null)|5600

5 rows selected.

== [Q2] 같은 결과를 CASE + 집계로 (모든 DBMS 공통 방식)

JOB|D10|D20|D30
ANALYST|(null)|6000|(null)
CLERK|1300|1900|950
MANAGER|2450|2975|2850
PRESIDENT|5000|(null)|(null)
SALESMAN|(null)|(null)|5600

5 rows selected.

== [Q3] 함정: 인라인 뷰 없이 테이블 전체로 PIVOT 하면 남은 모든 컬럼(empno, ename …)이 그룹 기준이 된다

ROWS_WITHOUT_INLINE_VIEW
14

1 row selected.

== [Q4] UNPIVOT: 열을 행으로. NULL 값 칸은 기본적으로 빠진다 (INCLUDE NULLS 로 포함)

JOB|DEPT|TOTAL
ANALYST|20|6000
CLERK|10|1300
CLERK|20|1900
CLERK|30|950
MANAGER|10|2450
MANAGER|20|2975
MANAGER|30|2850
PRESIDENT|10|5000
SALESMAN|30|5600

9 rows selected.

INCLUDE_NULLS_ROWS
15

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_pivot_unpivot_sqlserver.sql -->
```text
== [Q1] PIVOT
job|d10|d20|d30
---|---|---|---
ANALYST|NULL|6000.00|NULL
CLERK|1300.00|1900.00|950.00
MANAGER|2450.00|2975.00|2850.00
PRESIDENT|5000.00|NULL|NULL
SALESMAN|NULL|NULL|5600.00

(5 rows affected)
== [Q2] CASE + 집계
job|d10|d20|d30
---|---|---|---
ANALYST|NULL|6000.00|NULL
CLERK|1300.00|1900.00|950.00
MANAGER|2450.00|2975.00|2850.00
PRESIDENT|5000.00|NULL|NULL
SALESMAN|NULL|NULL|5600.00

(5 rows affected)
== [Q3] 원본 테이블 전체로 PIVOT 하면 남은 컬럼이 모두 그룹 기준
rows_without_derived_table
--------------------------
14

(1 rows affected)
== [Q4] UNPIVOT (SQL Server 는 NULL 칸을 항상 제외, INCLUDE NULLS 없음)
job|dept|total
---|----|-----
ANALYST|d20|6000.00
CLERK|d10|1300.00
CLERK|d20|1900.00
CLERK|d30|950.00
MANAGER|d10|2450.00
MANAGER|d20|2975.00
MANAGER|d30|2850.00
PRESIDENT|d10|5000.00
SALESMAN|d30|5600.00

(9 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 = Q2: 직무 5행 × (job + 부서 3열). 해당 부서에 그 직무가 없으면 NULL이다.
* Q3: empno·ename 등 남은 컬럼이 그룹 기준이 되어 14행(사원마다 1행)이 나온다.
* Q4: 15칸 중 NULL이 아닌 9칸 → 9행. INCLUDE NULLS면 15행(Oracle).

## F. 변형 문제
1. 부서별 행, 직무별 열(인원 수)로 PIVOT 하라.
2. PIVOT 결과에 총합 열을 추가하라(CASE 방식이 더 쉽다).

G: [../exercises/ex05_pivot_unpivot.md](../exercises/ex05_pivot_unpivot.md)
