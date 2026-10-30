# ex03 SELECT·DISTINCT·ALIAS·산술 연산·문자열 결합·DUAL

> 근거: PDF추출본 E-07(DUAL), 요구목록 §7(SELECT·DISTINCT·별칭) — PDF 내 SELECT 절 본문은 추출본에 없음 · 데이터: SCOTT · 검증: Oracle 21c / SQL Server 2022 / 23ai 계열 실행

## A. 개념 설명
* **DISTINCT**: SELECT 목록 **전체 조합**을 기준으로 중복 행을 없앤다. 컬럼 하나에만 적용되지 않는다. 기본값은 ALL(중복 유지)이다.
* **ALIAS**: 출력 열 이름만 바꾼다. AS는 생략할 수 있다. Oracle은 따옴표 없는 별칭을 대문자로 출력하고, `"..."` 안의 별칭은 그대로 둔다. SQL Server는 대소문자를 그대로 두고 `"..."`나 `[...]`를 쓴다.
* **NULL 산술**: NULL이 하나라도 들어간 산술식은 결과가 NULL이다.
* **결합**: Oracle `||`는 NULL을 빈 문자열처럼 다룬다. SQL Server `+`는 NULL이 하나라도 있으면 NULL이다. `CONCAT`은 두 DBMS 모두 NULL을 빈 문자열로 다룬다. Oracle CONCAT은 인수 2개만 받는다.
* **DUAL**(PDF E-07): Oracle의 1행 1열(DUMMY='X') 더미 테이블이다. SYS가 소유하고 모든 사용자가 쓸 수 있다. 23ai 이전 Oracle은 FROM이 필수라 DUAL이 필요하다. SQL Server는 FROM 없이 SELECT 할 수 있고 DUAL이 없다.

## B. 입력 데이터
EMP 14행(00_common). 30번 부서 6명 중 BLAKE·JAMES의 comm이 NULL, TURNER는 0이다.

## C. 실행 SQL
[Oracle](ex03_select_basics_oracle.sql) · [SQL Server](ex03_select_basics_sqlserver.sql) · [23ai 계열 전용](ex03_select_basics_oracle23ai.sql)

## D. 결과 예측 문제
1. Q1과 Q2는 각각 몇 행인가?
2. Q4에서 `sal + comm`이 NULL인 행은 누구인가? TURNER(comm 0)는?
3. Q5의 `'X' || NULL`과 SQL Server `'X' + NULL`의 결과는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex03_select_basics_oracle.sql -->
```text
== [Q1] DISTINCT 한 컬럼

JOB
ANALYST
CLERK
MANAGER
PRESIDENT
SALESMAN

5 rows selected.

== [Q2] DISTINCT 두 컬럼 = (deptno, job) 조합 기준 중복 제거

DEPTNO|JOB
10|CLERK
10|MANAGER
10|PRESIDENT
20|ANALYST
20|CLERK
20|MANAGER
30|CLERK
30|MANAGER
30|SALESMAN

9 rows selected.

== [Q3] 별칭: AS 생략 가능, 큰따옴표 없으면 대문자로 출력, 있으면 그대로

이름|MONTHLY|Annual Sal
CLARK|2450|29400
KING|5000|60000
MILLER|1300|15600

3 rows selected.

== [Q4] NULL 이 섞인 산술 연산 결과는 NULL

ENAME|SAL|COMM|SAL_PLUS_COMM|SAL_PLUS_NVL
ALLEN|1600|300|1900|1900
WARD|1250|500|1750|1750
MARTIN|1250|1400|2650|2650
BLAKE|2850|(null)|(null)|2850
TURNER|1500|0|1500|1500
JAMES|950|(null)|(null)|950

6 rows selected.

== [Q5] 문자열 결합: || 는 NULL 을 빈 문자열처럼 다룬다, CONCAT 은 인수 2개

WHO|X_NULL|CONCAT_NULL
SMITH(CLERK)|X|X

1 row selected.

== [Q6] DUAL: DUMMY 컬럼 하나, 값 'X' 한 행 (PDF E-07)

DUMMY
X

1 row selected.

TWO|ZERO
2|0

1 row selected.

== [Q7] 21c 에서 FROM 생략 -> 오류 (PDF E-07: 23c 이전은 FROM 필수)
SELECT 1 + 1 AS two
                  *
ERROR at line 1:
ORA-00923: FROM keyword not found where expected
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_select_basics_sqlserver.sql -->
```text
== [Q1] DISTINCT 한 컬럼
job
---
ANALYST
CLERK
MANAGER
PRESIDENT
SALESMAN

(5 rows affected)
== [Q2] DISTINCT 두 컬럼
deptno|job
------|---
10|CLERK
10|MANAGER
10|PRESIDENT
20|ANALYST
20|CLERK
20|MANAGER
30|CLERK
30|MANAGER
30|SALESMAN

(9 rows affected)
== [Q3] 별칭: 대소문자를 바꾸지 않는다, 공백 포함 시 "" 또는 []
이름|monthly|Annual Sal|Annual Sal2
--|-------|----------|-----------
CLARK|2450.00|29400.00|29400.00
KING|5000.00|60000.00|60000.00
MILLER|1300.00|15600.00|15600.00

(3 rows affected)
== [Q4] NULL 이 섞인 산술 연산 결과는 NULL
ename|sal|comm|sal_plus_comm|sal_plus_isnull
-----|---|----|-------------|---------------
ALLEN|1600.00|300.00|1900.00|1900.00
WARD|1250.00|500.00|1750.00|1750.00
MARTIN|1250.00|1400.00|2650.00|2650.00
BLAKE|2850.00|NULL|NULL|2850.00
TURNER|1500.00|.00|1500.00|1500.00
JAMES|950.00|NULL|NULL|950.00

(6 rows affected)
== [Q5] 문자열 결합: + 는 NULL 이 하나라도 있으면 NULL, CONCAT 은 NULL 을 빈 문자열로
who|x_null|concat_null|concat3
---|------|-----------|-------
SMITH(CLERK)|NULL|X|ABC

(1 rows affected)
== [Q6] FROM 없는 SELECT 가능
two
---
2

(1 rows affected)
== [Q7] DUAL 테이블은 없다 -> 오류
Msg 208, Level 16, State 1, Server a70f428a7f8a, Line 2
Invalid object name 'dual'.
```
<!-- /RESULT -->

23ai 계열 (Oracle AI Database 26ai Free 23.26.3)
<!-- RESULT: ex03_select_basics_oracle23ai.sql -->
```text
== [Q1] FROM 절 없는 SELECT (23ai 부터 허용)
TWO
2

1 row selected.

== [Q2] DROP TABLE IF EXISTS (23ai 부터 허용)

Table dropped.

Table created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [Q3] GROUP BY 에 SELECT 별칭 사용 (23ai 부터 허용)
D|S
10|300
20|300

2 rows selected.

== [Q4] 버전 확인
BANNER_FULL
Oracle AI Database 26ai Free Release 23.26.3.0.0 - Develop, Learn, and Run for Free
Version 23.26.3.0.0

1 row selected.

Table dropped.
```
<!-- /RESULT -->

**이유**
* Q1: JOB 값 5종 → 5행. Q2: (deptno, job) 조합 9종 → 9행. 14행이 9행으로 줄었다. 조합 전체가 같아야 중복이다.
* Q3: Oracle은 `monthly`를 `MONTHLY`로, 한글 별칭은 그대로 출력한다. SQL Server는 `monthly` 그대로다.
* Q4: BLAKE·JAMES는 comm이 NULL이라 `sal+comm`이 NULL이다. TURNER는 0이라 1500이다. **NULL과 0은 다르다.**
* Q5: Oracle `'X'||NULL = 'X'`, SQL Server `'X'+NULL = NULL`. 두 DBMS의 결과가 **다르다**.
* Q7(21c): ORA-00923 FROM keyword not found. 23ai 계열 Q1은 성공한다. PDF E-07 서술과 일치한다.

## F. 변형 문제
1. `SELECT DISTINCT deptno, job` 대신 `SELECT DISTINCT deptno`로 바꾸면 몇 행인가?
2. Q4의 NVL을 `NVL2(comm, sal+comm, sal)`로 바꿔도 같은가? (07단원 ex05)
3. Oracle에서 `SELECT ename AS "이름 " FROM emp`처럼 별칭 끝에 공백이 있으면 출력 열 이름은?
4. `SELECT DISTINCT * FROM dual`은 몇 행인가?

G: [exercises/ex03_select_basics.md](../exercises/ex03_select_basics.md)
