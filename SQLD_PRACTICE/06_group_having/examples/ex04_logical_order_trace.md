# ex04 논리적 처리 순서 단계별 추적

> 근거: PDF추출본 E-05((1) FROM → (2) WHERE → (3) GROUP BY → (4) HAVING → (5) SELECT → (6) ORDER BY), 요구목록 §3(학습 중심 순서), 학습 능력 7 · 데이터: EMP·DEPT · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
아래 쿼리 하나를 처리 단계마다 끊어서, 각 단계가 넘겨주는 중간 결과를 직접 조회한다.

```sql
SELECT d.dname, COUNT(*) AS cnt, SUM(e.sal) AS total   -- (5) SELECT
FROM emp e JOIN dept d ON e.deptno = d.deptno           -- (1) FROM·JOIN·ON
WHERE e.job <> 'PRESIDENT'                              -- (2) WHERE
GROUP BY d.dname                                        -- (3) GROUP BY
HAVING COUNT(*) >= 2                                    -- (4) HAVING
ORDER BY total DESC                                     -- (6) ORDER BY
FETCH FIRST 2 ROWS ONLY;                                -- (7) 행 제한 (SQL Server: OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY)
```

* DISTINCT는 SELECT 다음, ORDER BY 앞이다. 행 제한은 맨 마지막이다(T1·T2에서 확인).
* **세 가지 순서를 구분한다.** 이것은 논리적 처리 순서(결과의 의미)다. 작성 순서(SELECT부터 씀)와 다르다. 실제 실행 계획(물리적 순서)과도 다르다. 옵티마이저는 결과가 같다면 WHERE를 조인 전에 적용하거나 정렬을 생략할 수 있다.

## B. 입력 데이터
EMP 14행 + DEPT 4행(00_common).

## C. 실행 SQL
[Oracle](ex04_logical_order_trace_oracle.sql) · [SQL Server](ex04_logical_order_trace_sqlserver.sql)

## D. 결과 예측 문제 (각 단계의 행 수를 먼저 적어라)
| 단계 | 예측 행 수 | 남거나 빠지는 이유 |
|---|---|---|
| S1 FROM·JOIN | | |
| S2 WHERE | | |
| S3 GROUP BY | | |
| S4 HAVING | | |
| S6 ORDER BY 첫 행 | | |
| S7 최종 | | |

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex04_logical_order_trace_oracle.sql -->
```text
== [S1] FROM + JOIN ON : 조인 결과 행 (14행)

EMPNO|ENAME|JOB|SAL|DNAME
7369|SMITH|CLERK|800|RESEARCH
7499|ALLEN|SALESMAN|1600|SALES
7521|WARD|SALESMAN|1250|SALES
7566|JONES|MANAGER|2975|RESEARCH
7654|MARTIN|SALESMAN|1250|SALES
7698|BLAKE|MANAGER|2850|SALES
7782|CLARK|MANAGER|2450|ACCOUNTING
7788|SCOTT|ANALYST|3000|RESEARCH
7839|KING|PRESIDENT|5000|ACCOUNTING
7844|TURNER|SALESMAN|1500|SALES
7876|ADAMS|CLERK|1100|RESEARCH
7900|JAMES|CLERK|950|SALES
7902|FORD|ANALYST|3000|RESEARCH
7934|MILLER|CLERK|1300|ACCOUNTING

14 rows selected.

== [S2] WHERE job <> 'PRESIDENT' : KING 제외 (13행)

ROWS_AFTER_WHERE
13

1 row selected.

== [S3] GROUP BY dname : 그룹별 행 (그룹 3개)

DNAME|MEMBERS|CNT|TOTAL
ACCOUNTING|CLARK,MILLER|2|3750
RESEARCH|ADAMS,FORD,JONES,SCOTT,SMITH|5|10875
SALES|ALLEN,BLAKE,JAMES,MARTIN,TURNER,WARD|6|9400

3 rows selected.

== [S4] HAVING COUNT(*) >= 2 : 세 그룹 모두 통과  -> [S5] SELECT 로 열 계산 -> [S6] ORDER BY total DESC

DNAME|CNT|TOTAL
RESEARCH|5|10875
SALES|6|9400
ACCOUNTING|2|3750

3 rows selected.

== [S7] 행 제한 FETCH FIRST 2 ROWS ONLY : 최종 결과

DNAME|CNT|TOTAL
RESEARCH|5|10875
SALES|6|9400

2 rows selected.

== [T1] DISTINCT 는 ORDER BY·행 제한보다 먼저: 중복 제거 -> 정렬 -> 3개

JOB
ANALYST
CLERK
MANAGER

3 rows selected.

== [T2] (비교) 행 제한을 먼저 한 뒤 중복 제거하면 다른 결과: 이름순 3명(ADAMS, ALLEN, BLAKE)의 직무

JOB
CLERK
MANAGER
SALESMAN

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_logical_order_trace_sqlserver.sql -->
```text
== [S1] FROM + JOIN ON
empno|ename|job|sal|dname
-----|-----|---|---|-----
7369|SMITH|CLERK|800.00|RESEARCH
7499|ALLEN|SALESMAN|1600.00|SALES
7521|WARD|SALESMAN|1250.00|SALES
7566|JONES|MANAGER|2975.00|RESEARCH
7654|MARTIN|SALESMAN|1250.00|SALES
7698|BLAKE|MANAGER|2850.00|SALES
7782|CLARK|MANAGER|2450.00|ACCOUNTING
7788|SCOTT|ANALYST|3000.00|RESEARCH
7839|KING|PRESIDENT|5000.00|ACCOUNTING
7844|TURNER|SALESMAN|1500.00|SALES
7876|ADAMS|CLERK|1100.00|RESEARCH
7900|JAMES|CLERK|950.00|SALES
7902|FORD|ANALYST|3000.00|RESEARCH
7934|MILLER|CLERK|1300.00|ACCOUNTING

(14 rows affected)
== [S2] WHERE
rows_after_where
----------------
13

(1 rows affected)
== [S3] GROUP BY (STRING_AGG 로 그룹 구성원 표시)
dname|members|cnt|total
-----|-------|---|-----
ACCOUNTING|CLARK,MILLER|2|3750.00
RESEARCH|ADAMS,FORD,JONES,SCOTT,SMITH|5|10875.00
SALES|ALLEN,BLAKE,JAMES,MARTIN,TURNER,WARD|6|9400.00

(3 rows affected)
== [S4~S6] HAVING -> SELECT -> ORDER BY
dname|cnt|total
-----|---|-----
RESEARCH|5|10875.00
SALES|6|9400.00
ACCOUNTING|2|3750.00

(3 rows affected)
== [S7] 행 제한: 최종 결과
dname|cnt|total
-----|---|-----
RESEARCH|5|10875.00
SALES|6|9400.00

(2 rows affected)
== [T1] DISTINCT -> ORDER BY -> 행 제한
job
---
ANALYST
CLERK
MANAGER

(3 rows affected)
== [T2] (비교) 행 제한 먼저
job
---
CLERK
MANAGER
SALESMAN

(3 rows affected)
```
<!-- /RESULT -->

**단계별 해설**
| 단계 | 행 수 | 이유 |
|---|---|---|
| S1 | 14 | 모든 사원의 deptno가 DEPT에 있다. 40번 OPERATIONS는 사원이 없어 INNER JOIN에서 사라진다 |
| S2 | 13 | KING(PRESIDENT) 제외 |
| S3 | 3그룹 | ACCOUNTING(CLARK, MILLER) 2 / RESEARCH 5 / SALES 6 |
| S4 | 3그룹 | 모두 2명 이상 |
| S5 | 3행 | dname, cnt, total 계산. 별칭 total이 이때 생긴다 |
| S6 | 3행 | total DESC: RESEARCH 10875 → SALES 9400 → ACCOUNTING 3750. 별칭 total을 쓸 수 있다 |
| S7 | 2행 | 앞의 2행만 남는다 |

* T1: DISTINCT(5종) → ORDER BY → 3개 = ANALYST·CLERK·MANAGER.
* T2: 행 제한을 먼저(이름순 3명 ADAMS·ALLEN·BLAKE)하고 DISTINCT를 하면 CLERK·MANAGER·SALESMAN이 된다. 단계 순서가 바뀌면 **결과가 바뀐다**.

## F. 변형 문제
1. WHERE를 `e.sal >= 1300`으로 바꾸고 S1~S7의 행 수를 다시 예측하라.
2. JOIN을 `dept d LEFT JOIN emp e`로 바꾸면 S1과 S3은 어떻게 달라지는가? (OPERATIONS 그룹의 COUNT(*)는 1, COUNT(e.empno)는 0)
3. `ORDER BY total DESC` 대신 `ORDER BY cnt`로 바꾸면 최종 2행은?

G: [../exercises/ex04_logical_order_trace.md](../exercises/ex04_logical_order_trace.md)
