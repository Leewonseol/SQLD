# ex05 제약조건 PK · FK · UNIQUE · CHECK · NOT NULL

> 근거: 요구목록 §7(PK·FK·CHECK·UNIQUE·NOT NULL), PDF추출본 E-03(자기참조 FK '멘토') · 데이터: D13_DEPT·D13_EMP(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 제약 | 의미 | NULL |
|---|---|---|
| PRIMARY KEY | 유일 + NOT NULL, 테이블당 하나 | 불가 |
| UNIQUE | 유일(대체키) | Oracle: 여러 NULL 허용 / SQL Server: **NULL 1개만** |
| NOT NULL | 값 필수 | 불가 |
| CHECK | 조건식이 FALSE가 아니어야 함 | 조건이 UNKNOWN이면 **통과** |
| FOREIGN KEY | 부모 PK/UNIQUE에 있는 값만(또는 NULL) | 허용(선택 참여) |
* FK 참조 동작: 기본(NO ACTION/RESTRICT) = 자식이 있으면 부모 삭제 거부, `ON DELETE CASCADE` = 자식도 삭제, `ON DELETE SET NULL` = 자식 FK를 NULL로. SQL Server만 `ON UPDATE CASCADE`를 지원한다.

## B. 입력 데이터
D13_DEPT·D13_EMP(학습용 가상 데이터). 실행 전후 데이터 변화는 E의 출력(SELECT 결과와 'n rows …' 메시지)으로 비교한다.

## C. 실행 SQL
[Oracle](ex05_constraints_oracle.sql) · [SQL Server](ex05_constraints_sqlserver.sql)

## D. 결과 예측 문제
1. email이 NULL인 행을 두 개 넣으면?
2. sal이 NULL이면 CHECK(sal > 0)을 통과하는가?
3. Q4에서 10번 부서를 지우면 사원 행은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_constraints_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

Table created.

1 row created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [Q1] UNIQUE 는 NULL 을 여러 개 허용한다 (Oracle) -> 성공

1 row created.

NULL_EMAIL_ROWS
2

1 row selected.

== [Q2] CHECK 는 NULL 이면 통과 (조건이 UNKNOWN 이면 위반이 아니다)

1 row created.

EMPNO|SAL
4|(null)

1 row selected.

== [Q3] 위반 사례: CHECK / UNIQUE / PK / NOT NULL / FK(없는 부모) / 자기참조 FK(없는 멘토)
INSERT INTO d13_emp VALUES (5, 'x', 'x@x', -1, 10, NULL)
*
ERROR at line 1:
ORA-02290: check constraint (SQLD_LAB.CK_D13_EMP_SAL) violated

INSERT INTO d13_emp VALUES (6, 'y', 'k@x', 10, 10, NULL)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.UQ_D13_EMP_EMAIL) violated

INSERT INTO d13_emp VALUES (1, 'z', 'z@x', 10, 10, NULL)
*
ERROR at line 1:
ORA-00001: unique constraint (SQLD_LAB.PK_D13_EMP) violated

INSERT INTO d13_emp VALUES (7, NULL, 'n@x', 10, 10, NULL)
                               *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."D13_EMP"."ENAME")

INSERT INTO d13_emp VALUES (8, 'w', 'w@x', 10, 99, NULL)
*
ERROR at line 1:
ORA-02291: integrity constraint (SQLD_LAB.FK_D13_EMP_DEPT) violated - parent key not found

INSERT INTO d13_emp VALUES (9, 'v', 'v@x', 10, 10, 77)
*
ERROR at line 1:
ORA-02291: integrity constraint (SQLD_LAB.FK_D13_EMP_MENTOR) violated - parent key not found

== [Q4] ON DELETE SET NULL: 부모(10번) 삭제 -> 자식의 deptno 가 NULL

1 row deleted.

EMPNO|DEPTNO
1|(null)
2|20
3|(null)
4|(null)

4 rows selected.

Rollback complete.

== [Q5] 자식이 참조 중인 자기참조 행(멘토 1) 삭제 -> 오류 (기본 옵션 = NO ACTION)
DELETE FROM d13_emp WHERE empno = 1
*
ERROR at line 1:
ORA-02292: integrity constraint (SQLD_LAB.FK_D13_EMP_MENTOR) violated - child record found

== [Q6] Oracle 은 ON UPDATE CASCADE 를 지원하지 않는다 -> 오류
CREATE TABLE d13_bad (id NUMBER REFERENCES d13_dept(deptno) ON UPDATE CASCADE)
                                                               *
ERROR at line 1:
ORA-00905: missing keyword

== [Q7] 제약조건 목록 (데이터 사전)

CONSTRAINT_NAME|CONSTRAINT_TYPE|SEARCH_CONDITION_VC
CK_D13_EMP_SAL|C|sal > 0
FK_D13_EMP_DEPT|R|(null)
FK_D13_EMP_MENTOR|R|(null)
NN_D13_EMP_ENAME|C|"ENAME" IS NOT NULL
PK_D13_EMP|P|(null)
UQ_D13_EMP_EMAIL|U|(null)

6 rows selected.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_constraints_sqlserver.sql -->
```text
(2 rows affected)

(2 rows affected)
== [Q1] UNIQUE 컬럼의 두 번째 NULL -> SQL Server 는 오류 (NULL 도 하나의 값처럼 취급)
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 2
Violation of UNIQUE KEY constraint 'uq_d13_emp_email'. Cannot insert duplicate key in object 'dbo.d13_emp'. The duplicate key value is (<NULL>).
The statement has been terminated.
null_email_rows
---------------
1

(1 rows affected)
== [Q1b] 여러 NULL 을 허용하려면 필터링된 UNIQUE 인덱스

(1 rows affected)
null_email_rows
---------------
2

(1 rows affected)
== [Q2] CHECK 는 NULL 이면 통과

(1 rows affected)
empno|sal
-----|---
4|NULL

(1 rows affected)
== [Q3] 위반 사례 (SQL Server 는 FK 위반도 CHECK 와 같은 Msg 547)
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 2
The INSERT statement conflicted with the CHECK constraint "ck_d13_emp_sal". The conflict occurred in database "SQLD_LAB", table "dbo.d13_emp", column 'sal'.
The statement has been terminated.
Msg 2601, Level 14, State 1, Server a70f428a7f8a, Line 1
Cannot insert duplicate key row in object 'dbo.d13_emp' with unique index 'ux_d13_emp_email'. The duplicate key value is (k@x).
The statement has been terminated.
Msg 2627, Level 14, State 1, Server a70f428a7f8a, Line 1
Violation of PRIMARY KEY constraint 'pk_d13_emp'. Cannot insert duplicate key in object 'dbo.d13_emp'. The duplicate key value is (1).
The statement has been terminated.
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 1
Cannot insert the value NULL into column 'ename', table 'SQLD_LAB.dbo.d13_emp'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the FOREIGN KEY constraint "fk_d13_emp_dept". The conflict occurred in database "SQLD_LAB", table "dbo.d13_dept", column 'deptno'.
The statement has been terminated.
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 1
The INSERT statement conflicted with the FOREIGN KEY SAME TABLE constraint "fk_d13_emp_mentor". The conflict occurred in database "SQLD_LAB", table "dbo.d13_emp", column 'empno'.
The statement has been terminated.
== [Q4] ON DELETE SET NULL

(1 rows affected)
empno|deptno
-----|------
1|NULL
2|20
3|NULL
4|NULL

(4 rows affected)
== [Q4b] ON UPDATE CASCADE: 부모 키 20 -> 21 이면 자식도 21

(1 rows affected)
empno|deptno
-----|------
2|21

(1 rows affected)
== [Q5] 참조 중인 자기참조 행 삭제 -> 오류
Msg 547, Level 16, State 1, Server a70f428a7f8a, Line 2
The DELETE statement conflicted with the SAME TABLE REFERENCE constraint "fk_d13_emp_mentor". The conflict occurred in database "SQLD_LAB", table "dbo.d13_emp", column 'mentor'.
The statement has been terminated.
== [Q7] 제약조건 목록
name|type_desc
----|---------
ck_d13_emp_sal|CHECK_CONSTRAINT
fk_d13_emp_dept|FOREIGN_KEY_CONSTRAINT
fk_d13_emp_mentor|FOREIGN_KEY_CONSTRAINT
pk_d13_emp|PRIMARY_KEY_CONSTRAINT

(4 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: Oracle은 NULL email 2행 성공. SQL Server는 두 번째 NULL에서 Msg 2627이다. 여러 NULL을 허용하려면 `WHERE email IS NOT NULL` 필터링된 UNIQUE 인덱스를 쓴다(Q1b). **결과가 다르다.**
* Q2: CHECK는 UNKNOWN을 통과시킨다. 값을 강제하려면 NOT NULL을 함께 둔다.
* Q3: 위반 코드 비교(단원 안내 표). SQL Server는 CHECK와 FK가 모두 Msg 547이고, 필터 인덱스로 바꾼 뒤의 UNIQUE 위반은 Msg 2601이다.
* Q4: ON DELETE SET NULL → 10번 사원의 deptno가 NULL. SQL Server Q4b: ON UPDATE CASCADE → 부모 키 변경이 자식에 전파된다. Oracle은 ON UPDATE를 지원하지 않는다(Q6, ORA-00905).
* Q5: 멘토로 참조 중인 행 삭제 → ORA-02292 / Msg 547.

## F. 변형 문제
1. FK 컬럼에 NOT NULL을 추가하면 관계의 선택성은 어떻게 바뀌는가? (01단원 ex02 필수 참여)
2. 'mentor는 자기 자신일 수 없다'를 CHECK로 구현하라. '멘토의 멘토가 자기 자신일 수 없다'는 CHECK로 가능한가? (01단원 ex06)

G: [../exercises/ex05_constraints.md](../exercises/ex05_constraints.md)
