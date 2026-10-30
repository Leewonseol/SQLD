# ex02 윈도우 프레임 ROWS · RANGE

> 근거: PDF추출본 E-33("RANGE: 값이 같으면 같은 범위로 취급하여 동시 연산", ROWS UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING / 1 FOLLOWING / CURRENT ROW 결과표) · 데이터: EMP 중 PDF와 같은 6명(SMITH 800, JAMES 950, ADAMS 1100, WARD 1250, MARTIN 1250, MILLER 1300) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **ROWS**: 물리적인 행 개수로 범위를 정한다(앞 1행, 뒤 1행 …). 동점이어도 행마다 따로 계산한다.
* **RANGE**: ORDER BY **값**으로 범위를 정한다. 같은 값(동점)은 같은 범위에 들어가 같은 결과가 나온다. Oracle은 값 오프셋(`RANGE 150 PRECEDING`)을 받고, SQL Server는 UNBOUNDED/CURRENT ROW만 받는다.
* **기본 프레임**: ORDER BY만 쓰면 `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`다. ORDER BY가 없으면 파티션 전체다.
* PDF의 SAL 정렬에는 동점(1250)이 있다. ROWS 결과가 결정적이도록 empno를 2차 정렬 키로 두었다.

## B. 입력 데이터
EMP 중 PDF와 같은 6명(SMITH 800, JAMES 950, ADAMS 1100, WARD 1250, MARTIN 1250, MILLER 1300)

## C. 실행 SQL
[Oracle](ex02_rows_range_oracle.sql) · [SQL Server](ex02_rows_range_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(RANGE 기본)과 Q4(ROWS 누적)에서 WARD·MARTIN의 값은 각각?
2. Q3(UNBOUNDED ~ 1 FOLLOWING)의 첫 행과 마지막 행 값은?
3. Q5 RANGE 150 PRECEDING에서 ADAMS(1100)는 어떤 값들을 더하는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_rows_range_oracle.sql -->
```text
== [Q1] PDF RANGE(기본 프레임): ORDER BY sal 만 쓰면 RANGE UNBOUNDED PRECEDING AND CURRENT ROW -> 같은 값은 함께 더한다

EMPNO|ENAME|SAL|TOTAL_SAL
7369|SMITH|800|800
7900|JAMES|950|1750
7876|ADAMS|1100|2850
7521|WARD|1250|5350
7654|MARTIN|1250|5350
7934|MILLER|1300|6650

6 rows selected.

== [Q2] PDF ROWS UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING: 모든 행이 전체 합 6650

EMPNO|ENAME|SAL|TOTAL_SAL
7369|SMITH|800|6650
7900|JAMES|950|6650
7876|ADAMS|1100|6650
7521|WARD|1250|6650
7654|MARTIN|1250|6650
7934|MILLER|1300|6650

6 rows selected.

== [Q3] PDF ROWS UNBOUNDED PRECEDING AND 1 FOLLOWING: 첫 행부터 다음 행까지

EMPNO|ENAME|SAL|TOTAL_SAL
7369|SMITH|800|1750
7900|JAMES|950|2850
7876|ADAMS|1100|4100
7521|WARD|1250|5350
7654|MARTIN|1250|6650
7934|MILLER|1300|6650

6 rows selected.

== [Q4] PDF ROWS UNBOUNDED PRECEDING AND CURRENT ROW: 행 단위 누적 (동점도 한 행씩)

EMPNO|ENAME|SAL|TOTAL_SAL
7369|SMITH|800|800
7900|JAMES|950|1750
7876|ADAMS|1100|2850
7521|WARD|1250|4100
7654|MARTIN|1250|5350
7934|MILLER|1300|6650

6 rows selected.

== [Q5] 이동 범위: ROWS 1 PRECEDING ~ 1 FOLLOWING (앞뒤 한 행) / RANGE 150 PRECEDING ~ CURRENT ROW (값 기준 150 이내)

EMPNO|ENAME|SAL|ROWS_PM1|RANGE_150
7369|SMITH|800|1750|800
7900|JAMES|950|2850|1750
7876|ADAMS|1100|3300|2050
7521|WARD|1250|3600|3600
7654|MARTIN|1250|3800|3600
7934|MILLER|1300|2550|3800

6 rows selected.

== [Q6] 프레임 없이 ORDER BY 만 있으면 RANGE 기본 = Q1, ORDER BY 도 없으면 파티션 전체

ENAME|SAL|NO_ORDER
SMITH|800|1750
JAMES|950|1750

2 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_rows_range_sqlserver.sql -->
```text
== [Q1] 기본 프레임(RANGE)
empno|ename|sal|total_sal
-----|-----|---|---------
7369|SMITH|800.00|800.00
7900|JAMES|950.00|1750.00
7876|ADAMS|1100.00|2850.00
7521|WARD|1250.00|5350.00
7654|MARTIN|1250.00|5350.00
7934|MILLER|1300.00|6650.00

(6 rows affected)
== [Q2] ROWS 전체
empno|ename|sal|total_sal
-----|-----|---|---------
7369|SMITH|800.00|6650.00
7900|JAMES|950.00|6650.00
7876|ADAMS|1100.00|6650.00
7521|WARD|1250.00|6650.00
7654|MARTIN|1250.00|6650.00
7934|MILLER|1300.00|6650.00

(6 rows affected)
== [Q3] ROWS UNBOUNDED PRECEDING AND 1 FOLLOWING
empno|ename|sal|total_sal
-----|-----|---|---------
7369|SMITH|800.00|1750.00
7900|JAMES|950.00|2850.00
7876|ADAMS|1100.00|4100.00
7521|WARD|1250.00|5350.00
7654|MARTIN|1250.00|6650.00
7934|MILLER|1300.00|6650.00

(6 rows affected)
== [Q4] ROWS 누적
empno|ename|sal|total_sal
-----|-----|---|---------
7369|SMITH|800.00|800.00
7900|JAMES|950.00|1750.00
7876|ADAMS|1100.00|2850.00
7521|WARD|1250.00|4100.00
7654|MARTIN|1250.00|5350.00
7934|MILLER|1300.00|6650.00

(6 rows affected)
== [Q5a] ROWS 1 PRECEDING ~ 1 FOLLOWING
empno|ename|sal|rows_pm1
-----|-----|---|--------
7369|SMITH|800.00|1750.00
7900|JAMES|950.00|2850.00
7876|ADAMS|1100.00|3300.00
7521|WARD|1250.00|3600.00
7654|MARTIN|1250.00|3800.00
7934|MILLER|1300.00|2550.00

(6 rows affected)
== [Q5b] RANGE 150 PRECEDING -> SQL Server 미지원(오류)
Msg 4194, Level 16, State 1, Server a70f428a7f8a, Line 2
RANGE is only supported with UNBOUNDED and CURRENT ROW window frame delimiters.
== [Q6] OVER ()
ename|sal|no_order
-----|---|--------
SMITH|800.00|1750.00
JAMES|950.00|1750.00

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1: WARD·MARTIN이 동점이라 둘 다 5350(800+950+1100+1250+1250)이다. PDF와 일치한다. 단 PDF 표의 3행 '2050'은 오기이고 실제는 2850이다.
* Q2: 모든 행 6650. Q3: 첫 행 800+950 = 1750, 마지막 행은 '다음 행'이 없어 6650.
* Q4: ROWS라서 WARD 4100, MARTIN 5350으로 다르다. PDF의 '2050'은 여기서도 오기(2850)다.
* Q5: ROWS ±1 = 앞뒤 한 행씩. RANGE 150: 값이 [sal−150, sal]인 행. ADAMS는 950·1100 → 2050. SQL Server는 Msg 4194.
* Q6: ORDER BY 없는 OVER () → 대상 행 전체 합.

## F. 변형 문제
1. 3행 이동 평균(앞 2행 ~ 현재 행)을 구하라.
2. Q1의 ORDER BY sal을 `ORDER BY sal, empno`로 바꾸면 RANGE 결과는 어떻게 바뀌는가? (동점이 사라져 ROWS와 같아진다)

G: [../exercises/ex02_rows_range.md](../exercises/ex02_rows_range.md)
