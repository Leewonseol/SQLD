# ex03 제1정규형 (1NF)

> 근거: 요구목록 §6(1NF). 추출본 본문 없음 · 데이터: N03_HOBBY_RAW(학번, 취미목록) — 학습용 가상 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 1NF: 모든 속성 값이 **원자값**이다. 한 칸에 여러 값(쉼표 목록)이나 반복 컬럼(취미1, 취미2, 취미3)이 없다.
* 다중값 컬럼은 검색·집계·제약이 어렵다. 'SQL' 검색이 'NoSQL'까지 잡고, 취미별 인원을 셀 수 없고, 취미 코드에 FK를 걸 수 없다.
* 해결: (식별자, 값) 행으로 나눈 별도 테이블.

## B. 입력 데이터
N03_HOBBY_RAW(학번, 취미목록) — 학습용 가상

## C. 실행 SQL
[Oracle](ex03_first_normal_form_oracle.sql) · [SQL Server](ex03_first_normal_form_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 `LIKE '%SQL%'`의 결과 학생은?
2. Q3 분해 후 행 수는?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex03_first_normal_form_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

== [Q1] 1NF 위반: 한 칸에 여러 값('SQL,독서')

Table created.

1 row created.

1 row created.

1 row created.

== [Q2] 다중값 컬럼 검색의 함정: 'SQL' 을 LIKE 로 찾으면 'NoSQL' 도 걸린다

STU_NO
S1
S2
S3

3 rows selected.

== [Q3] 1NF 로 분해: (학번, 취미) 한 행에 하나씩. 정규식으로 쉼표 목록을 행으로 펼친다

Table created.

6 rows created.

STU_NO|HOBBY
S1|SQL
S1|독서
S2|NoSQL
S3|SQL
S3|독서
S3|등산

6 rows selected.

== [Q4] 정확한 검색: = 비교

STU_NO
S1
S3

2 rows selected.

Rollback complete.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex03_first_normal_form_sqlserver.sql -->
```text
== [Q1] 1NF 위반 테이블

(3 rows affected)
== [Q2] LIKE 함정
stu_no
------
S1
S2
S3

(3 rows affected)
== [Q3] 1NF 로 분해

(6 rows affected)
stu_no|hobby
------|-----
S1|SQL
S1|독서
S2|NoSQL
S3|SQL
S3|독서
S3|등산

(6 rows affected)
== [Q4] 정확한 검색
stu_no
------
S1
S3

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q2: S1·S3과 'NoSQL'인 S2까지 3명이 나온다(오탐).
* Q3: 6행. 문자열 분리는 Oracle은 REGEXP_SUBSTR + CONNECT BY LEVEL, SQL Server는 STRING_SPLIT으로 했다.
* Q4: `= 'SQL'` → S1, S3만.

## F. 변형 문제
1. 분해된 테이블에서 취미별 학생 수를 구하라.
2. 원래 형식(쉼표 목록)으로 되돌려 보여 주는 쿼리를 LISTAGG / STRING_AGG로 작성하라.

G: [../exercises/ex03_first_normal_form.md](../exercises/ex03_first_normal_form.md)
