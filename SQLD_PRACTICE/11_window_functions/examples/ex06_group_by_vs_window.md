# ex06 GROUP BY 와 윈도우 함수의 차이

> 근거: 요구목록 §9(GROUP BY와 윈도우 함수의 차이) · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| | GROUP BY | 윈도우 함수 |
|---|---|---|
| 처리 단계 | GROUP BY(3) | SELECT(5) |
| 결과 행 수 | 그룹 수로 줄어든다 | 그대로 유지된다 |
| 개별 컬럼 함께 출력 | 불가(그룹 컬럼만) | 가능 |
| 결과로 거르기 | HAVING | 인라인 뷰 + 바깥 WHERE |
* 둘을 함께 쓸 수 있다. GROUP BY가 먼저 그룹을 만들고, 그 그룹 행 위에서 윈도우 함수가 계산된다(`SUM(SUM(sal)) OVER ()`).

## B. 입력 데이터
EMP

## C. 실행 SQL
[Oracle](ex06_group_by_vs_window_oracle.sql) · [SQL Server](ex06_group_by_vs_window_sqlserver.sql)

## D. 결과 예측 문제
1. Q1과 Q2의 행 수는?
2. Q3 `SUM(SUM(sal)) OVER ()`는 무엇을 계산하는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_group_by_vs_window_oracle.sql -->
```text
== [Q1] GROUP BY: 그룹마다 1행 -> 3행. 개별 사원 컬럼은 볼 수 없다

DEPTNO|DEPT_SUM
10|8750
20|10875
30|9400

3 rows selected.

== [Q2] 윈도우: 행 수 유지(14행) + 그룹 값을 각 행에 붙인다

DEPTNO|ENAME|SAL|DEPT_SUM|PCT
10|KING|5000|8750|57.1
10|CLARK|2450|8750|28
10|MILLER|1300|8750|14.9
20|FORD|3000|10875|27.6
20|SCOTT|3000|10875|27.6
20|JONES|2975|10875|27.4
20|ADAMS|1100|10875|10.1
20|SMITH|800|10875|7.4
30|BLAKE|2850|9400|30.3
30|ALLEN|1600|9400|17
30|TURNER|1500|9400|16
30|MARTIN|1250|9400|13.3
30|WARD|1250|9400|13.3
30|JAMES|950|9400|10.1

14 rows selected.

== [Q3] 윈도우 함수는 GROUP BY 결과 위에서도 동작한다 (처리 순서: GROUP BY -> SELECT 의 윈도우)

DEPTNO|DEPT_SUM|GRAND_TOTAL|RNK
10|8750|29025|3
20|10875|29025|1
30|9400|29025|2

3 rows selected.

== [Q4] 행 수 비교

GROUP_ROWS|WINDOW_ROWS|WINDOW_DISTINCT_ROWS
3|14|3

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_group_by_vs_window_sqlserver.sql -->
```text
== [Q1] GROUP BY: 그룹마다 1행 -> 3행. 개별 사원 컬럼은 볼 수 없다
deptno|dept_sum
------|--------
10|8750.00
20|10875.00
30|9400.00

(3 rows affected)
== [Q2] 윈도우: 행 수 유지(14행) + 그룹 값을 각 행에 붙인다
deptno|ename|sal|dept_sum|pct
------|-----|---|--------|---
10|KING|5000.00|8750.00|57.100000000000000000000000000
10|CLARK|2450.00|8750.00|28.000000000000000000000000000
10|MILLER|1300.00|8750.00|14.900000000000000000000000000
20|FORD|3000.00|10875.00|27.600000000000000000000000000
20|SCOTT|3000.00|10875.00|27.600000000000000000000000000
20|JONES|2975.00|10875.00|27.400000000000000000000000000
20|ADAMS|1100.00|10875.00|10.100000000000000000000000000
20|SMITH|800.00|10875.00|7.400000000000000000000000000
30|BLAKE|2850.00|9400.00|30.300000000000000000000000000
30|ALLEN|1600.00|9400.00|17.000000000000000000000000000
30|TURNER|1500.00|9400.00|16.000000000000000000000000000
30|MARTIN|1250.00|9400.00|13.300000000000000000000000000
30|WARD|1250.00|9400.00|13.300000000000000000000000000
30|JAMES|950.00|9400.00|10.100000000000000000000000000

(14 rows affected)
== [Q3] 윈도우 함수는 GROUP BY 결과 위에서도 동작한다 (처리 순서: GROUP BY -> SELECT 의 윈도우)
deptno|dept_sum|grand_total|rnk
------|--------|-----------|---
10|8750.00|29025.00|3
20|10875.00|29025.00|1
30|9400.00|29025.00|2

(3 rows affected)
== [Q4] 행 수 비교
group_rows|window_rows|window_distinct_rows
----------|-----------|--------------------
3|14|3

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 3행, Q2 14행. Q4: 윈도우 결과에 DISTINCT를 붙이면 3행으로 GROUP BY와 같아진다.
* Q2 pct: 부서 합계 대비 비율. SQL Server는 `sal * 100 / SUM(...)` 순서로 계산해 정수 나눗셈을 피했다(DECIMAL이라 문제는 없지만 순서를 바꾸면 자릿수가 달라진다).
* Q3: 안쪽 SUM(sal)은 GROUP BY 집계(부서 합계), 바깥 SUM() OVER ()는 그 3행의 합(29025). RANK는 부서 합계 순위다.

## F. 변형 문제
1. 부서 평균보다 급여가 높은 사원을 윈도우 함수로 구하라(08단원 ex04 연관 서브쿼리와 비교).
2. 15단원 Q7(GROUP BY와 윈도우 함수 선택지)을 풀어라.

G: [../exercises/ex06_group_by_vs_window.md](../exercises/ex06_group_by_vs_window.md)
