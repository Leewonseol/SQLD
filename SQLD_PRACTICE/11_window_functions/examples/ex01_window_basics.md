# ex01 윈도우 함수의 효과와 집계 윈도우

> 근거: PDF추출본 E-32("집계함수결과와 각 컬럼별 행 정보는 동시 출력 불가", 서브쿼리·윈도우 해결, BOOKSHELF SUM/AVG, "ORDER BY를 명시하지 않을 경우엔 합이 누적으로 계산되지 않음") · 데이터: EMP, BOOKSHELF 8권(PDF 원문 값) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 일반 집계는 행을 하나로 줄인다. 윈도우 집계 `SUM(x) OVER (…)`는 행을 그대로 두고 각 행 옆에 집계값을 붙인다.
* `OVER ()`: 전체 행이 창 하나. `PARTITION BY p`: p 값마다 창을 나눈다(GROUP BY와 비슷하지만 행은 줄지 않는다).
* `ORDER BY`를 넣으면 기본 프레임이 "파티션 처음 ~ 현재 행(RANGE)"이 되어 **누적** 집계가 된다. ORDER BY가 없으면 파티션 전체다.

## B. 입력 데이터
EMP, BOOKSHELF 8권(PDF 원문 값)

## C. 실행 SQL
[Oracle](ex01_window_basics_oracle.sql) · [SQL Server](ex01_window_basics_sqlserver.sql)

## D. 결과 예측 문제
1. Q2에서 TOTAL_SUBQ와 TOTAL_WIN은 왜 다른가? (WHERE 적용 시점)
2. Q3 열린책들의 누적합 세 값은?
3. Q4 '창문 넘어 도망친 100세 노인'의 누적 평균은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex01_window_basics_oracle.sql -->
```text
== [Q1] PDF: 집계함수 결과와 행 정보는 GROUP BY 없이 함께 출력할 수 없다 -> 오류
SELECT empno, ename, sal, SUM(sal) AS total FROM emp
       *
ERROR at line 1:
ORA-00937: not a single-group group function

== [Q2] 해결 1 스칼라 서브쿼리 / 해결 2 윈도우 함수 SUM(sal) OVER ()

EMPNO|ENAME|SAL|TOTAL_SUBQ|TOTAL_WIN
7782|CLARK|2450|29025|8750
7839|KING|5000|29025|8750
7934|MILLER|1300|29025|8750

3 rows selected.

== [Q3] PDF: SUM(price) OVER (PARTITION BY publisher ORDER BY price) -> 출판사 안에서 가격순 누적합

BOOK_NAME|PUBLISHER|PRICE|TOTAL
멋진 신세계|문학동네|13000|13000
천개의 찬란한 태양|문학동네|16000|29000
어린 왕자|민음사|8800|8800
참을 수 없는 존재의 가벼움|민음사|11000|19800
데미안|열린책들|12000|12000
1984|열린책들|13500|25500
창문 넘어 도망친 100세 노인|열린책들|15200|40700
나미야 잡화점의 기적|현대문학|14800|14800

8 rows selected.

== [Q4] PDF: AVG(price) OVER (PARTITION BY publisher ORDER BY price) -> 누적 평균 (PDF 의 13,566.57 과 비교)

BOOK_NAME|PUBLISHER|PRICE|AVG
멋진 신세계|문학동네|13000|13000
천개의 찬란한 태양|문학동네|16000|14500
어린 왕자|민음사|8800|8800
참을 수 없는 존재의 가벼움|민음사|11000|9900
데미안|열린책들|12000|12000
1984|열린책들|13500|12750
창문 넘어 도망친 100세 노인|열린책들|15200|13566.67
나미야 잡화점의 기적|현대문학|14800|14800

8 rows selected.

== [Q5] ORDER BY 를 빼면 누적이 아니라 파티션 전체 합 (PDF "ORDER BY를 명시하지 않을 경우엔 합이 누적으로 계산되지 않음")

BOOK_NAME|PUBLISHER|PRICE|TOTAL
멋진 신세계|문학동네|13000|29000
천개의 찬란한 태양|문학동네|16000|29000
어린 왕자|민음사|8800|19800
참을 수 없는 존재의 가벼움|민음사|11000|19800
데미안|열린책들|12000|40700
1984|열린책들|13500|40700
창문 넘어 도망친 100세 노인|열린책들|15200|40700
나미야 잡화점의 기적|현대문학|14800|14800

8 rows selected.

== [Q6] COUNT·MAX·MIN 윈도우

ENAME|DEPTNO|SAL|CNT|MX|MN
KING|10|5000|3|5000|1300
CLARK|10|2450|3|5000|1300
MILLER|10|1300|3|5000|1300

3 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex01_window_basics_sqlserver.sql -->
```text
== [Q1] 집계와 행 정보 동시 출력 -> 오류
Msg 8120, Level 16, State 1, Server a70f428a7f8a, Line 2
Column 'emp.empno' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
== [Q2] 스칼라 서브쿼리 / SUM() OVER ()
empno|ename|sal|total_subq|total_win
-----|-----|---|----------|---------
7782|CLARK|2450.00|29025.00|8750.00
7839|KING|5000.00|29025.00|8750.00
7934|MILLER|1300.00|29025.00|8750.00

(3 rows affected)
== [Q3] 출판사별 가격순 누적합
book_name|publisher|price|total
---------|---------|-----|-----
멋진 신세계|문학동네|13000.00|13000.00
천개의 찬란한 태양|문학동네|16000.00|29000.00
어린 왕자|민음사|8800.00|8800.00
참을 수 없는 존재의 가벼움|민음사|11000.00|19800.00
데미안|열린책들|12000.00|12000.00
1984|열린책들|13500.00|25500.00
창문 넘어 도망친 100세 노인|열린책들|15200.00|40700.00
나미야 잡화점의 기적|현대문학|14800.00|14800.00

(8 rows affected)
== [Q4] 누적 평균
book_name|publisher|price|avg
---------|---------|-----|---
멋진 신세계|문학동네|13000.00|13000.000000
천개의 찬란한 태양|문학동네|16000.00|14500.000000
어린 왕자|민음사|8800.00|8800.000000
참을 수 없는 존재의 가벼움|민음사|11000.00|9900.000000
데미안|열린책들|12000.00|12000.000000
1984|열린책들|13500.00|12750.000000
창문 넘어 도망친 100세 노인|열린책들|15200.00|13566.670000
나미야 잡화점의 기적|현대문학|14800.00|14800.000000

(8 rows affected)
== [Q5] ORDER BY 없으면 파티션 전체
book_name|publisher|price|total
---------|---------|-----|-----
멋진 신세계|문학동네|13000.00|29000.00
천개의 찬란한 태양|문학동네|16000.00|29000.00
어린 왕자|민음사|8800.00|19800.00
참을 수 없는 존재의 가벼움|민음사|11000.00|19800.00
데미안|열린책들|12000.00|40700.00
1984|열린책들|13500.00|40700.00
창문 넘어 도망친 100세 노인|열린책들|15200.00|40700.00
나미야 잡화점의 기적|현대문학|14800.00|14800.00

(8 rows affected)
== [Q6] COUNT·MAX·MIN 윈도우
ename|deptno|sal|cnt|mx|mn
-----|------|---|---|--|--
KING|10|5000.00|3|5000.00|1300.00
CLARK|10|2450.00|3|5000.00|1300.00
MILLER|10|1300.00|3|5000.00|1300.00

(3 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 ORA-00937 / Msg 8120.
* Q2: 스칼라 서브쿼리는 EMP 전체(29025)를 따로 계산한다. 윈도우 함수는 **WHERE(deptno = 10)를 통과한 행** 위에서 계산되어 8750이다. 윈도우 함수가 SELECT 단계에서 계산된다는 증거다.
* Q3: 12000 → 25500 → 40700. PDF 결과표와 일치한다.
* Q4: (12000+13500+15200)/3 = 13566.67. PDF의 '13,566.57'은 오기다.
* Q5: ORDER BY를 빼면 출판사 합계(문학동네 29000 등)가 모든 행에 붙는다.

## F. 변형 문제
1. 전체 대비 각 책 가격의 비율(%)을 구하라.
2. 출판사별 가격 내림차순 누적합으로 바꾸면 열린책들의 값은?

G: [../exercises/ex01_window_basics.md](../exercises/ex01_window_basics.md)
