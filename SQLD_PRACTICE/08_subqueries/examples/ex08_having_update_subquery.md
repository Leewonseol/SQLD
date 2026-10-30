# ex08 HAVING 절 서브쿼리와 UPDATE SET 절 서브쿼리

> 근거: PDF추출본 E-24(HAVING 서브쿼리), E-25("서브쿼리 결과가 NULL을 반환하면 해당 컬럼 결과가 NULL이 될 수 있기 때문에 주의") · 데이터: EMP, BONUS(학습용 가상 데이터: 7369→100, 7499→200) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* HAVING 서브쿼리: 그룹 집계를 다른 집계값(전체 평균 등)과 비교한다.
* UPDATE SET 서브쿼리: `SET col = (SELECT …)`. **WHERE가 없으면 모든 행**이 갱신된다. 서브쿼리 짝이 없는 행은 NULL로 덮인다(PDF E-25).
  * 해결 ① `WHERE EXISTS (같은 연관 조건)` ② `NVL((서브쿼리), 원래값)` ③ SQL Server `UPDATE … FROM … JOIN`, Oracle `MERGE`(13단원)
* 실험은 복사본(EMP_U)에서 하고 ROLLBACK 한다. 원본 EMP는 바꾸지 않는다.

## B. 입력 데이터
EMP, BONUS(학습용 가상 데이터: 7369→100, 7499→200) (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex08_having_update_subquery_oracle.sql) · [SQL Server](ex08_having_update_subquery_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 결과 부서는?
2. Q3 뒤 30번 부서 6명 중 comm이 NULL이 되는 사람은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex08_having_update_subquery_oracle.sql -->
```text
== [Q1] HAVING 서브쿼리: 평균 급여가 전체 평균보다 높은 부서

DEPTNO|AVG_SAL
20|2175
10|2916.67

2 rows selected.

== [Q1b] (검증 환경 주의) 21c XE 21.3 에서는 위 Q1 결과가 ORDER BY deptno 와 다른 순서로 나왔다.
실행 계획에 집계 서브쿼리 제거 변환(VW_WIF_1)이 보인다. 이 변환을 끄면 정렬이 맞다. 23ai 계열에서는 정상(ex08_..._oracle23ai.sql).

DEPTNO|AVG_SAL
10|2916.67
20|2175

2 rows selected.

Explained.

PLAN_TABLE_OUTPUT
Plan hash value: 3994140971

------------------------------------------
| Id  | Operation             | Name     |
------------------------------------------
|   0 | SELECT STATEMENT      |          |
|   1 |  SORT ORDER BY        |          |
|   2 |   VIEW                | VW_WIF_1 |
|   3 |    WINDOW BUFFER      |          |
|   4 |     HASH GROUP BY     |          |
|   5 |      TABLE ACCESS FULL| EMP      |
------------------------------------------

12 rows selected.

== [Q2] UPDATE SET 서브쿼리 실험용 복사본 (emp 의 원본은 건드리지 않는다)

PL/SQL procedure successfully completed.

Table created.

== [Q3] PDF 의 주의: WHERE 없이 SET comm = (서브쿼리) -> 짝이 없는 행의 comm 이 NULL 로 덮인다

6 rows updated.

EMPNO|ENAME|COMM
7499|ALLEN|200
7521|WARD|(null)
7654|MARTIN|(null)
7698|BLAKE|(null)
7844|TURNER|(null)
7900|JAMES|(null)

6 rows selected.

Rollback complete.

== [Q4] 해결: 짝이 있는 행만 갱신 (WHERE EXISTS)

1 row updated.

EMPNO|ENAME|COMM
7499|ALLEN|200
7521|WARD|500
7654|MARTIN|1400
7698|BLAKE|(null)
7844|TURNER|0
7900|JAMES|(null)

6 rows selected.

Rollback complete.

== [Q5] 다른 해결: NVL 로 원래 값 유지

6 rows updated.

EMPNO|ENAME|COMM
7499|ALLEN|200
7521|WARD|500
7654|MARTIN|1400
7698|BLAKE|(null)
7844|TURNER|0
7900|JAMES|(null)

6 rows selected.

Rollback complete.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex08_having_update_subquery_sqlserver.sql -->
```text
== [Q1] HAVING 서브쿼리
deptno|avg_sal
------|-------
10|2916.670000
20|2175.000000

(2 rows affected)
== [Q2] 실험용 복사본

(6 rows affected)
== [Q3] WHERE 없는 SET 서브쿼리 -> 짝 없는 행이 NULL

(6 rows affected)
empno|ename|comm
-----|-----|----
7499|ALLEN|200.00
7521|WARD|NULL
7654|MARTIN|NULL
7698|BLAKE|NULL
7844|TURNER|NULL
7900|JAMES|NULL

(6 rows affected)
== [Q4] WHERE EXISTS

(1 rows affected)
empno|ename|comm
-----|-----|----
7499|ALLEN|200.00
7521|WARD|500.00
7654|MARTIN|1400.00
7698|BLAKE|NULL
7844|TURNER|.00
7900|JAMES|NULL

(6 rows affected)
== [Q5] SQL Server 식 UPDATE ... FROM JOIN (짝 있는 행만 갱신)

(1 rows affected)
empno|ename|comm
-----|-----|----
7499|ALLEN|200.00
7521|WARD|500.00
7654|MARTIN|1400.00
7698|BLAKE|NULL
7844|TURNER|.00
7900|JAMES|NULL

(6 rows affected)
```
<!-- /RESULT -->

23ai 계열 (Q1 재실행)
<!-- RESULT: ex08_having_update_subquery_oracle23ai.sql -->
```text
== [Q1] HAVING 서브쿼리 + ORDER BY deptno (21c XE 21.3 에서 정렬이 어긋났던 쿼리)
DEPTNO|AVG_SAL
10|2916.67
20|2175

2 rows selected.

BANNER_FULL
Oracle AI Database 26ai Free Release 23.26.3.0.0 - Develop, Learn, and Run for Free
Version 23.26.3.0.0

1 row selected.
```
<!-- /RESULT -->

**이유**
* Q1: 전체 평균(2073.21)보다 평균이 높은 10·20번 부서. **Oracle 21c XE 21.3에서는 ORDER BY deptno인데도 20, 10 순으로 나왔다**(단원 안내의 '검증 환경 주의' 참고. Q1b·23ai에서는 10, 20). SQL Server는 10, 20이다.
* Q3: BONUS에 있는 사람은 30번 부서의 ALLEN(7499)뿐이다. 나머지 5명(WARD·MARTIN·BLAKE·TURNER·JAMES)의 comm이 NULL로 덮인다. WARD 500, MARTIN 1400, TURNER 0이 사라졌다.
* Q4·Q5: ALLEN만 200으로 바뀌고 나머지는 그대로다.

## F. 변형 문제
1. 30번 부서의 comm을 BONUS 값으로 바꾸되, BONUS에 없는 사람은 0으로 바꿔라.
2. Q3의 실수를 커밋 전에 발견하는 확인 쿼리를 작성하라(갱신 전후 NULL 개수 비교).

G: [../exercises/ex08_having_update_subquery.md](../exercises/ex08_having_update_subquery.md)
