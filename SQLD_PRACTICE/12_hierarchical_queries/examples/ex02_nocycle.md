# ex02 순환 구조와 NOCYCLE · CONNECT_BY_ISCYCLE

> 근거: PDF추출본 E-37(EMP1 1000↔2000, "NOCYCLE 명시하지 않아 오류", "CONNECT_BY_ISCYCLE: 자식 데이터와 조상 데이터가 같으면 1") · 데이터: EMP1(PDF 원문 값) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* 데이터에 순환(A의 관리자 B, B의 관리자 A)이 있으면 CONNECT BY가 끝없이 전개하려다 **ORA-01436** 오류를 낸다.
* `CONNECT BY NOCYCLE`: 이미 방문한 행으로 돌아가는 연결을 끊는다. `CONNECT_BY_ISCYCLE`은 "이 행의 자식이 조상 중 하나라서 끊긴 행"에 1을 준다. NOCYCLE 없이 쓰면 ORA-30930이다.
* SQL Server 재귀 CTE: 순환 감지 기능이 없다. `OPTION (MAXRECURSION n)` 한도(기본 100)를 넘으면 Msg 530. 경로 문자열로 직접 막는다.

## B. 입력 데이터
EMP1(PDF 원문 값)

## C. 실행 SQL
[Oracle](ex02_nocycle_oracle.sql) · [SQL Server](ex02_nocycle_sqlserver.sql)

## D. 결과 예측 문제
1. Q1(NOCYCLE 없음)의 결과는?
2. Q2에서 IS_CYCLE이 1인 행은? 그 이유는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_nocycle_oracle.sql -->
```text
== [Q1] PDF: 순환 데이터인데 NOCYCLE 을 쓰지 않으면 오류
ERROR:
ORA-01436: CONNECT BY loop in user data

no rows selected

== [Q2] PDF: NOCYCLE + CONNECT_BY_ISCYCLE (자식이 조상과 같아 순환이 생기는 행 = 1)

EMP_ID|NAME|LEVEL|IS_CYCLE
1000|홍길동|1|0
2000|강감찬|2|1

2 rows selected.

== [Q3] NOCYCLE 없이 CONNECT_BY_ISCYCLE 을 쓰면 오류
SELECT emp_id, CONNECT_BY_ISCYCLE FROM emp1 START WITH emp_id = 1000 CONNECT BY PRIOR emp_id = mgr_id
                                                                                *
ERROR at line 1:
ORA-30930: NOCYCLE keyword is required with CONNECT_BY_ISCYCLE pseudocolumn
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_nocycle_sqlserver.sql -->
```text
== [Q1] 순환 데이터를 재귀 CTE 로 전개 -> 기본 MAXRECURSION 100 초과 오류
emp_id|name|lvl
------|----|---
1000|홍길동|1
2000|강감찬|2
1000|홍길동|3
2000|강감찬|4
1000|홍길동|5
2000|강감찬|6
1000|홍길동|7
2000|강감찬|8
1000|홍길동|9
2000|강감찬|10
1000|홍길동|11
2000|강감찬|12
1000|홍길동|13
2000|강감찬|14
1000|홍길동|15
2000|강감찬|16
1000|홍길동|17
2000|강감찬|18
1000|홍길동|19
2000|강감찬|20
1000|홍길동|21
2000|강감찬|22
1000|홍길동|23
2000|강감찬|24
1000|홍길동|25
2000|강감찬|26
1000|홍길동|27
2000|강감찬|28
1000|홍길동|29
2000|강감찬|30
1000|홍길동|31
2000|강감찬|32
1000|홍길동|33
2000|강감찬|34
1000|홍길동|35
2000|강감찬|36
1000|홍길동|37
2000|강감찬|38
1000|홍길동|39
2000|강감찬|40
1000|홍길동|41
2000|강감찬|42
1000|홍길동|43
2000|강감찬|44
1000|홍길동|45
2000|강감찬|46
1000|홍길동|47
2000|강감찬|48
1000|홍길동|49
2000|강감찬|50
1000|홍길동|51
2000|강감찬|52
1000|홍길동|53
2000|강감찬|54
1000|홍길동|55
2000|강감찬|56
1000|홍길동|57
2000|강감찬|58
1000|홍길동|59
2000|강감찬|60
1000|홍길동|61
2000|강감찬|62
1000|홍길동|63
2000|강감찬|64
1000|홍길동|65
2000|강감찬|66
1000|홍길동|67
2000|강감찬|68
1000|홍길동|69
2000|강감찬|70
1000|홍길동|71
2000|강감찬|72
1000|홍길동|73
2000|강감찬|74
1000|홍길동|75
2000|강감찬|76
1000|홍길동|77
2000|강감찬|78
1000|홍길동|79
2000|강감찬|80
1000|홍길동|81
2000|강감찬|82
1000|홍길동|83
2000|강감찬|84
1000|홍길동|85
2000|강감찬|86
1000|홍길동|87
2000|강감찬|88
1000|홍길동|89
2000|강감찬|90
1000|홍길동|91
2000|강감찬|92
1000|홍길동|93
2000|강감찬|94
1000|홍길동|95
2000|강감찬|96
1000|홍길동|97
2000|강감찬|98
1000|홍길동|99
2000|강감찬|100
1000|홍길동|101
Msg 530, Level 16, State 1, Server a70f428a7f8a, Line 2
The statement terminated. The maximum recursion 100 has been exhausted before statement completion.
== [Q2] 경로 문자열로 순환 감지 (NOCYCLE·CONNECT_BY_ISCYCLE 흉내)
emp_id|name|lvl|is_cycle
------|----|---|--------
1000|홍길동|1|0
2000|강감찬|2|1

(2 rows affected)
```
<!-- /RESULT -->

**이유**
* Q1 ORA-01436.
* Q2: 1000(LEVEL 1, 0) → 2000(LEVEL 2, 1). 2000의 자식이 1000(조상)이라 순환이 감지되고 거기서 멈춘다. PDF 결과표와 일치한다.
* SQL Server Q1: 1000, 2000, 1000, …을 101행 출력한 뒤 Msg 530으로 중단했다. 오류이지만 부분 결과가 나온다.
* SQL Server Q2: 경로에 이미 있는 id면 전개하지 않는다. 다음 자식이 경로에 있으면 is_cycle = 1로 표시해 Oracle 결과와 같게 만들었다.

## F. 변형 문제
1. EMP1에 3000(관리자 2000)을 추가하면 Q2 결과는?
2. SQL Server에서 `OPTION (MAXRECURSION 3)`을 붙이면 몇 행 뒤에 멈추는가? (미실행 과제)

G: [../exercises/ex02_nocycle.md](../exercises/ex02_nocycle.md)
