# ex05 NULL 관련 함수

> 근거: 요구목록 §7(NVL, ISNULL, NULLIF, COALESCE). E-28 NVL(species,'합계') 사용례 · 데이터: EMP 30번 부서 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
| 함수 | 의미 | Oracle | SQL Server |
|---|---|---|---|
| NVL(a, b) / ISNULL(a, b) | a가 NULL이면 b | NVL | ISNULL (결과 형 = a의 형 → **잘림 주의**) |
| NVL2(a, b, c) | a가 NULL이 아니면 b, NULL이면 c | NVL2 | 없음 → IIF / CASE |
| NULLIF(a, b) | a = b이면 NULL, 아니면 a | ○ | ○ |
| COALESCE(a, b, …) | 처음으로 NULL이 아닌 값 | ○ | ○ (모두 형 없는 NULL이면 Msg 4127) |
* **NVL(SUM(x), 0)과 SUM(NVL(x, 0))**: 대상 행이 없으면 SUM(NVL())도 NULL이다. 빈 집합 대비는 바깥쪽 NVL이다.

## B. 입력 데이터
EMP 30번 부서. 별도 테이블을 만들지 않는 실습은 리터럴 값으로 결과를 확정했다.

## C. 실행 SQL
[Oracle](ex05_null_functions_oracle.sql) · [SQL Server](ex05_null_functions_sqlserver.sql)

## D. 결과 예측 문제
1. BLAKE의 NVL2(comm, sal+comm, sal)는?
2. 40번 부서(사원 없음)에서 NVL(SUM(sal),0)과 SUM(NVL(sal,0))은?
3. SQL Server `ISNULL(CAST(NULL AS VARCHAR(2)), 'ABCD')`는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex05_null_functions_oracle.sql -->
```text
== [Q1] NVL(a, b): a 가 NULL 이면 b / NVL2(a, b, c): a 가 NULL 이 아니면 b, NULL 이면 c

ENAME|COMM|NVL_C|NVL2_PAY
ALLEN|300|300|1900
WARD|500|500|1750
MARTIN|1400|1400|2650
BLAKE|(null)|0|2850
TURNER|0|0|1500
JAMES|(null)|0|950

6 rows selected.

== [Q2] NULLIF(a, b): 같으면 NULL, 다르면 a / COALESCE: 처음으로 NULL 이 아닌 값

N1|N2|C1|C2
(null)|10|third|(null)

1 row selected.

== [Q3] 0 으로 나누기 회피: NULLIF 로 분모 0 을 NULL 로

ENAME|SAL|COMM|RATIO
ALLEN|1600|300|5.33
WARD|1250|500|2.5
MARTIN|1250|1400|.89
BLAKE|2850|(null)|(null)
TURNER|1500|0|(null)
JAMES|950|(null)|(null)

6 rows selected.

== [Q4] NVL(SUM) 과 SUM(NVL) : 대상 행이 없으면 SUM(NVL()) 도 NULL

NVL_SUM|SUM_NVL
0|(null)

1 row selected.

== [Q5] NVL 의 두 인수 자료형: 숫자 컬럼에 문자 기본값 -> 오류
SELECT NVL(comm, 'none') FROM emp
                 *
ERROR at line 1:
ORA-01722: invalid number

== [Q6] 문자 기본값을 쓰려면 먼저 문자로 변환

ENAME|COMM_TXT
ALLEN|300
WARD|500
MARTIN|1400
BLAKE|none
TURNER|0
JAMES|none

6 rows selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex05_null_functions_sqlserver.sql -->
```text
== [Q1] ISNULL(a, b) / NVL2 대체는 CASE 또는 IIF
ename|comm|isnull_c|nvl2_pay
-----|----|--------|--------
ALLEN|300.00|300.00|1900.00
WARD|500.00|500.00|1750.00
MARTIN|1400.00|1400.00|2650.00
BLAKE|NULL|.00|2850.00
TURNER|.00|.00|1500.00
JAMES|NULL|.00|950.00

(6 rows affected)
== [Q2] NULLIF / COALESCE
n1|n2|c1
--|--|--
NUL|10|third

(1 rows affected)
== [Q3] NULLIF 로 0 나누기 회피
ename|sal|comm|ratio
-----|---|----|-----
ALLEN|1600.00|300.00|5.3300000000
WARD|1250.00|500.00|2.5000000000
MARTIN|1250.00|1400.00|.8900000000
BLAKE|2850.00|NULL|NULL
TURNER|1500.00|.00|NULL
JAMES|950.00|NULL|NULL

(6 rows affected)
== [Q4] ISNULL(SUM) 과 SUM(ISNULL)
isnull_sum|sum_isnull
----------|----------
.00|NULL

(1 rows affected)
== [Q7] ISNULL 은 첫 인수의 자료형으로 결과를 맞춘다 -> 잘림. COALESCE 는 우선순위가 높은 형
isnull_trunc|coalesce_full
------------|-------------
AB|ABCD

(1 rows affected)
== [Q8] COALESCE 인수가 모두 형 없는 NULL -> 오류
Msg 4127, Level 16, State 1, Server a70f428a7f8a, Line 2
At least one of the arguments to COALESCE must be an expression that is not the NULL constant.
== [Q5] 숫자 컬럼에 문자 기본값 -> 오류
Msg 8114, Level 16, State 5, Server a70f428a7f8a, Line 2
Error converting data type varchar to numeric.
== [Q6] 먼저 문자로 변환
ename|comm_txt
-----|--------
ALLEN|300.00
WARD|500.00
MARTIN|1400.00
BLAKE|none
TURNER|0.00
JAMES|none

(6 rows affected)
== [Q9] NVL 은 없는 함수
Msg 195, Level 15, State 10, Server a70f428a7f8a, Line 2
'NVL' is not a recognized built-in function name.
```
<!-- /RESULT -->

**이유**
* Q1: comm이 NULL인 BLAKE·JAMES는 NVL 0, NVL2는 sal만. TURNER(comm 0)는 NULL이 아니므로 sal+0.
* Q2: NULLIF(10,10)=NULL. sqlcmd는 열 너비 때문에 NULL을 `NUL`로 잘라 표시했다(값은 NULL). COALESCE(NULL, NULL)은 Oracle NULL, SQL Server는 Msg 4127.
* Q3: TURNER(comm 0)는 NULLIF로 분모가 NULL이 되어 결과 NULL(오류 아님).
* Q4: 0 / NULL. 빈 집합이라 SUM(NVL())은 NULL이다.
* Q5: 숫자 컬럼의 기본값으로 문자를 주면 ORA-01722 / Msg 8114. 먼저 문자로 바꾼다(Q6). SQL Server는 DECIMAL을 문자로 바꿀 때 '300.00'처럼 소수 자리가 남는다.
* Q7: ISNULL은 첫 인수의 형(VARCHAR(2))으로 결과를 맞춰 'AB'로 잘린다. COALESCE는 'ABCD'다. **결과가 다르다.**

## F. 변형 문제
1. 사원별 실수령액(sal + comm)을 NVL·COALESCE·CASE 세 방법으로 구하고 결과가 같은지 비교하라.
2. 관리자가 없으면 'TOP', 있으면 관리자 사번을 문자로 출력하라.
3. `COALESCE(comm, mgr, 0)`의 의미를 설명하고 KING·SMITH·ALLEN의 결과를 예측하라.

G: [../exercises/ex05_null_functions.md](../exercises/ex05_null_functions.md)
