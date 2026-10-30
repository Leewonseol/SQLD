# ex05 NTILE · PERCENT_RANK · CUME_DIST · RATIO_TO_REPORT

> 근거: PDF추출본 E-35("NTILE(N) (SQL Server는 지원X)", "ORDER BY 필수", "14명을 3 그룹으로 분리 그룹별로 5, 5, 4"). PERCENT_RANK 등은 추출본 미확인 · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `NTILE(n)`: 정렬 순서대로 n개 그룹으로 나눈다. 나누어떨어지지 않으면 **앞 그룹부터 1명씩 더** 배정한다(14/3 → 5, 5, 4).
* `PERCENT_RANK()` = (RANK − 1)/(행 수 − 1). `CUME_DIST()` = (현재 값 이하인 행 수)/(행 수).
* `RATIO_TO_REPORT(x) OVER ()`(Oracle 전용) = x / SUM(x) OVER ().

## B. 입력 데이터
EMP

## C. 실행 SQL
[Oracle](ex05_ntile_ratio_oracle.sql) · [SQL Server](ex05_ntile_ratio_sqlserver.sql)

## D. 결과 예측 문제
1. NTILE(3)의 그룹별 인원은? NTILE(2)는?
2. 30번 부서 WARD(1250)의 PERCENT_RANK와 CUME_DIST는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_ntile_ratio_oracle.sql -->
```text
== [Q1] PDF: 14명을 3그룹 -> 5, 5, 4 (나누어떨어지지 않으면 앞 그룹이 1명씩 더 많다)

GRP|CNT
1|5
2|5
3|4

3 rows selected.

== [Q2] PDF: NTILE(2) OVER (ORDER BY SAL)

ENAME|SAL|DEPTNO|GROUP_NO
SMITH|800|20|1
JAMES|950|30|1
ADAMS|1100|20|1
WARD|1250|30|1
MARTIN|1250|30|1
MILLER|1300|10|1
TURNER|1500|30|1
ALLEN|1600|30|2
CLARK|2450|10|2
BLAKE|2850|30|2
JONES|2975|20|2
SCOTT|3000|20|2
FORD|3000|20|2
KING|5000|10|2

14 rows selected.

== [Q3] PERCENT_RANK = (RANK-1)/(행수-1), CUME_DIST = (현재 값 이하 행 수)/행수

ENAME|SAL|RNK|PCT_RANK|CUME
JAMES|950|1|0|.167
MARTIN|1250|2|.2|.5
WARD|1250|2|.2|.5
TURNER|1500|4|.6|.667
ALLEN|1600|5|.8|.833
BLAKE|2850|6|1|1

6 rows selected.

== [Q4] RATIO_TO_REPORT(Oracle 전용): 합계 대비 비율

ENAME|SAL|RATIO|SAME_BY_SUM
KING|5000|.571|.571
CLARK|2450|.28|.28
MILLER|1300|.149|.149

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_ntile_ratio_sqlserver.sql -->
```text
== [Q1] NTILE(3) 그룹 크기
grp|cnt
---|---
1|5
2|5
3|4

(3 rows affected)
== [Q2] NTILE(2)
ename|sal|deptno|group_no
-----|---|------|--------
SMITH|800.00|20|1
JAMES|950.00|30|1
ADAMS|1100.00|20|1
WARD|1250.00|30|1
MARTIN|1250.00|30|1
MILLER|1300.00|10|1
TURNER|1500.00|30|1
ALLEN|1600.00|30|2
CLARK|2450.00|10|2
BLAKE|2850.00|30|2
JONES|2975.00|20|2
SCOTT|3000.00|20|2
FORD|3000.00|20|2
KING|5000.00|10|2

(14 rows affected)
== [Q3] PERCENT_RANK / CUME_DIST (FLOAT 결과)
ename|sal|rnk|pct_rank|cume
-----|---|---|--------|----
JAMES|950.00|1|0.0|0.16700000000000001
MARTIN|1250.00|2|0.20000000000000001|0.5
WARD|1250.00|2|0.20000000000000001|0.5
TURNER|1500.00|4|0.59999999999999998|0.66700000000000004
ALLEN|1600.00|5|0.80000000000000004|0.83299999999999996
BLAKE|2850.00|6|1.0|1.0

(6 rows affected)
== [Q4] RATIO_TO_REPORT 없음 -> sal / SUM(sal) OVER ()
ename|sal|same_by_sum
-----|---|-----------
KING|5000.00|.5710000000000000000000000000000
CLARK|2450.00|.2800000000000000000000000000000
MILLER|1300.00|.1490000000000000000000000000000

(3 rows affected)
== [Q5] RATIO_TO_REPORT -> 오류
Msg 195, Level 15, State 10, Server a70f428a7f8a, Line 2
'RATIO_TO_REPORT' is not a recognized built-in function name.
```
<!-- /RESULT -->

**이유**
* Q1 5·5·4. PDF와 일치한다. **SQL Server 2022에서도 실행된다.** PDF의 "SQL Server는 지원X"는 맞지 않는다(SQL Server 2005부터 지원 — 공식 문서 기준).
* Q2 NTILE(2) → 7명·7명.
* Q3: 6명 중 RANK 2 → (2−1)/5 = 0.2, 1250 이하 3명 → 3/6 = 0.5. 동점 MARTIN도 같다.
* Q4: KING 5000/8750 = 0.571.

## F. 변형 문제
1. 급여를 4분위로 나눠 각 분위의 최저·최고 급여를 구하라.
2. 부서 안에서 급여 상위 50%인 사원을 NTILE로 구하라.

G: [../exercises/ex05_ntile_ratio.md](../exercises/ex05_ntile_ratio.md)
