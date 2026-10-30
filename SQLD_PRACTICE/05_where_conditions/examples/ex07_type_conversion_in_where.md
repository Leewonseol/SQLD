# ex07 비교 대상의 자료형 일치와 암시적 형변환

> 근거: PDF추출본 E-06("조건 전달 시 비교 대상끼리 데이터 타입이 일치하는 것이 좋음, ex) 숫자 데이터 타입을 문자 상수로 비교 시 성능 문제 발생 가능") · 데이터: EMP, W_CODE(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 자료형이 다른 두 값을 비교하면 DBMS가 한쪽을 암시적으로 변환한다.
  * Oracle: 문자와 숫자를 비교하면 **문자 쪽을 숫자로** 바꾼다. 컬럼이 문자이면 `TO_NUMBER(컬럼)`이 되어 모든 행에 함수가 적용된다. 인덱스를 못 쓰고, 숫자가 아닌 값이 있으면 ORA-01722가 난다.
  * SQL Server: **자료형 우선순위**가 높은 쪽(INT > VARCHAR)으로 바꾼다. 결과는 Oracle과 비슷하다. 변환 실패는 Msg 245다.
* 변환되면 비교 의미도 바뀐다. 문자 `'001'`, `'01'`, `'1'`은 서로 다르지만 숫자로 바꾸면 모두 1이다.
* PDF가 예로 든 "숫자 컬럼 = 문자 상수"는 상수 쪽만 변환되어 문제가 작다(Q1). 반대로 "문자 컬럼 = 숫자 상수"가 더 위험하다(Q2).

## B. 입력 데이터 (학습용 가상 데이터)
W_CODE(id PK, code VARCHAR): 1 `001`, 2 `01`, 3 `1`, 4 `10`, 5 `A1`

## C. 실행 SQL
[Oracle](ex07_type_conversion_in_where_oracle.sql) · [SQL Server](ex07_type_conversion_in_where_sqlserver.sql)

## D. 결과 예측 문제
1. Q2 `code = 1`은 성공하는가?
2. Q3(id ≤ 4로 제한)과 Q4(`code = '1'`)의 결과 행은?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex07_type_conversion_in_where_oracle.sql -->
```text
== [Q1] 숫자 컬럼 = 문자 상수: 상수 '7369' 가 숫자로 변환 -> 정상

ENAME
SMITH

1 row selected.

== [Q2] 문자 컬럼 = 숫자 상수: 컬럼 쪽이 TO_NUMBER 로 변환된다 -> 'A1' 행에서 오류
ERROR:
ORA-01722: invalid number

no rows selected

== [Q3] 숫자로 바뀔 수 있는 행만 남기면 '001','01','1' 셋이 모두 1 과 같다 (문자 비교였다면 '1' 만)

ID|CODE
1|001
2|01
3|1

3 rows selected.

== [Q4] 자료형을 맞춘 문자 비교

ID|CODE
3|1

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex07_type_conversion_in_where_sqlserver.sql -->
```text
== [Q1] 숫자 컬럼 = 문자 상수
ename
-----
SMITH

(1 rows affected)
== [Q2] 문자 컬럼 = 숫자 상수 -> A1 변환 실패
id|code
--|----
1|001
2|01
3|1
Msg 245, Level 16, State 1, Server a70f428a7f8a, Line 2
Conversion failed when converting the varchar value 'A1' to data type int.
== [Q3] 숫자로 바뀔 수 있는 행만
id|code
--|----
1|001
2|01
3|1

(3 rows affected)
== [Q4] 문자 비교
id|code
--|----
3|1

(1 rows affected)
```
<!-- /RESULT -->

**이유**
* Q2: 두 DBMS 모두 'A1'을 숫자로 바꾸다 실패한다. SQL Server는 실패하기 전까지 읽은 3행을 이미 출력한 뒤 Msg 245를 냈다. **부분 결과가 나와도 문장은 실패한 것이다.**
* Q3: 숫자 비교라 '001', '01', '1' 세 행이 모두 1과 같다.
* Q4: 문자 비교라 '1' 한 행만 같다.
* 주의: Q3이 성공한 것은 이번 실행 계획에서 `id <= 4`가 먼저 적용되었기 때문이다. SQL은 WHERE 조건의 평가 순서를 보장하지 않는다. 실행 계획이 바뀌면 같은 쿼리도 실패할 수 있다.

## F. 변형 문제
1. `WHERE code = TO_CHAR(1)`(Oracle) / `WHERE code = CAST(1 AS VARCHAR)`(SQL Server)의 결과는?
2. `WHERE TO_NUMBER(code) = 1`(Oracle)은 Q2와 무엇이 같고 무엇이 다른가?
3. `empno = '7369 '`(뒤에 공백)은 두 DBMS에서 성공하는가? (미실행·문법 검토 과제: 직접 실행해 보라)

G: [../exercises/ex07_type_conversion_in_where.md](../exercises/ex07_type_conversion_in_where.md)
