# ex05 제3정규형 (3NF) — PDF 사원·부서 예

> 근거: PDF추출본 E-01("제 3차 정규화를 통해 사원 테이블은 사원 테이블과 부서 테이블로 분해", 정규화 전후 쿼리, "조인 키는 보통 외래 키로 설정") · 데이터: N03_EMP_ORIG — PDF 원문 값(2401 김지민 100 영업부 서울 / 2402 이사원 101 개발부 서울 / 2403 유현지 201 생산부 부산) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 3NF: 2NF이면서 **이행 함수 종속이 없다**. 사번 → 부서번호 → (부서명, 부서위치)에서 부서번호를 결정자로 하는 부서 테이블을 분리한다.
* 분리 뒤 사원 테이블의 부서번호가 **외래 키 = 조인 키**가 된다(PDF).
* 정규화 전에는 한 테이블에서 바로 조회했던 정보를 정규화 뒤에는 JOIN으로 조회한다(PDF의 두 쿼리).

## B. 입력 데이터
N03_EMP_ORIG — PDF 원문 값(2401 김지민 100 영업부 서울 / 2402 이사원 101 개발부 서울 / 2403 유현지 201 생산부 부산)

## C. 실행 SQL
[Oracle](ex05_third_normal_form_oracle.sql) · [SQL Server](ex05_third_normal_form_sqlserver.sql)

## D. 결과 예측 문제
1. 정규화 전후 쿼리의 결과는 같은가?
2. 부서 위치를 바꾸려면 정규화 전·후에 각각 몇 행을 고쳐야 하는가?

## E. 실제 출력 (정규화 전후 비교)
Oracle 21c XE
<!-- RESULT: ex05_third_normal_form_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

== [Q1] PDF E-01: 사원(사번 PK, 이름, 부서번호, 부서명, 부서위치) 에서 사번 -> 부서번호 -> 부서명·부서위치 (이행 종속)

EMP_NO|NAME|DEPT_NO|DEPT_NAME|DEPT_LOC
2401|김지민|100|영업부|서울
2402|이사원|101|개발부|서울
2403|유현지|201|생산부|부산

3 rows selected.

== [Q2] PDF 정규화 전 쿼리(사번 2401 의 사번·이름·부서명). PDF 원문 'WHERE 사='2401'' 은 컬럼명 오기 -> 사번

EMP_NO|NAME|DEPT_NAME
2401|김지민|영업부

1 row selected.

== [Q3] 3NF 분해: 사원(사번, 이름, 부서번호 FK) + 부서(부서번호 PK, 부서명, 부서위치)

Table created.

Table created.

Table altered.

Table altered.

Table altered.

== [Q4] PDF 정규화 후 쿼리: 함께 보려면 조인이 필요하다 (조인 키 = 외래키 부서번호)

EMP_NO|NAME|DEPT_NAME
2401|김지민|영업부

1 row selected.

== [Q5] 무손실 검증: 분해 후 JOIN 결과 = 원래 테이블

DIFF_ROWS
0

1 row selected.

== [Q6] 갱신 이상 해소: 부서 위치 변경은 부서 테이블 한 행만

1 row updated.

EMP_NO|DEPT_LOC
2401|대전

1 row selected.

Rollback complete.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_third_normal_form_sqlserver.sql -->
```text
== [Q1] 정규화 전
emp_no|name|dept_no|dept_name|dept_loc
------|----|-------|---------|--------
2401|김지민|100|영업부|서울
2402|이사원|101|개발부|서울
2403|유현지|201|생산부|부산

(3 rows affected)
== [Q2] 정규화 전 쿼리
emp_no|name|dept_name
------|----|---------
2401|김지민|영업부

(1 rows affected)
== [Q3] 3NF 분해

(3 rows affected)

(3 rows affected)
== [Q4] 정규화 후 쿼리(조인)
emp_no|name|dept_name
------|----|---------
2401|김지민|영업부

(1 rows affected)
== [Q5] 무손실 검증
diff_rows
---------
0

(1 rows affected)
== [Q6] 부서 위치 변경은 한 행만

(1 rows affected)
emp_no|dept_loc
------|--------
2401|대전

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q2·Q4: 결과가 같다(2401 김지민 영업부). PDF 정규화 전 쿼리 원문은 `WHERE 사='2401'`인데 컬럼명 오기로 판단해 사번으로 실행했다.
* Q5: diff 0 → 무손실.
* Q6: 정규화 뒤에는 부서 한 행만 고치면 된다. 정규화 전에는 그 부서 사원 수만큼 고쳐야 한다.

## F. 변형 문제
1. 부서 테이블에 '부서장 사번'을 추가하면 사원 ↔ 부서 사이에 어떤 관계가 하나 더 생기는가?
2. PDF 사원 테이블에서 2NF 위반이 있는가? (PK가 단일 컬럼이면 부분 종속은 생길 수 없다)

G: [../exercises/ex05_third_normal_form.md](../exercises/ex05_third_normal_form.md)
