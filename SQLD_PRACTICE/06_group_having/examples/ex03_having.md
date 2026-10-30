# ex03 HAVING

> 근거: PDF추출본 E-06("GROUP BY를 통해 그룹화된 결과에 대한 조건 […] HAVING 절"), E-24("그룹핑된 결과에 대해 부가 조건") · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **HAVING**: GROUP BY가 만든 그룹을 거른다. 집계함수를 쓸 수 있고, SELECT에 없는 집계로도 거를 수 있다.
* **WHERE와 차이**: WHERE는 그룹을 만들기 **전에** 행을 거른다. HAVING은 **후에** 그룹을 거른다.
  * 그룹 컬럼에 대한 조건(`deptno <> 30`)은 어느 쪽에 두어도 결과가 같다. WHERE에 두면 그룹을 만들 행이 줄어 보통 더 효율적이다.
  * 개별 행 값 조건(`sal > 1500`)을 WHERE에 두는 것과, 그룹 집계 조건(`MIN(sal) > 1500`)을 HAVING에 두는 것은 의미가 다르다.
* GROUP BY 없이 HAVING만 쓰면 테이블 전체가 한 그룹이다.

## B. 입력 데이터
EMP. 부서별 최저 급여: 10번 1300, 20번 800, 30번 950.

## C. 실행 SQL
[Oracle](ex03_having_oracle.sql) · [SQL Server](ex03_having_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 `HAVING MAX(sal) >= 3000`인 부서는?
2. Q3 두 쿼리(WHERE sal > 1500 / HAVING MIN(sal) > 1500)의 결과는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_having_oracle.sql -->
```text
== [Q1] HAVING: 그룹 조건. SELECT 에 없는 집계로도 거를 수 있다

DEPTNO|CNT
10|3
20|5

2 rows selected.

== [Q2] 그룹 컬럼 조건은 WHERE 와 HAVING 어느 쪽이든 결과가 같다 (WHERE 가 먼저 줄여서 보통 더 효율적)

DEPTNO|CNT
10|3
20|5

2 rows selected.

DEPTNO|CNT
10|3
20|5

2 rows selected.

== [Q3] WHERE 와 HAVING 의 결과가 다른 경우: 급여 조건을 어디에 두는가

DEPTNO|CNT
10|2
20|3
30|2

3 rows selected.

no rows selected

== [Q4] GROUP BY 없는 HAVING: 테이블 전체가 한 그룹. 조건이 거짓이면 0행

no rows selected

CNT
14

1 row selected.

== [Q5] HAVING 에 그룹 컬럼도 집계도 아닌 컬럼 -> 오류
SELECT deptno, COUNT(*) FROM emp GROUP BY deptno HAVING sal > 1000
                                                        *
ERROR at line 1:
ORA-00979: not a GROUP BY expression
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_having_sqlserver.sql -->
```text
== [Q1] SELECT 에 없는 집계로 HAVING
deptno|cnt
------|---
10|3
20|5

(2 rows affected)
== [Q2] 그룹 컬럼 조건 WHERE vs HAVING
deptno|cnt
------|---
10|3
20|5

(2 rows affected)
deptno|cnt
------|---
10|3
20|5

(2 rows affected)
== [Q3] 급여 조건 WHERE vs HAVING
deptno|cnt
------|---
10|2
20|3
30|2

(3 rows affected)
deptno|cnt
------|---

(0 rows affected)
== [Q4] GROUP BY 없는 HAVING
cnt
---

(0 rows affected)
cnt
---
14

(1 rows affected)
== [Q5] HAVING 에 비그룹 컬럼 -> 오류
Msg 8121, Level 16, State 1, Server a70f428a7f8a, Line 2
Column 'emp.sal' is invalid in the HAVING clause because it is not contained in either an aggregate function or the GROUP BY clause.
```
<!-- /RESULT -->

**이유**
* Q1: 10번(KING 5000), 20번(SCOTT·FORD 3000). 30번은 최고 2850이라 빠진다.
* Q3: WHERE 쪽은 "1500 초과 사원만 세기" → 10번 2, 20번 3, 30번 2. HAVING 쪽은 "모든 사원이 1500 초과인 부서" → 없음(0행).
* Q4: 전체 14행 한 그룹이다. `> 100`이면 0행, `> 10`이면 1행.
* Q5: HAVING에 비그룹 컬럼 → ORA-00979 / Msg 8121.

## F. 변형 문제
1. "평균 급여가 2000 이상이고 인원이 4명 이상인 부서"를 구하라.
2. Q3의 WHERE 쪽 쿼리에 `HAVING COUNT(*) >= 3`을 붙이면?
3. HAVING을 GROUP BY 앞에 쓰면? (04단원 ex02: Oracle 허용, SQL Server 오류)

G: [../exercises/ex03_having.md](../exercises/ex03_having.md)
