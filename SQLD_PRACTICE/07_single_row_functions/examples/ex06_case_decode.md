# ex06 CASE 표현식과 DECODE

> 근거: 요구목록 §7(CASE). E-29에서 DECODE(GROUPING(...)) 사용 · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **단순 CASE** `CASE 식 WHEN 값 THEN …`: `식 = 값` 비교다. 그래서 `WHEN NULL`은 절대 일치하지 않는다.
* **검색 CASE** `CASE WHEN 조건 THEN …`: 조건을 위에서부터 평가해 **처음으로 참인** WHEN의 결과를 낸다. ELSE가 없으면 NULL이다.
* 모든 THEN/ELSE 결과는 같은 자료형으로 맞춰야 한다.
* **DECODE**(Oracle 전용): `DECODE(식, 값1, 결과1, …, 기본값)`. CASE와 달리 **NULL과 NULL을 같다고** 본다.
* SQL Server 전용: `IIF(조건, 참, 거짓)`, `CHOOSE(n, 값1, 값2, …)`.

## B. 입력 데이터
EMP. 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex06_case_decode_oracle.sql) · [SQL Server](ex06_case_decode_sqlserver.sql)

## D. 결과 예측 문제
1. Q2에서 KING(5000)의 결과는 '3000+'인가?
2. Q4 `CASE comm WHEN NULL THEN 'NULL!'`은 BLAKE(comm NULL)에게 무엇을 돌려주는가?
3. Q5 DECODE는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex06_case_decode_oracle.sql -->
```text
== [Q1] 단순 CASE (값 비교) 와 검색 CASE (조건)

ENAME|DEPTNO|SIMPLE_CASE|SEARCHED_CASE
SMITH|20|RES|LOW
ALLEN|30|ETC|MID
KING|10|ACC|HIGH
FORD|20|RES|HIGH

4 rows selected.

== [Q2] 첫 번째로 참인 WHEN 에서 멈춘다 (순서 함정): 5000 은 첫 WHEN(>= 1000) 에서 끝

ENAME|SAL|WRONG_ORDER
SMITH|800|(null)
KING|5000|1000+

2 rows selected.

== [Q3] ELSE 생략 -> 해당 없으면 NULL

ENAME|HAS_COMM
ALLEN|Y
WARD|Y
MARTIN|Y
BLAKE|(null)
TURNER|(null)
JAMES|(null)

6 rows selected.

== [Q4] 단순 CASE 로는 NULL 을 찾지 못한다 (CASE comm WHEN NULL ... 은 comm = NULL 비교)

ENAME|COMM|SIMPLE_NULL|SEARCHED_NULL
ALLEN|300|not matched|value
BLAKE|(null)|not matched|NULL!

2 rows selected.

== [Q5] DECODE 는 NULL 과 NULL 을 같다고 본다 (CASE 와 다른 점)

ENAME|COMM|DECODE_NULL
ALLEN|300|value
BLAKE|(null)|NULL!

2 rows selected.

== [Q6] DECODE(값, 비교1, 결과1, 비교2, 결과2, 기본값)

ENAME|JOB_CODE
ALLEN|S
WARD|S
MARTIN|S
BLAKE|X
TURNER|S
JAMES|C

6 rows selected.

== [Q7] CASE 결과의 자료형은 통일되어야 한다 -> 오류
SELECT CASE WHEN sal > 1000 THEN 'big' ELSE 0 END FROM emp
                                            *
ERROR at line 1:
ORA-00932: inconsistent datatypes: expected CHAR got NUMBER
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_case_decode_sqlserver.sql -->
```text
== [Q1] 단순 CASE 와 검색 CASE
ename|deptno|simple_case|searched_case
-----|------|-----------|-------------
SMITH|20|RES|LOW
ALLEN|30|ETC|MID
KING|10|ACC|HIGH
FORD|20|RES|HIGH

(4 rows affected)
== [Q2] 첫 번째 참인 WHEN
ename|sal|wrong_order
-----|---|-----------
SMITH|800.00|NULL
KING|5000.00|1000+

(2 rows affected)
== [Q3] ELSE 생략
ename|has_comm
-----|--------
ALLEN|Y
WARD|Y
MARTIN|Y
BLAKE|NULL
TURNER|NULL
JAMES|NULL

(6 rows affected)
== [Q4] 단순 CASE 와 NULL
ename|comm|simple_null|searched_null
-----|----|-----------|-------------
ALLEN|300.00|not matched|value
BLAKE|NULL|not matched|NULL!

(2 rows affected)
== [Q6] IIF(조건, 참, 거짓) / CHOOSE(인덱스, 값1, 값2, ...)
ename|job_code|dname_choose
-----|--------|------------
ALLEN|S|SAL
WARD|S|SAL
MARTIN|S|SAL
BLAKE|X|SAL
TURNER|S|SAL
JAMES|C|SAL

(6 rows affected)
== [Q7] CASE 결과 자료형 불일치 -> 문자를 INT 로 바꾸다 실패

-
0
Msg 245, Level 16, State 1, Server a70f428a7f8a, Line 2
Conversion failed when converting the varchar value 'big' to data type int.
== [Q5] DECODE 는 없는 함수
Msg 195, Level 15, State 10, Server a70f428a7f8a, Line 2
'DECODE' is not a recognized built-in function name.
```
<!-- /RESULT -->

**이유**
* Q2: 5000은 첫 WHEN(>= 1000)에서 참이므로 '1000+'로 끝난다. 범위 조건은 큰 값부터 쓴다. SMITH(800)는 ELSE가 없어 NULL이다.
* Q4: 단순 CASE는 `comm = NULL` 비교라 UNKNOWN이고 ELSE로 간다. 검색 CASE의 `IS NULL`만 찾는다.
* Q5: DECODE는 NULL을 찾는다. **CASE와 결과가 다르다.**
* Q7: 'big'과 0을 섞으면 Oracle은 ORA-00932(컴파일 단계), SQL Server는 INT 우선순위 때문에 'big'을 INT로 바꾸다 Msg 245(실행 단계)가 난다. SQL Server는 실패 전에 첫 행(0)을 이미 출력했다.
* SQL Server CHOOSE(deptno/10, …): 30/10 = 3 → 'SAL'.

## F. 변형 문제
1. 급여 등급을 CASE로 만들어라: 3000 이상 'A', 2000 이상 'B', 1000 이상 'C', 나머지 'D'.
2. 부서별로 직무가 CLERK인 사원 수와 SALESMAN인 사원 수를 한 행에 구하라(CASE + SUM, 피벗 기초 → 10단원 ex05).
3. DECODE(deptno, 10, 'A', 20, 'B')에서 30번 부서의 결과는?

G: [../exercises/ex06_case_decode.md](../exercises/ex06_case_decode.md)
