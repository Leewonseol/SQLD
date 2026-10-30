# ex02 집합 연산의 규칙

> 근거: PDF추출본 E-27("두 집합의 각 컬럼의 순서와 데이터 타입이 상호 호환 가능해야", "전체 집합의 컬럼명과 데이터 타입은 첫 번째 집합에 의해 결정") · 데이터: EMP, DEPT, S_A·S_B·S_C · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 각 SELECT의 컬럼 **수**가 같아야 하고, 같은 위치의 자료형이 호환되어야 한다.
* 결과 컬럼 이름은 첫 번째 SELECT가 정한다. ORDER BY는 맨 끝에 한 번만 쓰고, 첫 SELECT의 이름이나 위치 번호를 쓴다.
* 우선순위: Oracle은 왼쪽부터 처리한다. SQL Server는 INTERSECT를 먼저 처리한다. 괄호로 의도를 명시한다.

## B. 입력 데이터
EMP, DEPT, S_A·S_B·S_C

## C. 실행 SQL
[Oracle](ex02_set_operation_rules_oracle.sql) · [SQL Server](ex02_set_operation_rules_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 결과 컬럼 이름은?
2. Q6 `A UNION B INTERSECT C`의 결과는 두 DBMS에서 각각?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_set_operation_rules_oracle.sql -->
```text
== [Q1] 결과 컬럼명은 첫 번째 SELECT 의 이름

FIRST_NAME|SAL
SMITH|800
ACCOUNTING|10

2 rows selected.

== [Q2] ORDER BY 는 맨 끝에 한 번. 첫 SELECT 의 이름이나 위치 번호로

NM|SAL
ACCOUNTING|10
CLARK|2450
KING|5000
MILLER|1300
OPERATIONS|40
RESEARCH|20
SALES|30

7 rows selected.

== [Q3] 두 번째 SELECT 의 별칭으로 정렬 -> 오류
SELECT ename AS nm FROM emp WHERE deptno = 10 UNION ALL SELECT dname AS dn FROM dept ORDER BY dn
                                                                                              *
ERROR at line 1:
ORA-00904: "DN": invalid identifier

== [Q4] 컬럼 수가 다르면 오류
SELECT ename, sal FROM emp UNION SELECT dname FROM dept
*
ERROR at line 1:
ORA-01789: query block has incorrect number of result columns

== [Q5] 자료형이 호환되지 않으면 오류 (문자 vs 숫자)
SELECT ename FROM emp UNION SELECT deptno FROM dept
       *
ERROR at line 1:
ORA-01790: expression must have same datatype as corresponding expression

== [Q6] 연산자 우선순위: Oracle 은 모든 집합 연산자가 같은 우선순위 -> 왼쪽부터: (A UNION B) INTERSECT C

V
2

1 row selected.

== [Q7] 각 SELECT 안에는 ORDER BY 를 둘 수 없다 (괄호로 감싼 인라인 뷰 안이라면 가능)
SELECT ename FROM emp WHERE deptno = 10 ORDER BY ename UNION SELECT dname FROM dept
                                                       *
ERROR at line 1:
ORA-00933: SQL command not properly ended
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_set_operation_rules_sqlserver.sql -->
```text
== [Q1] 결과 컬럼명은 첫 번째 SELECT
first_name|sal
----------|---
SMITH|800.00
ACCOUNTING|10.00

(2 rows affected)
== [Q2] ORDER BY 는 맨 끝에 한 번
nm|sal
--|---
ACCOUNTING|10.00
CLARK|2450.00
KING|5000.00
MILLER|1300.00
OPERATIONS|40.00
RESEARCH|20.00
SALES|30.00

(7 rows affected)
== [Q3] 두 번째 SELECT 별칭으로 정렬 -> 오류
Msg 207, Level 16, State 1, Server a70f428a7f8a, Line 2
Invalid column name 'dn'.
Msg 104, Level 16, State 1, Server a70f428a7f8a, Line 2
ORDER BY items must appear in the select list if the statement contains a UNION, INTERSECT or EXCEPT operator.
== [Q4] 컬럼 수 불일치 -> 오류
Msg 205, Level 16, State 1, Server a70f428a7f8a, Line 2
All queries combined using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in their target lists.
== [Q5] 문자 vs 숫자: SQL Server 는 숫자 쪽으로 변환을 시도 -> 실패
Msg 245, Level 16, State 1, Server a70f428a7f8a, Line 2
Conversion failed when converting the varchar value 'SMITH' to data type tinyint.
== [Q6] 연산자 우선순위: SQL Server 는 INTERSECT 가 먼저 -> A UNION (B INTERSECT C)
v
-
NULL
1
2

(3 rows affected)
== [Q6b] 괄호로 Oracle 과 같은 의미 만들기
v
-
2

(1 rows affected)
== [Q7] 각 SELECT 안의 ORDER BY -> 오류
Msg 156, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near the keyword 'UNION'.
```
<!-- /RESULT -->

**이유**
* Q1 FIRST_NAME·SAL. Q2 nm으로 정렬했다. Q3 두 번째 별칭 dn은 ORA-00904 / Msg 207 + 104.
* Q4 컬럼 수 → ORA-01789 / Msg 205. Q5 자료형 → ORA-01790 / Msg 245(SQL Server는 TINYINT로 'SMITH'를 바꾸려다 실패).
* Q6: Oracle (A∪B)∩C = {2}. SQL Server A∪(B∩C) = {NULL, 1, 2}. **결과가 다르다.** 괄호를 쓰면(Q6b) 같아진다.
* Q7: 각 SELECT 안의 ORDER BY → ORA-00933 / Msg 156.

## F. 변형 문제
1. Q5를 오류 없이 실행되게 고쳐라(TO_CHAR/CAST).
2. `A EXCEPT B UNION C`의 결과를 두 DBMS 규칙으로 예측하라.

G: [../exercises/ex02_set_operation_rules.md](../exercises/ex02_set_operation_rules.md)
