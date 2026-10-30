# ex10 뷰(VIEW)

> 근거: **추출본에서 확인되지 않은 항목**. PDF E-21이 인라인 뷰를 '동적 뷰'라 부르므로 대비 개념으로 작성했다. PDF 원문 확인 필요 · 데이터: EMP · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 뷰는 SELECT 문을 이름으로 저장한 **가상 테이블**이다. 데이터는 저장하지 않는다. 조회할 때마다 기본 테이블에서 읽는다.
* 장점: 독립성(테이블 구조 변경을 숨김), 편의성(복잡한 쿼리를 이름으로), 보안(필요한 컬럼·행만 노출).
* `WITH CHECK OPTION`: 뷰 조건을 벗어나는 INSERT/UPDATE를 막는다. `WITH READ ONLY`(Oracle 전용): 뷰를 통한 DML을 금지한다.
* SQL Server: CREATE VIEW는 배치의 첫 문장이어야 한다. WITH READ ONLY가 없다(권한으로 제어한다).

## B. 입력 데이터
EMP (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex10_view_oracle.sql) · [SQL Server](ex10_view_sqlserver.sql)

## D. 결과 예측 문제
1. Q2에서 EMP를 바꾼 직후 뷰를 조회하면 바뀐 값이 보이는가?
2. Q3 CHECK OPTION 뷰로 deptno를 30으로 바꾸면?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex10_view_oracle.sql -->
```text
== [Q1] 뷰 생성: 실제 데이터는 저장하지 않고 정의(쿼리)만 저장한다

View created.

EMPNO|ENAME|SAL|DEPTNO
7369|SMITH|800|20
7566|JONES|2975|20
7788|SCOTT|3000|20
7876|ADAMS|1100|20
7902|FORD|3000|20

5 rows selected.

== [Q2] 기본 테이블이 바뀌면 뷰 결과도 바로 바뀐다 (실험 후 ROLLBACK)

1 row updated.

ENAME|SAL
SMITH|801

1 row selected.

Rollback complete.

== [Q3] WITH CHECK OPTION: 뷰 조건(deptno = 20)을 벗어나게 만드는 변경을 막는다

View created.

UPDATE v_emp20_chk SET deptno = 30 WHERE empno = 7369
       *
ERROR at line 1:
ORA-01402: view WITH CHECK OPTION where-clause violation

== [Q4] WITH READ ONLY (Oracle): 뷰를 통한 DML 금지

View created.

UPDATE v_emp20_ro SET ename = 'X' WHERE empno = 7369
                      *
ERROR at line 1:
ORA-42399: cannot perform a DML operation on a read-only view

== [Q5] 정리

View dropped.

View dropped.

View dropped.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex10_view_sqlserver.sql -->
```text
== [Q1] 뷰 생성
empno|ename|sal|deptno
-----|-----|---|------
7369|SMITH|800.00|20
7566|JONES|2975.00|20
7788|SCOTT|3000.00|20
7876|ADAMS|1100.00|20
7902|FORD|3000.00|20

(5 rows affected)
== [Q2] 기본 테이블 변경이 뷰에 바로 반영

(1 rows affected)
ename|sal
-----|---
SMITH|801.00

(1 rows affected)
== [Q3] WITH CHECK OPTION
Msg 550, Level 16, State 1, Server a70f428a7f8a, Line 2
The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
The statement has been terminated.
== [Q5] 정리
```
<!-- /RESULT -->

**이유**
* Q2: 801로 보인다. 뷰는 데이터를 복사하지 않는다(ROLLBACK으로 원복).
* Q3: ORA-01402 / Msg 550. Q4(Oracle): ORA-42399(21c에서 확인. 19c 미실행).

## F. 변형 문제
1. 20번 부서 사원 이름과 부서명을 보여 주는 조인 뷰를 만들고, 그 뷰로 ename을 바꿀 수 있는지 시험하라(키 보존 테이블 개념).
2. 뷰를 만든 뒤 기본 테이블에서 뷰가 쓰는 컬럼을 삭제하면? (Oracle: 뷰가 INVALID 상태가 된다 — 미실행 과제)

G: [../exercises/ex10_view.md](../exercises/ex10_view.md)
