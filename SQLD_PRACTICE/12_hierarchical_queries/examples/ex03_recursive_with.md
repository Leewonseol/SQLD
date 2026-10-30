# ex03 재귀 WITH (재귀 CTE)

> 근거: 요구목록 §7(계층형 질의) — 표준 구문. 추출본에는 재귀 WITH 본문 없음 · 데이터: H_EMP, EMP, EMP1 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 구조: `WITH t(열목록) AS ( 기준 부분(루트) UNION ALL 재귀 부분(t와 원본 조인) ) SELECT … FROM t`
* Oracle 재귀 WITH는 열 이름 목록이 **필수**다. `SEARCH DEPTH FIRST BY 컬럼 SET 순서열`(ORDER SIBLINGS BY와 같은 순서), `CYCLE 컬럼 SET 표시열 TO 'Y' DEFAULT 'N'`(순환 감지)을 지원한다.
* SQL Server: SEARCH/CYCLE 절이 없다. 기준 부분과 재귀 부분의 자료형·길이가 **정확히** 같아야 한다(Msg 240) → CAST로 맞춘다.

## B. 입력 데이터
H_EMP, EMP, EMP1

## C. 실행 SQL
[Oracle](ex03_recursive_with_oracle.sql) · [SQL Server](ex03_recursive_with_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 결과는 ex01 Q1(CONNECT BY)과 같은가?
2. SQL Server Q3에서 CAST를 빼면 왜 오류인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_recursive_with_oracle.sql -->
```text
== [Q1] 재귀 WITH 로 CONNECT BY 와 같은 결과 (열 이름 목록 필수)

EMP_NAME|MGR_NAME|LVL|PATH
A|(null)|1|/A
B|A|2|/A/B
C|A|2|/A/C
D|C|3|/A/C/D

4 rows selected.

== [Q2] SEARCH DEPTH FIRST BY (ORDER SIBLINGS BY 와 같은 깊이 우선 순서)

ORG|LVL
KING|1
. BLAKE|2
... ALLEN|3
... JAMES|3
... MARTIN|3
... TURNER|3
... WARD|3
. CLARK|2
... MILLER|3
. JONES|2
... FORD|3
..... SMITH|4
... SCOTT|3
..... ADAMS|4

14 rows selected.

== [Q3] CYCLE 절로 순환 감지 (EMP1)

EMP_ID|NAME|LVL|IS_CYCLE
1000|홍길동|1|N
2000|강감찬|2|N
1000|홍길동|3|Y

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_recursive_with_sqlserver.sql -->
```text
== [Q1] 재귀 CTE
emp_name|mgr_name|lvl|path
--------|--------|---|----
A|NULL|1|/A
B|A|2|/A/B
C|A|2|/A/C
D|C|3|/A/C/D

(4 rows affected)
== [Q2] 깊이 우선 순서: 이름 경로로 정렬
org|lvl
---|---
KING|1
..BLAKE|2
....ALLEN|3
....JAMES|3
....MARTIN|3
....TURNER|3
....WARD|3
..CLARK|2
....MILLER|3
..JONES|2
....FORD|3
......SMITH|4
....SCOTT|3
......ADAMS|4

(14 rows affected)
== [Q3] 재귀 부분의 형이 기준 부분과 다르면 오류 (CAST 를 빼면)
Msg 240, Level 16, State 1, Server a70f428a7f8a, Line 2
Types don't match between the anchor and the recursive part in column "path" of recursive query "t".
```
<!-- /RESULT -->

**이유**
* Q1: 같은 4행(A, B, C, D)과 경로.
* Q2: Oracle SEARCH DEPTH FIRST는 CONNECT BY + ORDER SIBLINGS BY와 같은 순서다. SQL Server는 이름 경로 문자열로 정렬해 같은 순서를 만들었다.
* Oracle Q3: CYCLE 절이 1000을 다시 만나는 행을 is_cycle = 'Y'로 표시하고 멈춘다(CONNECT BY NOCYCLE과 달리 순환된 행 자체가 한 번 더 나온다).
* SQL Server Q3: 기준 부분의 `'/' + emp_name`은 VARCHAR(6), 재귀 부분은 길이가 늘어나 형이 달라진다 → Msg 240.

## F. 변형 문제
1. 각 사원의 상위 관리자 수(LEVEL − 1)를 재귀 CTE로 구하라.
2. CONNECT BY와 재귀 WITH 중 SQL Server로 옮길 수 있는 것은?

G: [../exercises/ex03_recursive_with.md](../exercises/ex03_recursive_with.md)
