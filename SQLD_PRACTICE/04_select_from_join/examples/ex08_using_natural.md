# ex08 ON·USING·NATURAL JOIN

> 근거: PDF추출본 E-15(ON), E-16(USING), E-17(NATURAL) · 데이터: **PDF 원문 값**(NJ_T1·NJ_T2·NJ_T3 = PDF의 Table1/Table2 두 예시) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 구분 | 조인 컬럼 지정 | 컬럼명이 달라도 | 결과의 조인 컬럼 | 접두사 | SQL Server |
|---|---|---|---|---|---|
| ON | 조건식을 직접 씀(괄호 선택) | 가능 | 양쪽 컬럼이 따로 남음 | 필요(같은 이름이면 필수) | 지원 |
| USING (col) | 같은 이름 컬럼을 골라 씀(괄호 필수) | 불가 | 하나로 합쳐지고 `SELECT *`에서 맨 앞 | **불가** ORA-25154 | 미지원 |
| NATURAL | 같은 이름 **모든** 컬럼을 자동 사용 | 불가 | 하나로 합쳐지고 맨 앞 | **불가** ORA-25155 | 미지원 |

* NATURAL JOIN에는 ON·USING을 추가할 수 없다. 일반 필터용 WHERE는 쓸 수 있다(Q9).
* 조인 컬럼이 NULL이면 같은 값으로 보지 않는다(PDF E-17).

## B. 입력 데이터 (PDF)
| NJ_T1(no, name) | NJ_T2(no, name) | NJ_T3(no, pos) |
|---|---|---|
| 1 A / 2 B / NULL C | 1 A / 2 C / NULL C | 1 탑 / 2 미드 / 1 정글 / NULL 서포터 |

## C. 실행 SQL
[Oracle](ex08_using_natural_oracle.sql) · [SQL Server](ex08_using_natural_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 NATURAL JOIN(NO, NAME 모두 비교)은 몇 행인가? `(NULL, C)` 두 행은 짝지어지는가?
2. Q2 NATURAL JOIN(NO만 비교)은 몇 행인가?
3. Q3 USING(no)의 행 수와 T2_NAME은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex08_using_natural_oracle.sql -->
```text
== [Q1] NATURAL JOIN nj_t1 - nj_t2 : 이름이 같은 모든 컬럼(NO, NAME)이 같아야 조인

NO|NAME
1|A

1 row selected.

== [Q2] NATURAL JOIN nj_t1 - nj_t3 : 공통 컬럼은 NO 하나. SELECT * 에서 공통 컬럼이 맨 앞, 한 번만

NO|NAME|POS
1|A|정글
1|A|탑
2|B|미드

3 rows selected.

== [Q3] USING (no) : NAME 은 공통 조인 컬럼이 아니므로 양쪽에 따로 남는다

NO|T1_NAME|T2_NAME
1|A|A
2|B|C

2 rows selected.

== [Q4] ON a.no = b.no : USING 과 같은 행, 하지만 NO 컬럼이 두 번 나온다

NO|NAME|NO|NAME
1|A|1|A
2|B|2|C

2 rows selected.

== [Q5] USING 컬럼에 테이블 접두사 -> 오류 (PDF E-16)
SELECT a.no FROM nj_t1 a JOIN nj_t2 b USING (no)
       *
ERROR at line 1:
ORA-25154: column part of USING clause cannot have qualifier

== [Q6] NATURAL JOIN 컬럼에 접두사 -> 오류 (PDF E-17)
SELECT a.no FROM nj_t1 a NATURAL JOIN nj_t2 b
       *
ERROR at line 1:
ORA-25155: column used in NATURAL join cannot have qualifier

== [Q7] NATURAL JOIN 에 ON 추가 -> 오류 (PDF E-17)
SELECT * FROM nj_t1 NATURAL JOIN nj_t2 ON nj_t1.no = nj_t2.no
                                       *
ERROR at line 1:
ORA-00933: SQL command not properly ended

== [Q8] USING 괄호 생략 -> 오류 (PDF E-16 "괄호 필수")
SELECT no FROM nj_t1 JOIN nj_t2 USING no
                                      *
ERROR at line 1:
ORA-00905: missing keyword

== [Q9] PDF 예: EMP NATURAL JOIN DEPT (공통 컬럼 DEPTNO). WHERE 의 일반 필터는 허용

DEPTNO|EMPNO|ENAME|DNAME
10|7782|CLARK|ACCOUNTING
10|7839|KING|ACCOUNTING
10|7934|MILLER|ACCOUNTING

3 rows selected.

== [Q10] PDF 예: NATURAL JOIN 결과에서 DEPT.DEPTNO 로 접두사 -> 오류
SELECT dept.deptno, empno, ename, dname FROM emp NATURAL JOIN dept
       *
ERROR at line 1:
ORA-25155: column used in NATURAL join cannot have qualifier
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex08_using_natural_sqlserver.sql -->
```text
== [Q1] NATURAL JOIN -> 구문 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near ';'.
== [Q2] USING -> 구문 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near 'USING'.
== [Q3] NATURAL JOIN nj_t1-nj_t2 대체: 같은 이름의 모든 컬럼을 ON 에 나열
no|name
--|----
1|A

(1 rows affected)
== [Q4] NATURAL JOIN nj_t1-nj_t3 대체
no|name|pos
--|----|---
1|A|정글
1|A|탑
2|B|미드

(3 rows affected)
== [Q5] USING (no) 대체
no|t1_name|t2_name
--|-------|-------
1|A|A
2|B|C

(2 rows affected)
== [Q6] ON 조인: SELECT * 이면 no 가 두 번
no|name|no|name
--|----|--|----
1|A|1|A
2|B|2|C

(2 rows affected)
== [Q7] EMP-DEPT NATURAL JOIN 대체 (deptno = 10)
deptno|empno|ename|dname
------|-----|-----|-----
10|7782|CLARK|ACCOUNTING
10|7839|KING|ACCOUNTING
10|7934|MILLER|ACCOUNTING

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 = 1행(1, A): (2,B)와 (2,C)는 NAME이 달라 짝이 아니다. (NULL,C)끼리는 NO가 NULL이라 같은 값이 아니다.
* Q2 = 3행: NO만 공통 컬럼이다. 1은 탑·정글 두 행과, 2는 미드와 짝지어진다. NULL–서포터는 빠진다. PDF 결과표(1 A 탑, 1 A 정글, 2 B 미드)와 일치한다.
* Q3 = 2행: NAME은 조인 컬럼이 아니므로 T1_NAME·T2_NAME이 따로 나온다(2 B / C).
* Q5·Q6·Q10: 조인 컬럼에 접두사를 붙이면 ORA-25154·ORA-25155. Q7: NATURAL + ON → ORA-00933. Q8: USING 괄호 생략 → ORA-00905.
* SQL Server Q1: `nj_t1 NATURAL JOIN nj_t2`에서 `NATURAL`을 **nj_t1의 별칭**으로 해석한다. 그 뒤 JOIN에 ON이 없어 Msg 102가 난다. USING은 Msg 102. PDF의 "SQL Server 지원X"와 일치한다. 대체 구문은 ON에 같은 이름 컬럼을 모두 나열하는 것이다(Q3~Q7).

## F. 변형 문제
1. NJ_T2에 `(2, 'B')`를 추가하면 Q1은 몇 행이 되는가?
2. NJ_T3의 컬럼 이름 `pos`를 `name`으로 바꾸면 Q2 NATURAL JOIN은 어떤 컬럼들로 비교하는가?
3. `SELECT *`를 썼을 때 USING과 ON의 출력 컬럼 개수 차이를 설명하라.

G: [exercises/ex08_using_natural.md](../exercises/ex08_using_natural.md)
