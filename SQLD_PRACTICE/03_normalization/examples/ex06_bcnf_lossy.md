# ex06 BCNF와 손실 분해(가짜 행)

> 근거: 요구목록 §6("1NF·2NF·3NF·BCNF 등", 무손실 분해와 JOIN 복원) · 데이터: N03_LECTURE(학생, 과목, 교수) 3행 — 학습용 가상 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **BCNF**: 모든 결정자가 후보키다. 3NF는 '키가 아닌 속성'의 종속만 보지만, BCNF는 주식별자 속성끼리의 종속도 본다.
* 예: (학생, 과목) → 교수, 교수 → 과목. 후보키는 (학생, 과목)과 (학생, 교수)다. 모든 속성이 어떤 후보키의 일부라 3NF는 만족한다. 그러나 결정자 '교수'가 후보키가 아니므로 BCNF를 위반한다.
* **분해 방법이 중요하다.** 공통 속성이 한쪽의 키(결정자)가 되도록 나눠야 무손실이다. (교수, 과목) + (학생, 교수)는 교수가 (교수, 과목)의 키라 무손실이다. (학생, 과목) + (과목, 교수)는 과목이 어느 쪽의 키도 아니라 **가짜 행**이 생긴다.
* 대가(종속성 보존 손실): BCNF 분해 뒤에는 '(학생, 과목) → 교수'를 PK/UNIQUE로 강제할 수 없다.

## B. 입력 데이터
N03_LECTURE(학생, 과목, 교수) 3행 — 학습용 가상

## C. 실행 SQL
[Oracle](ex06_bcnf_lossy_oracle.sql) · [SQL Server](ex06_bcnf_lossy_sqlserver.sql)

## D. 결과 예측 문제
1. Q2(잘못된 분해)를 다시 조인하면 몇 행인가? 원래는 3행이다.
2. Q3(BCNF 분해)는?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex06_bcnf_lossy_oracle.sql -->
```text
PL/SQL procedure successfully completed.

Table created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [Q1] 함수 종속 확인: prof -> course 는 성립(위반 0), course -> prof 는 불성립(SQL 에 교수 둘)

PROF_TO_COURSE_VIOL|COURSE_TO_PROF_VIOL
0|1

1 row selected.

== [Q2] 잘못된 분해 (학생, 과목) + (과목, 교수) 를 과목으로 다시 조인 -> 원래 3행보다 많은 가짜 행 (손실 분해)

STUDENT|COURSE|PROF
s1|DB|P3
s1|SQL|P1
s1|SQL|P2
s2|SQL|P1
s2|SQL|P2

5 rows selected.

== [Q3] BCNF 분해 (교수, 과목) + (학생, 교수) 를 교수로 조인 -> 원래 3행 그대로 (무손실)

STUDENT|COURSE|PROF
s1|DB|P3
s1|SQL|P1
s2|SQL|P2

3 rows selected.

== [Q4] 대가: BCNF 분해 후에는 '(학생, 과목) -> 교수'(학생은 과목당 교수 1명)를 한 테이블의 PK/UNIQUE 로 강제할 수 없다
(과목이 다른 테이블에 있어서) -> 종속성 보존 손실. 트리거 등이 필요하다 (설계 설명, 실행 대상 아님)

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex06_bcnf_lossy_sqlserver.sql -->
```text
(3 rows affected)
== [Q1] 함수 종속 확인
prof_to_course_viol|course_to_prof_viol
-------------------|-------------------
0|1

(1 rows affected)
== [Q2] 잘못된 분해 -> 가짜 행
student|course|prof
-------|------|----
s1|DB|P3
s1|SQL|P1
s1|SQL|P2
s2|SQL|P1
s2|SQL|P2

(5 rows affected)
== [Q3] BCNF 분해 -> 무손실
student|course|prof
-------|------|----
s1|DB|P3
s1|SQL|P1
s2|SQL|P2

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: 교수 → 과목은 성립(위반 0), 과목 → 교수는 불성립(SQL에 P1·P2).
* Q2: 5행. s1–SQL–P2, s2–SQL–P1 두 개가 **가짜 행**이다. 정보가 늘어난 것처럼 보이지만 사실은 정보를 잃은 것이다(누가 누구에게 배우는지 알 수 없다).
* Q3: 3행으로 원래와 같다.

## F. 변형 문제
1. s3가 SQL을 P1에게 듣는 행을 추가하면 Q2·Q3은 각각 몇 행인가?
2. 정규화 이론에서 '무손실 분해'의 판정 규칙(공통 속성이 한쪽 릴레이션의 키)을 이 예로 설명하라.

G: [../exercises/ex06_bcnf_lossy.md](../exercises/ex06_bcnf_lossy.md)
