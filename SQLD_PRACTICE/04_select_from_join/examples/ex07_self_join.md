# ex07 SELF JOIN (자기 자신과의 조인)

> 근거: PDF추출본 E-02(직원·상사), E-03(자기참조 FK), E-12(EMPLOYEES) · 데이터: **PDF 원문 값**(STAFF의 박현석 ID=5는 추출본에서 누락되어 순번으로 보충) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을 하는가**: 한 테이블 안의 계층 관계(사원–관리자, 멘티–멘토)를 따라가려고 같은 테이블을 FROM에 두 번 쓴다. 두 사본을 구별하려면 **별칭이 필수**다.
* **언제 쓰는가**: 자기참조 FK(E-03 "FK는 자기 자신이 속한 릴레이션을 참조할 수 있다")가 있는 테이블에서 "상사 이름"처럼 한 단계 위의 값을 가져올 때. 여러 단계를 따라가려면 계층형 질의를 쓴다(12단원).
* **차이**: 조인 조건의 **방향**이 결과의 의미를 정한다. `사원.mgr_id = 관리자.emp_id`에서는 왼쪽이 부하, 오른쪽이 상사다. 반대로 쓰면 열의 의미가 뒤바뀐다.

## B. 입력 데이터 (PDF)
* EMPLOYEES(emp_id PK, name, mgr_id FK→EMPLOYEES): 100 KING NULL, 101 ALLEN 100, 102 WARD 100, 103 JONES 102, 104 MARTIN 101, 105 SMITH 103
* STAFF(staff_id PK, name, boss_id FK→STAFF): 1 나사장 NULL, 2 김철수 1, 3 이지현 1, 4 황수지 2, 5 박현석 3

## C. 실행 SQL
[Oracle](ex07_self_join_oracle.sql) · [SQL Server](ex07_self_join_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(PDF 원문 조건 `E1.EMP_ID = E2.EMP_ID`)은 몇 행이고, E2_NAME은 무엇인가?
2. Q2는 몇 행인가? 빠지는 사람은?
3. Q4(PDF 원문 쿼리)의 "직원이름" 열에는 누가 나오는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex07_self_join_oracle.sql -->
```text
== [Q1] PDF E-12 쿼리 원문 그대로: WHERE E1.EMP_ID = E2.EMP_ID (자기 자신과 조인됨)

EMP_ID|NAME|MGR_ID|E2_EMP_ID|E2_NAME
100|KING|(null)|100|KING
101|ALLEN|100|101|ALLEN
102|WARD|100|102|WARD
103|JONES|102|103|JONES
104|MARTIN|101|104|MARTIN
105|SMITH|103|105|SMITH

6 rows selected.

== [Q2] PDF 결과표를 만드는 조건: 사원(E1)의 MGR_ID = 관리자(E2)의 EMP_ID

EMP_ID|NAME|MGR_ID|MGR_EMP_ID|MGR_NAME
101|ALLEN|100|100|KING
102|WARD|100|100|KING
103|JONES|102|102|WARD
104|MARTIN|101|101|ALLEN
105|SMITH|103|103|JONES

5 rows selected.

== [Q3] 관리자가 없는 KING 도 출력: OUTER JOIN

EMP_ID|NAME|MGR_NAME
100|KING|(null)
101|ALLEN|KING
102|WARD|KING
103|JONES|WARD
104|MARTIN|ALLEN
105|SMITH|JONES

6 rows selected.

== [Q4] PDF E-02 쿼리 원문 그대로: a.직원ID = b.상사ID, a.이름 AS 직원이름, b.이름 AS 상사

직원이름|상사
나사장|김철수
나사장|이지현
김철수|황수지
이지현|박현석

4 rows selected.

== [Q5] PDF E-02 결과표(나사장-NULL 포함 5행)를 만드는 쿼리

직원이름|상사
나사장|(null)
김철수|나사장
이지현|나사장
황수지|김철수
박현석|이지현

5 rows selected.

== [Q6] 같은 테이블을 두 번 쓰면서 별칭을 생략 -> 오류
SELECT name FROM staff, staff
       *
ERROR at line 1:
ORA-00918: column ambiguously defined
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex07_self_join_sqlserver.sql -->
```text
== [Q1] PDF E-12 쿼리 원문 그대로
emp_id|name|mgr_id|e2_emp_id|e2_name
------|----|------|---------|-------
100|KING|NULL|100|KING
101|ALLEN|100|101|ALLEN
102|WARD|100|102|WARD
103|JONES|102|103|JONES
104|MARTIN|101|104|MARTIN
105|SMITH|103|105|SMITH

(6 rows affected)
== [Q2] e1.mgr_id = e2.emp_id
emp_id|name|mgr_id|mgr_emp_id|mgr_name
------|----|------|----------|--------
101|ALLEN|100|100|KING
102|WARD|100|100|KING
103|JONES|102|102|WARD
104|MARTIN|101|101|ALLEN
105|SMITH|103|103|JONES

(5 rows affected)
== [Q3] OUTER JOIN
emp_id|name|mgr_name
------|----|--------
100|KING|NULL
101|ALLEN|KING
102|WARD|KING
103|JONES|WARD
104|MARTIN|ALLEN
105|SMITH|JONES

(6 rows affected)
== [Q4] PDF E-02 쿼리 원문 그대로
직원이름|상사
----|--
나사장|김철수
나사장|이지현
김철수|황수지
이지현|박현석

(4 rows affected)
== [Q5] PDF E-02 결과표를 만드는 쿼리
직원이름|상사
----|--
나사장|NULL
김철수|나사장
이지현|나사장
황수지|김철수
박현석|이지현

(5 rows affected)
== [Q6] 별칭 없이 같은 테이블 두 번 -> 오류
Msg 1013, Level 16, State 1, Server a70f428a7f8a, Line 2
The objects "staff" and "staff" in the FROM clause have the same exposed names. Use correlation names to distinguish them.
```
<!-- /RESULT -->

**이유와 외부검증**
* Q1: `e1.emp_id = e2.emp_id`는 각 행을 **자기 자신**과 짝짓는다 → 6행, E2_NAME = 자기 이름. PDF E-12 결과표(ALLEN–KING, WARD–KING, JONES–WARD, MARTIN–ALLEN, SMITH–JONES 5행)는 Q2 조건 `e1.mgr_id = e2.emp_id`로 실행해야 나온다. **PDF 쿼리의 조인 조건이 오기다.**
* Q2: KING은 mgr_id가 NULL이라 짝이 없다 → 5행. PDF의 "MANAGER_ID NULL인 KING은 조건에 맞지 않으니 제외됨"과 일치한다.
* Q3: LEFT OUTER JOIN이라 KING이 mgr_name NULL로 남는다 → 6행.
* Q4: PDF E-02 원문 `WHERE a.직원ID = b.상사ID`에서 a는 "누군가의 상사"가 된다. 그래서 "직원이름" 열에 상사(나사장·김철수·이지현)가, "상사" 열에 부하가 나온다. 4행이다. PDF 결과표(나사장–NULL, 김철수–나사장 …)와 **다르다.**
* Q5: PDF 결과표는 `a.boss_id = b.staff_id` + LEFT JOIN으로 만든 이 결과와 같다.
* Q6: 같은 테이블을 별칭 없이 두 번 쓰면 Oracle은 열 참조에서 ORA-00918, SQL Server는 FROM 단계에서 Msg 1013이 난다.

## F. 변형 문제
1. 상사의 상사(2단계 위) 이름까지 출력하려면 STAFF를 몇 번 조인해야 하는가?
2. 부하가 없는 직원(리프)만 출력하라. (NOT EXISTS 또는 LEFT JOIN … IS NULL)
3. 각 상사별 부하 수를 구하라. 부하가 0명인 직원도 포함하라.

G: [exercises/ex07_self_join.md](../exercises/ex07_self_join.md)
