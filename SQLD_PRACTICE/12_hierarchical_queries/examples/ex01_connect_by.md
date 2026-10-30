# ex01 START WITH · CONNECT BY PRIOR 와 계층형 가상 컬럼·함수

> 근거: PDF추출본 E-37(LEVEL, CONNECT_BY_ISLEAF, CONNECT_BY_ROOT, SYS_CONNECT_BY_PATH, ORDER SIBLINGS BY, 사원 A·B·C·D 결과표) · 데이터: H_EMP(PDF 원문 값), EMP(SCOTT) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `START WITH`: 루트 행 조건. 생략하면 **모든 행**이 각각 루트가 된다(Q6).
* `CONNECT BY PRIOR 부모컬럼 = 자식컬럼`: 부모–자식 연결 조건(방향은 단원 안내의 기억법).
* 가상 컬럼: `LEVEL`(루트 1), `CONNECT_BY_ISLEAF`(리프면 1). 가상 함수: `CONNECT_BY_ROOT 컬럼`(루트 값), `SYS_CONNECT_BY_PATH(컬럼, '/')`(경로), `ORDER SIBLINGS BY`(계층을 유지하면서 형제끼리 정렬), `CONNECT_BY_ISCYCLE`(ex02).
* **WHERE vs CONNECT BY 조건**: WHERE는 전개가 **끝난 뒤** 해당 행만 지운다(자식은 남는다). CONNECT BY에 넣은 조건은 그 노드에서 **전개를 멈춰** 하위 가지 전체가 빠진다.
* 계층형 질의의 처리 순서: START WITH → CONNECT BY 전개 → WHERE → (SELECT) → ORDER BY.

## B. 입력 데이터
H_EMP(PDF 원문 값), EMP(SCOTT)

## C. 실행 SQL
[Oracle](ex01_connect_by_oracle.sql) · [SQL Server](ex01_connect_by_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 결과의 LEVEL과 IS_LEAF를 예측하라.
2. Q5 두 쿼리의 행 수는? (JONES 아래: FORD, SMITH, SCOTT, ADAMS)

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_connect_by_oracle.sql -->
```text
== [Q1] PDF 예 (순방향, 위 -> 아래): PRIOR 사원 = 관리자 -> "부모 행의 사원 = 자식 행의 관리자"

루트사원|경로|사원|관리자|LVL|IS_LEAF
A|/A|A|(null)|1|0
A|/A/B|B|A|2|1
A|/A/C|C|A|2|0
A|/A/C/D|D|C|3|1

4 rows selected.

== [Q2] 역방향(아래 -> 위): PRIOR 를 반대편에 두면 D 에서 루트까지 올라간다

LVL|EMP_NAME|MGR_NAME|PATH
1|D|C|/D
2|C|A|/D/C
3|A|(null)|/D/C/A

3 rows selected.

== [Q3] EMP(SCOTT) 전체 조직도: 들여쓰기 + ORDER SIBLINGS BY (형제 사이만 정렬, 계층 구조 유지)

ORG|LVL|LEAF
KING|1|0
. BLAKE|2|0
... ALLEN|3|1
... JAMES|3|1
... MARTIN|3|1
... TURNER|3|1
... WARD|3|1
. CLARK|2|0
... MILLER|3|1
. JONES|2|0
... FORD|3|0
..... SMITH|4|1
... SCOTT|3|0
..... ADAMS|4|1

14 rows selected.

== [Q4] 일반 ORDER BY 를 쓰면 계층 순서가 깨진다

LVL|ENAME
4|ADAMS
3|ALLEN
2|BLAKE
2|CLARK
3|FORD

5 rows selected.

== [Q5] WHERE 는 전개가 끝난 뒤 행을 거른다(자식은 남음) / CONNECT BY 의 조건은 그 가지 전체를 잘라낸다

LVL|ENAME
1|KING
2|BLAKE
3|ALLEN
3|JAMES
3|MARTIN
3|TURNER
3|WARD
2|CLARK
3|MILLER
3|FORD
4|SMITH
3|SCOTT
4|ADAMS

13 rows selected.

LVL|ENAME
1|KING
2|BLAKE
3|ALLEN
3|JAMES
3|MARTIN
3|TURNER
3|WARD
2|CLARK
3|MILLER

9 rows selected.

== [Q6] START WITH 를 빼면 모든 행이 각각 루트가 된다 (행 수 증가)

ROWS_NO_START_WITH
8

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_connect_by_sqlserver.sql -->
```text
== [Q0] CONNECT BY 구문 -> 오류
Msg 336, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near 'mgr_name'. If this is intended to be a common table expression, you need to explicitly terminate the previous statement with a semi-colon.
== [Q1] 재귀 CTE 로 PDF 결과표 재현: 루트·경로·LEVEL·리프 여부
루트사원|경로|사원|관리자|lvl|is_leaf
----|--|--|---|---|-------
A|/A|A|NULL|1|0
A|/A/B|B|A|2|1
A|/A/C|C|A|2|0
A|/A/C/D|D|C|3|1

(4 rows affected)
== [Q2] 역방향: D 에서 루트까지
lvl|emp_name|mgr_name|path
---|--------|--------|----
1|D|C|/D
2|C|A|/D/C
3|A|NULL|/D/C/A

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: A(1, 리프 아님), B(2, 리프), C(2, 리프 아님), D(3, 리프). PDF 결과표와 일치한다.
* Q2: D에서 출발해 C → A로 올라간다. LEVEL은 출발점에서 1이다.
* Q3: 조직도(14행). ORDER SIBLINGS BY ename은 형제끼리만 정렬한다. Q4의 일반 ORDER BY는 계층 순서를 깨뜨린다.
* Q5: WHERE는 JONES 한 행만 지워 13행, CONNECT BY 조건은 JONES 가지(JONES·FORD·SMITH·SCOTT·ADAMS 5행)를 잘라 9행.
* Q6: START WITH가 없으면 각 행을 루트로 한 번씩 전개한다. A(4) + B(1) + C(2) + D(1) = 8행.

## F. 변형 문제
1. KING의 직속 부하만(LEVEL = 2) 출력하라.
2. 각 사원의 최상위 관리자 이름(CONNECT_BY_ROOT)과 경로를 구하라.
3. Q5에서 JONES를 지우되 JONES의 부하는 남기면서, 그 부하들의 LEVEL은 몇이 되는지 확인하라.

G: [../exercises/ex01_connect_by.md](../exercises/ex01_connect_by.md)
