# ex03 순위 함수 RANK · DENSE_RANK · ROW_NUMBER

> 근거: 요구목록 §7(추출본에는 순위 함수 본문 없음) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 함수 | 동점 처리 | 예(5000, 3000, 3000, 2975) |
|---|---|---|
| RANK | 같은 순위, 다음 순위는 건너뜀 | 1, 2, 2, 4 |
| DENSE_RANK | 같은 순위, 건너뛰지 않음 | 1, 2, 2, 3 |
| ROW_NUMBER | 모두 다른 번호(동점 순서는 정렬 키에 따라) | 1, 2, 3, 4 |
* 순위 함수에는 OVER 안의 ORDER BY가 **필수**다.
* 윈도우 함수는 WHERE에서 쓸 수 없다(WHERE가 먼저 처리된다). 인라인 뷰 안에서 순위를 만들고 바깥 WHERE에서 거른다.

## B. 입력 데이터
EMP

## C. 실행 SQL
[Oracle](ex03_rank_functions_oracle.sql) · [SQL Server](ex03_rank_functions_sqlserver.sql)

## D. 결과 예측 문제
1. Q1에서 JONES(2975)의 RANK와 DENSE_RANK는?
2. Q4(RANK ≤ 2)와 Q5(ROW_NUMBER ≤ 2)에서 20번 부서는 각각 누가 남는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_rank_functions_oracle.sql -->
```text
== [Q1] 동점 처리 차이: 급여 내림차순 (SCOTT·FORD 3000 동점)

ENAME|SAL|RNK|DRNK|RN
KING|5000|1|1|1
FORD|3000|2|2|2
SCOTT|3000|2|2|3
JONES|2975|4|3|4
BLAKE|2850|5|4|5
CLARK|2450|6|5|6

6 rows selected.

== [Q2] PARTITION BY: 부서 안에서 순위

DEPTNO|ENAME|SAL|DEPT_RNK
10|KING|5000|1
10|CLARK|2450|2
10|MILLER|1300|3
20|FORD|3000|1
20|SCOTT|3000|1
20|JONES|2975|3
20|ADAMS|1100|4
20|SMITH|800|5
30|BLAKE|2850|1
30|ALLEN|1600|2
30|TURNER|1500|3
30|MARTIN|1250|4
30|WARD|1250|4
30|JAMES|950|6

14 rows selected.

== [Q3] 윈도우 함수는 WHERE 에서 쓸 수 없다 (WHERE 가 SELECT 보다 먼저) -> 오류
SELECT ename FROM emp WHERE RANK() OVER (ORDER BY sal DESC) <= 3
                            *
ERROR at line 1:
ORA-30483: window  functions are not allowed here

== [Q4] 부서별 TOP 2: 인라인 뷰에서 순위를 만든 뒤 바깥 WHERE 로 거른다 (RANK 는 동점 모두 포함)

DEPTNO|ENAME|SAL|RNK
10|KING|5000|1
10|CLARK|2450|2
20|FORD|3000|1
20|SCOTT|3000|1
30|BLAKE|2850|1
30|ALLEN|1600|2

6 rows selected.

== [Q5] ROW_NUMBER 로 부서별 정확히 2명: 동점 중 누가 남는지는 2차 정렬 키가 정한다

DEPTNO|ENAME|SAL|RN
10|KING|5000|1
10|CLARK|2450|2
20|SCOTT|3000|1
20|FORD|3000|2
30|BLAKE|2850|1
30|ALLEN|1600|2

6 rows selected.

== [Q6] 순위 함수에 ORDER BY 가 없으면 오류
SELECT ename, RANK() OVER (PARTITION BY deptno) FROM emp
              *
ERROR at line 1:
ORA-30485: missing ORDER BY expression in the window specification
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_rank_functions_sqlserver.sql -->
```text
== [Q1] 동점 처리 차이
ename|sal|rnk|drnk|rn
-----|---|---|----|--
KING|5000.00|1|1|1
FORD|3000.00|2|2|2
SCOTT|3000.00|2|2|3
JONES|2975.00|4|3|4
BLAKE|2850.00|5|4|5
CLARK|2450.00|6|5|6

(6 rows affected)
== [Q2] PARTITION BY
deptno|ename|sal|dept_rnk
------|-----|---|--------
10|KING|5000.00|1
10|CLARK|2450.00|2
10|MILLER|1300.00|3
20|FORD|3000.00|1
20|SCOTT|3000.00|1
20|JONES|2975.00|3
20|ADAMS|1100.00|4
20|SMITH|800.00|5
30|BLAKE|2850.00|1
30|ALLEN|1600.00|2
30|TURNER|1500.00|3
30|MARTIN|1250.00|4
30|WARD|1250.00|4
30|JAMES|950.00|6

(14 rows affected)
== [Q3] WHERE 에 윈도우 함수 -> 오류
Msg 4108, Level 15, State 1, Server a70f428a7f8a, Line 2
Windowed functions can only appear in the SELECT or ORDER BY clauses.
== [Q4] 부서별 TOP 2 (RANK)
deptno|ename|sal|rnk
------|-----|---|---
10|KING|5000.00|1
10|CLARK|2450.00|2
20|FORD|3000.00|1
20|SCOTT|3000.00|1
30|BLAKE|2850.00|1
30|ALLEN|1600.00|2

(6 rows affected)
== [Q5] ROW_NUMBER 정확히 2명
deptno|ename|sal|rn
------|-----|---|--
10|KING|5000.00|1
10|CLARK|2450.00|2
20|SCOTT|3000.00|1
20|FORD|3000.00|2
30|BLAKE|2850.00|1
30|ALLEN|1600.00|2

(6 rows affected)
== [Q6] 순위 함수에 ORDER BY 없음 -> 오류
Msg 4112, Level 15, State 1, Server a70f428a7f8a, Line 2
The function 'RANK' must have an OVER clause with ORDER BY.
```
<!-- /RESULT -->

**이유**
* Q1: KING 1/1/1, FORD·SCOTT 2/2/(2,3), JONES 4/3/4, BLAKE 5/4/5, CLARK 6/5/6.
* Q3: WHERE에 윈도우 함수 → ORA-30483 / Msg 4108. Q6: 순위 함수에 ORDER BY 없음 → ORA-30485 / Msg 4112.
* Q4: RANK ≤ 2는 20번 부서에서 SCOTT·FORD(공동 1위) 둘이고, 2위가 없으니 JONES는 빠진다. 10번 KING·CLARK, 30번 BLAKE·ALLEN.
* Q5: ROW_NUMBER는 정확히 2명. 20번 동점은 2차 키 empno가 작은 SCOTT(7788)·FORD(7902) 순서다.

## F. 변형 문제
1. 부서별 급여 3위까지를 DENSE_RANK로 구하고, RANK로 구한 결과와 비교하라.
2. 전체 급여 순위가 4~6위인 사원을 ROW_NUMBER로 구하라(06단원 ex06 OFFSET과 비교).

G: [../exercises/ex03_rank_functions.md](../exercises/ex03_rank_functions.md)
