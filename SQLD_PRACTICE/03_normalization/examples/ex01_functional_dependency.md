# ex01 함수 종속과 결정자

> 근거: 요구목록 §6(함수 종속과 결정자). 추출본 본문 없음 · 데이터: N03_ENROLL(학번, 학생명, 학과, 학과장, 과목코드, 과목명, 성적) 5행, PK(학번, 과목코드) — 학습용 가상 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **함수 종속 X → Y**: X 값이 같으면 Y 값도 반드시 같다. X를 **결정자**, Y를 **종속자**라 한다.
* **완전 함수 종속**: 키 **전체**에 종속(학번+과목코드 → 성적). **부분 함수 종속**: 키의 **일부**에 종속(학번 → 학생명) → 2NF 위반. **이행 함수 종속**: X → Y → Z(학번 → 학과 → 학과장) → 3NF 위반.
* 함수 종속은 **업무 규칙**이다. SQL로는 현재 데이터가 종속을 '위반하는지'만 확인할 수 있다. `GROUP BY X HAVING COUNT(DISTINCT Y) > 1`이 한 행이라도 나오면 X → Y가 아니다.

## B. 입력 데이터
N03_ENROLL(학번, 학생명, 학과, 학과장, 과목코드, 과목명, 성적) 5행, PK(학번, 과목코드) — 학습용 가상

## C. 실행 SQL
[Oracle](ex01_functional_dependency_oracle.sql) · [SQL Server](ex01_functional_dependency_sqlserver.sql)

## D. 결과 예측 문제
1. Q1의 7개 검사에서 위반이 나오는 것은?
2. stu_no → dept_head는 직접 종속인가 이행 종속인가?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex01_functional_dependency_oracle.sql -->
```text
== [Q1] 함수 종속 검사: 각 X 그룹에서 Y 가 2개 이상이면 위반

FD|VIOLATIONS
stu_no -> stu_name|0
stu_no -> dept|0
dept -> dept_head|0
course_cd -> course_nm|0
(stu_no,course_cd) -> grade|0
dept -> stu_name (종속 아님)|1
course_cd -> grade (종속 아님)|2

7 rows selected.

== [Q2] 종속의 종류 판별 (기본키 = stu_no + course_cd)
완전 함수 종속 : (stu_no, course_cd) -> grade          (키 전체에 종속)
부분 함수 종속 : stu_no -> stu_name, dept / course_cd -> course_nm   (키의 일부에 종속 -> 2NF 위반)
이행 함수 종속 : stu_no -> dept -> dept_head            (키가 아닌 속성을 거쳐 종속 -> 3NF 위반)

ROWS_TOTAL|STUDENTS|COURSES|DEPTS
5|3|3|2

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_functional_dependency_sqlserver.sql -->
```text
== [Q1] 함수 종속 검사: 각 X 그룹에서 Y 가 2개 이상이면 위반
fd|violations
--|----------
stu_no -> stu_name|0
stu_no -> dept|0
dept -> dept_head|0
course_cd -> course_nm|0
(stu_no,course_cd) -> grade|0
dept -> stu_name (종속 아님)|1
course_cd -> grade (종속 아님)|2

(7 rows affected)
== [Q2] 종속의 종류 판별 (기본키 = stu_no + course_cd)
  완전 함수 종속 : (stu_no, course_cd) -> grade          (키 전체에 종속)
  부분 함수 종속 : stu_no -> stu_name, dept / course_cd -> course_nm   (키의 일부에 종속 -> 2NF 위반)
  이행 함수 종속 : stu_no -> dept -> dept_head            (키가 아닌 속성을 거쳐 종속 -> 3NF 위반)
rows_total|students|courses|depts
----------|--------|-------|-----
5|3|3|2

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 업무상 종속인 5개는 위반 0이다. 'dept → stu_name'(DB 학과에 김·이)과 'course_cd → grade'(C1에 A·B, C2에 B·A)는 위반이 있어 종속이 아니다.
* Q2: stu_no → dept, dept → dept_head이므로 stu_no → dept_head는 **이행** 종속이다.

## F. 변형 문제
1. 성적 → 학생명이 성립하는지 SQL로 검사하라.
2. 데이터를 1행 추가해 'dept → dept_head'가 깨지게 만들어 보라. 그 행은 어떤 이상 현상의 결과인가?

G: [../exercises/ex01_functional_dependency.md](../exercises/ex01_functional_dependency.md)
