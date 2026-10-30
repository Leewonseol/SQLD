# ex09 CROSS JOIN (카티션 곱)

> 근거: PDF추출본 E-18 · 데이터: **PDF 원문 값**(Table1 X1·X2, Table2 X1·Y2) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을 하는가**: 조인 조건 없이 가능한 모든 행 조합을 만든다. E.F. Codd의 일반 집합 연산자 PRODUCT에 해당한다. 행 수는 M × N이다.
* **언제 쓰는가**: 모든 조합이 필요할 때 일부러 쓴다(달력 × 매장, 사이즈 × 색상). 조인 조건을 빠뜨려 **실수로** 생기는 경우가 더 많다.
* **차이**: INNER JOIN은 CROSS JOIN 결과 중 조건을 만족하는 행만 남긴 것이다. NULL도 한 행으로 조합된다.

## B. 입력 데이터 (PDF)
CJ_T1: (a, 12) (b, 3) (NULL, 8) · CJ_T2: (a, 4.8) (b, 1.2) (C, 3.6)

## C. 실행 SQL
[Oracle](ex09_cross_join_oracle.sql) · [SQL Server](ex09_cross_join_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 행 수는? x1이 NULL인 행은 결과에 몇 번 나오는가?
2. Q3 EQUI JOIN은 몇 행인가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex09_cross_join_oracle.sql -->
```text
== [Q1] CROSS JOIN = 3 x 3 = 9행. 조인 조건이 없으므로 NULL 도 그대로 조합된다

X1|X2|X1|Y2
a|12|a|4.8
a|12|C|3.6
a|12|b|1.2
(null)|8|a|4.8
(null)|8|C|3.6
(null)|8|b|1.2
b|3|a|4.8
b|3|C|3.6
b|3|b|1.2

9 rows selected.

== [Q2] Oracle 방식: FROM 에 테이블만 나열하고 WHERE 조인 조건이 없으면 카티션 곱

CARTESIAN_ROWS
9

1 row selected.

== [Q3] 비교: 같은 데이터에 x1 으로 EQUI JOIN -> a, b 2행 (NULL 과 'C' 는 짝이 없다)

X1|X2|Y2
a|12|4.8
b|3|1.2

2 rows selected.

== [Q4] CROSS JOIN 에 ON -> 오류
SELECT * FROM cj_t1 a CROSS JOIN cj_t2 b ON a.x1 = b.x1
                                         *
ERROR at line 1:
ORA-00933: SQL command not properly ended

== [Q5] 문자 정렬 비교: x1 오름차순 (Oracle 기본 BINARY 정렬, NULL 은 마지막)

X1
C
a
a
b
b
(null)

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex09_cross_join_sqlserver.sql -->
```text
== [Q1] CROSS JOIN 9행
x1|x2|x1|y2
--|--|--|--
a|12|a|4.8
a|12|C|3.6
a|12|b|1.2
NULL|8|a|4.8
NULL|8|C|3.6
NULL|8|b|1.2
b|3|a|4.8
b|3|C|3.6
b|3|b|1.2

(9 rows affected)
== [Q2] FROM a, b
cartesian_rows
--------------
9

(1 rows affected)
== [Q3] EQUI JOIN 비교
x1|x2|y2
--|--|--
a|12|4.8
b|3|1.2

(2 rows affected)
== [Q4] CROSS JOIN 에 ON -> 오류
Msg 156, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near the keyword 'ON'.
== [Q5] 문자 정렬 비교: x1 오름차순 (기본 데이터 정렬, NULL 은 처음)
x1
--
NULL
a
a
b
b
C

(6 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 = 3 × 3 = 9행이다. 비교가 없으므로 NULL 행도 CJ_T2의 각 행과 한 번씩, 3번 나온다. PDF 결과표 9행과 일치한다.
* 정렬은 숫자 컬럼(x2 DESC, y2 DESC)으로만 했다. 그래서 두 DBMS의 행 순서가 같다. 문자 컬럼 x1로 정렬하면 순서가 달라질 수 있다. Oracle 기본(BINARY)에서는 대문자 `C`가 소문자 `a`·`b`보다 앞이다. SQL Server 기본 데이터 정렬(대소문자 구분 안 함)에서는 a < b < C다. NULL의 위치도 다르다(06단원 ex05). Q5에서 실행으로 확인했다. Oracle은 `C a a b b (null)`, SQL Server(SQL_Latin1_General_CP1_CI_AS)는 `NULL a a b b C`다. **문자 정렬 결과는 DBMS와 데이터 정렬 설정에 따라 다르다.**
* Q3 = 2행: 'C'와 NULL은 짝이 없다.
* Q4: CROSS JOIN에는 ON을 쓸 수 없다. Oracle ORA-00933, SQL Server Msg 156.

## F. 변형 문제
1. CJ_T2에 행 1개를 추가하면 Q1은 몇 행인가?
2. Q1에 `WHERE cj_t1.x1 = cj_t2.x1`을 붙이면 어떤 조인과 같아지는가?
3. 빈 테이블과 CROSS JOIN 하면 몇 행인가?

G: [exercises/ex09_cross_join.md](../exercises/ex09_cross_join.md)
