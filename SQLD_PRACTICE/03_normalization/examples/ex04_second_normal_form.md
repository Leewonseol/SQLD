# ex04 제2정규형 (2NF)과 무손실 분해

> 근거: 요구목록 §6(2NF, 정규화 전후 테이블 비교, 무손실 분해와 JOIN 복원) · 데이터: N03_ENROLL → 학생·과목·수강 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 2NF: 1NF이면서 **부분 함수 종속이 없다**. 복합 키의 일부에만 종속된 속성을 그 부분 키를 PK로 하는 테이블로 옮긴다.
  * 학번 → 학생명·학과·학과장 ⇒ 학생(학번 PK) / 과목코드 → 과목명 ⇒ 과목(과목코드 PK) / (학번, 과목코드) → 성적 ⇒ 수강
* **무손실 분해**: 나눈 테이블을 공통 속성(FK)으로 다시 JOIN 하면 원래 테이블과 **정확히** 같아야 한다. 양방향 차집합이 0행이면 검증된다.
* 학생 테이블에는 아직 학번 → 학과 → 학과장(이행 종속)이 남아 있다 → 3NF(ex05).

## B. 입력 데이터
N03_ENROLL → 학생·과목·수강

## C. 실행 SQL
[Oracle](ex04_second_normal_form_oracle.sql) · [SQL Server](ex04_second_normal_form_sqlserver.sql)

## D. 결과 예측 문제
1. 분해 후 학생·과목·수강 테이블의 행 수는?
2. 무손실 검증 diff_rows는?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex04_second_normal_form_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

== [Q1] 분해: 학번에만 종속된 속성 -> 학생, 과목코드에만 종속 -> 과목, 키 전체에 종속 -> 수강

Table created.

Table created.

Table created.

Table altered.

Table altered.

Table altered.

Table altered.

Table altered.

STUDENTS|COURSES|ENROLLS
3|3|5

1 row selected.

== [Q2] 무손실 분해 검증: 분해한 테이블을 JOIN 하면 원래 테이블과 정확히 같은가 (양방향 차집합 0)

DIFF_ROWS
0

1 row selected.

== [Q3] 이상 현상 해소: 수강생 없는 새 과목을 등록할 수 있다

1 row created.

COURSES_NOW
4

1 row selected.

Rollback complete.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex04_second_normal_form_sqlserver.sql -->
```text
== [Q1] 분해

(3 rows affected)

(3 rows affected)

(5 rows affected)
students|courses|enrolls
--------|-------|-------
3|3|5

(1 rows affected)
== [Q2] 무손실 분해 검증
diff_rows
---------
0

(1 rows affected)
== [Q3] 새 과목 등록 가능

(1 rows affected)
courses_now
-----------
4

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 학생 3, 과목 3, 수강 5. 중복 저장이 사라졌다.
* Q2: 0 → 무손실.
* Q3: 수강생 없는 C4를 과목 테이블에 등록할 수 있다(삽입 이상 해소).

## F. 변형 문제
1. 분해 전과 후에 '학생 S1의 과목명 목록' 쿼리를 각각 작성해 비교하라.
2. 학생 테이블의 학과장 갱신 이상은 해결되었는가?

G: [../exercises/ex04_second_normal_form.md](../exercises/ex04_second_normal_form.md)
