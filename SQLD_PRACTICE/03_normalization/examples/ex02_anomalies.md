# ex02 이상 현상 (삽입·갱신·삭제)

> 근거: 요구목록 §6(삽입·수정·삭제 이상현상). 추출본 본문 없음 · 데이터: N03_ENROLL (정규화 전) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **삽입 이상**: 원하지 않는 정보까지 있어야 입력할 수 있다(수강생 없이 과목을 등록 못 함).
* **갱신 이상**: 같은 사실이 여러 행에 중복되어 일부만 바뀌면 모순이 생긴다(학과장 2명).
* **삭제 이상**: 한 행을 지우면 함께 저장된 다른 사실까지 사라진다(마지막 수강 기록과 함께 과목 정보가 사라짐).
* 원인은 하나다. **서로 다른 결정자에 종속된 속성을 한 테이블에 모아 둔 것**이다.

## B. 입력 데이터
N03_ENROLL (정규화 전)

## C. 실행 SQL
[Oracle](ex02_anomalies_oracle.sql) · [SQL Server](ex02_anomalies_sqlserver.sql)

## D. 결과 예측 문제
1. Q1의 INSERT는 왜 실패하는가?
2. Q2 뒤 DB 학과의 학과장 수는?
3. Q4에서 dept_head는 몇 번 저장되어 있는가? 실제 사실은 몇 개인가?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex02_anomalies_oracle.sql -->
```text
== [Q1] 삽입 이상: 수강생이 없는 새 과목 C4(데이터베이스) 를 등록할 수 없다 (PK 일부인 stu_no 에 NULL 불가)
INSERT INTO n03_enroll (stu_no, course_cd, course_nm) VALUES (NULL, 'C4', '데이터베이스')
                                                              *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SQLD_LAB"."N03_ENROLL"."STU_NO")

== [Q2] 갱신 이상: DB 학과장을 바꾸면서 일부 행만 바꾸면 같은 학과에 학과장이 둘이 된다

2 rows updated.

DEPT|HEADS|HEAD_VALUES
AI|1|정교수
DB|2|박교수,한교수

2 rows selected.

Rollback complete.

== [Q3] 삭제 이상: S3 의 C3 수강 기록을 지우면 '통계' 과목의 존재 자체가 사라진다

1 row deleted.

C3_ROWS_LEFT
0

1 row selected.

Rollback complete.

== [Q4] 중복 저장량: 같은 사실(학과장, 과목명)이 몇 번 반복 저장되는가

WHAT|STORED|DISTINCT_FACTS
dept_head 저장 횟수|5|2
course_nm 저장 횟수|5|3

2 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_anomalies_sqlserver.sql -->
```text
== [Q1] 삽입 이상
Msg 515, Level 16, State 2, Server a70f428a7f8a, Line 2
Cannot insert the value NULL into column 'stu_no', table 'SQLD_LAB.dbo.n03_enroll'; column does not allow nulls. INSERT fails.
The statement has been terminated.
== [Q2] 갱신 이상

(2 rows affected)
dept|heads|head_values
----|-----|-----------
AI|1|정교수
DB|2|박교수,한교수

(2 rows affected)
== [Q3] 삭제 이상

(1 rows affected)
c3_rows_left
------------
0

(1 rows affected)
== [Q4] 중복 저장량
what|stored|distinct_facts
----|------|--------------
dept_head 저장 횟수|5|2
course_nm 저장 횟수|5|3

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: PK(stu_no, course_cd)의 stu_no가 NULL이라 거부된다(ORA-01400 / Msg 515) → 삽입 이상.
* Q2: S1 행만 '한교수'로 바뀌어 DB 학과에 학과장이 2명이 된다 → 갱신 이상.
* Q3: C3 행이 하나뿐이라 지우면 '통계' 과목 정보가 0행이 된다 → 삭제 이상.
* Q4: 학과장은 5번 저장되었지만 사실은 2개, 과목명도 5번 저장되었지만 사실은 3개다.

## F. 변형 문제
1. ex04(2NF)·ex05(3NF) 분해 뒤에 Q1~Q3이 각각 해결되는지 확인하라.
2. 이상 현상을 줄이는 대신 무엇이 늘어나는가? (조인)

G: [../exercises/ex02_anomalies.md](../exercises/ex02_anomalies.md)
