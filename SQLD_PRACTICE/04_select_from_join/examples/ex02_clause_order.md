# ex02 SELECT 문의 작성 순서와 논리적 처리 순서

> 근거: PDF추출본 E-05 (페이지 미확인) · 데이터: SCOTT EMP(00_common) · 검증: Oracle 21c XE 실행 / SQL Server 2022 실행 / 23ai 계열 일부 실행

## A. 개념 설명
* **무엇을 하는가**: SELECT 문은 6개 절(SELECT·FROM·WHERE·GROUP BY·HAVING·ORDER BY)로 이루어진다. 작성 순서와 처리 순서가 다르다.
* **언제 쓰는가**: 별칭을 어디서 쓸 수 있는지, 집계함수를 어느 절에 둘 수 있는지 판단할 때. 결과를 예측할 때 모두 이 순서를 따른다.
* **다른 개념과 차이**: 논리적 처리 순서는 "결과의 의미"를 정한다. 실제 실행 계획(물리적 순서)과 다르다.

| 단계 | 논리적 처리 | 쓸 수 있는 것 |
|---|---|---|
| 1 | FROM (JOIN·ON) | 테이블, 테이블 별칭 |
| 2 | WHERE | 행 단위 조건. 집계함수 불가, SELECT 별칭 불가 |
| 3 | GROUP BY | 그룹 기준. SELECT 별칭 불가(19c·21c·SQL Server). 23ai는 허용 |
| 4 | HAVING | 그룹 조건. 집계함수 가능 |
| 5 | SELECT | 표현식 계산, 별칭 생성 |
| 6 | ORDER BY | SELECT 별칭 가능 (PDF E-08 "유일하게 […] 별칭 사용 가능") |

## B. 입력 데이터
`EMP`(empno PK, ename, job, mgr FK→EMP, hiredate, sal, comm, deptno FK→DEPT) 14행. 00_common/setup_*.sql.

## C. 실행 SQL
* Oracle: [ex02_clause_order_oracle.sql](ex02_clause_order_oracle.sql)
* SQL Server: [ex02_clause_order_sqlserver.sql](ex02_clause_order_sqlserver.sql)
* 23ai 계열 전용(GROUP BY 별칭): [ex03_select_basics_oracle23ai.sql](ex03_select_basics_oracle23ai.sql)

## D. 결과 예측 문제 (실행 전에 답하라)
1. Q1: 처리 순서대로 계산하라. WHERE를 지난 행은 몇 개인가? 그룹은 몇 개, HAVING을 지난 그룹은 몇 개인가?
2. Q2: `WHERE annual > 30000`은 왜 실패하는가? 어느 단계에서 `annual`이 아직 없는가?
3. Q4: HAVING을 GROUP BY 앞에 쓰면 두 DBMS에서 각각 어떻게 되는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_clause_order_oracle.sql -->
```text
== [Q1] 작성 순서대로 쓴 쿼리: 급여 1000 이상 사원만 남긴 뒤 부서별로 묶고 3명 이상인 부서만

DEPTNO|CNT
30|5
20|4
10|3

3 rows selected.

== [Q2] SELECT 절 별칭을 WHERE 에서 사용 -> 오류 (WHERE 가 SELECT 보다 먼저 처리된다)
SELECT ename, sal * 12 AS annual FROM emp WHERE annual > 30000
                                                *
ERROR at line 1:
ORA-00904: "ANNUAL": invalid identifier

== [Q3] SELECT 절 별칭을 ORDER BY 에서 사용 -> 가능 (ORDER BY 는 SELECT 다음)

ENAME|ANNUAL
KING|60000
FORD|36000
SCOTT|36000
JONES|35700
BLAKE|34200

5 rows selected.

== [Q4] HAVING 을 GROUP BY 앞에 작성 (PDF E-05 "서로 바꿀 수 있으나")

DEPTNO|CNT
20|5
30|6

2 rows selected.

== [Q5] GROUP BY 에 SELECT 별칭 사용 -> 19c/21c 에서는 오류 (23ai 는 허용: ex03_select_basics_oracle23ai.sql)
SELECT deptno AS d, COUNT(*) AS cnt FROM emp GROUP BY d
                                                      *
ERROR at line 1:
ORA-00904: "D": invalid identifier
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_clause_order_sqlserver.sql -->
```text
== [Q1] 작성 순서대로 쓴 쿼리
deptno|cnt
------|---
30|5
20|4
10|3

(3 rows affected)
== [Q2] SELECT 절 별칭을 WHERE 에서 사용 -> 오류
Msg 207, Level 16, State 1, Server a70f428a7f8a, Line 2
Invalid column name 'annual'.
== [Q3] SELECT 절 별칭을 ORDER BY 에서 사용 -> 가능
ename|annual
-----|------
KING|60000.00
FORD|36000.00
SCOTT|36000.00
JONES|35700.00
BLAKE|34200.00

(5 rows affected)
== [Q4] HAVING 을 GROUP BY 앞에 작성 -> SQL Server 는 구문 오류
Msg 156, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near the keyword 'GROUP'.
== [Q5] GROUP BY 에 SELECT 별칭 사용 -> 오류
Msg 207, Level 16, State 1, Server a70f428a7f8a, Line 2
Invalid column name 'd'.
```
<!-- /RESULT -->

**행별 이유 (Q1)**
1. FROM: EMP 14행.
2. WHERE `sal >= 1000`: SMITH(800)와 JAMES(950)가 빠져 12행이 남는다.
3. GROUP BY deptno: 10번 3행, 20번 4행(SMITH 제외), 30번 5행(JAMES 제외).
4. HAVING `COUNT(*) >= 3`: 세 그룹 모두 통과한다.
5. ORDER BY cnt DESC: 30(5) → 20(4) → 10(3).

* Q2: WHERE 단계(2)에는 SELECT 단계(5)에서 만드는 별칭 `annual`이 아직 없다. Oracle ORA-00904, SQL Server Msg 207.
* Q3: ORDER BY(6)는 SELECT(5) 다음이라 별칭을 쓸 수 있다. 36000이 FORD·SCOTT 둘이라 두 번째 정렬 키 ename을 두었다. **두 번째 키가 없으면 동점 행의 순서를 단정할 수 없다.**
* Q4: Oracle은 HAVING을 GROUP BY 앞에 써도 실행한다(20번 5명, 30번 6명). SQL Server는 Msg 156 구문 오류. 따라서 PDF E-05의 "서로 바꿀 수 있으나"는 **Oracle에만 해당한다**.
* Q5: GROUP BY에 SELECT 별칭을 쓰면 21c ORA-00904, SQL Server Msg 207이다. 23ai 계열에서는 실행된다(ex03_select_basics_oracle23ai 결과).
* SQL Server는 `sal`이 DECIMAL(7,2)라서 `60000.00`처럼 소수 둘째 자리까지 표시한다. Oracle NUMBER(7,2)는 `60000`으로 표시한다. 값은 같다.

## F. 변형 문제
1. Q1의 WHERE를 `sal >= 1300`으로 바꾸면 HAVING을 통과하는 부서는?
2. Q1의 `HAVING COUNT(*) >= 3`을 WHERE로 옮기면 어떤 오류가 나는가? (05단원 ex06)
3. `ORDER BY 2 DESC`(위치 번호)로 바꾸어도 같은가?
4. Q3에서 `ORDER BY annual`을 `ORDER BY sal*12`로 바꾸면 결과가 같은가?

G(직접 작성): [exercises/ex02_clause_order.md](../exercises/ex02_clause_order.md) · H(정답): [answers/](../answers/)
