# ex04 연관(상관) 서브쿼리와 비연관 서브쿼리

> 근거: 요구목록 §7. 추출본에는 '연관' 용어가 E-20("단일행 연관 서브쿼리")에만 있다 · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **비연관**: 서브쿼리가 바깥 쿼리 컬럼을 참조하지 않는다. 한 번 계산한 결과를 모든 행이 함께 쓴다.
* **연관**: 서브쿼리 안에서 바깥 행의 값(e.deptno)을 참조한다. 바깥 **행마다** 다시 평가하는 것으로 해석한다. 실제로는 옵티마이저가 조인으로 바꾸기도 한다.
* **함정**: 연관 조건에서 바깥 별칭을 빠뜨리면(`x.deptno = deptno`), 이름이 가장 가까운 서브쿼리 자기 컬럼으로 해석된다. 항상 참이 되어 비연관과 같아진다. 오류는 나지 않는다.

## B. 입력 데이터
EMP (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex04_correlated_subquery_oracle.sql) · [SQL Server](ex04_correlated_subquery_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(전체 평균)과 Q2(자기 부서 평균)의 결과에서 다른 사원은?
2. Q4는 Q1과 Q2 중 어느 것과 같은가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_correlated_subquery_oracle.sql -->
```text
== [Q1] 비연관: 서브쿼리가 바깥 쿼리 컬럼을 참조하지 않는다 -> 한 번 계산해 모든 행에 같은 값

ENAME|DEPTNO|SAL
KING|10|5000
CLARK|10|2450
FORD|20|3000
SCOTT|20|3000
JONES|20|2975
BLAKE|30|2850

6 rows selected.

== [Q2] 연관: 서브쿼리가 바깥 행의 deptno 를 참조 -> 행마다 '자기 부서 평균'과 비교

ENAME|DEPTNO|SAL
KING|10|5000
FORD|20|3000
SCOTT|20|3000
JONES|20|2975
BLAKE|30|2850
ALLEN|30|1600

6 rows selected.

== [Q3] 같은 결과를 인라인 뷰 + 조인으로

ENAME|DEPTNO|SAL
KING|10|5000
SCOTT|20|3000
FORD|20|3000
JONES|20|2975
BLAKE|30|2850
ALLEN|30|1600

6 rows selected.

== [Q4] 연관 조건의 별칭을 빠뜨리면: x.deptno = deptno 는 서브쿼리 자기 컬럼끼리 비교(항상 참) -> 비연관과 같아짐

ENAME|DEPTNO|SAL
KING|10|5000
CLARK|10|2450
FORD|20|3000
SCOTT|20|3000
JONES|20|2975
BLAKE|30|2850

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_correlated_subquery_sqlserver.sql -->
```text
== [Q1] 비연관: 서브쿼리가 바깥 쿼리 컬럼을 참조하지 않는다 -> 한 번 계산해 모든 행에 같은 값
ename|deptno|sal
-----|------|---
KING|10|5000.00
CLARK|10|2450.00
SCOTT|20|3000.00
FORD|20|3000.00
JONES|20|2975.00
BLAKE|30|2850.00

(6 rows affected)
== [Q2] 연관: 서브쿼리가 바깥 행의 deptno 를 참조 -> 행마다 '자기 부서 평균'과 비교
ename|deptno|sal
-----|------|---
KING|10|5000.00
FORD|20|3000.00
SCOTT|20|3000.00
JONES|20|2975.00
BLAKE|30|2850.00
ALLEN|30|1600.00

(6 rows affected)
== [Q3] 같은 결과를 인라인 뷰 + 조인으로
ename|deptno|sal
-----|------|---
KING|10|5000.00
FORD|20|3000.00
SCOTT|20|3000.00
JONES|20|2975.00
BLAKE|30|2850.00
ALLEN|30|1600.00

(6 rows affected)
== [Q4] 연관 조건의 별칭을 빠뜨리면: x.deptno = deptno 는 서브쿼리 자기 컬럼끼리 비교(항상 참) -> 비연관과 같아짐
ename|deptno|sal
-----|------|---
KING|10|5000.00
CLARK|10|2450.00
SCOTT|20|3000.00
FORD|20|3000.00
JONES|20|2975.00
BLAKE|30|2850.00

(6 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 전체 평균 2073보다 많은 6명. CLARK(2450)이 포함된다.
* Q2: 부서 평균(10번 2916.67 / 20번 2175 / 30번 1566.67)보다 많은 6명. CLARK은 10번 평균보다 적어 빠지고, ALLEN(1600 > 1566.67)이 들어온다.
* Q3: 인라인 뷰 + 조인은 Q2와 같다(동점 SCOTT·FORD 순서만 다르다 — ORDER BY 키가 같으면 순서를 단정할 수 없다).
* Q4: Q1과 같다. 별칭 누락이 의미를 바꿨다.

## F. 변형 문제
1. 자기 직무의 평균 급여보다 적게 받는 사원을 연관 서브쿼리로 구하라.
2. 같은 부서에 자기보다 급여가 높은 사람이 2명 미만인 사원(부서별 상위 2명)을 연관 서브쿼리로 구하라.

G: [../exercises/ex04_correlated_subquery.md](../exercises/ex04_correlated_subquery.md)
