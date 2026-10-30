# ex02 MERGE

> 근거: PDF추출본 E-04("DML: MERGE"). MERGE 구문 본문은 추출본에 없음 · 데이터: D13_STOCK·D13_STOCK_IN(학습용 가상 데이터) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* `MERGE INTO 대상 USING 원본 ON (조인 조건)` → 짝이 있으면 `WHEN MATCHED THEN UPDATE/DELETE`, 없으면 `WHEN NOT MATCHED THEN INSERT`.
* 대상 한 행에 원본이 두 행 이상 짝지어지면 오류다(ORA-30926 / Msg 8672). ON 조건의 키가 원본에서 유일해야 한다.
* Oracle: ON 조건 괄호 필수, ON에 쓴 컬럼은 UPDATE 불가, `UPDATE … DELETE WHERE`(갱신된 결과로 판단).
* SQL Server: 문장 끝 `;` 필수, `WHEN MATCHED AND 조건 THEN DELETE`, `WHEN NOT MATCHED BY SOURCE`(원본에 없는 대상 행 처리).

## B. 입력 데이터
D13_STOCK·D13_STOCK_IN(학습용 가상 데이터). 실행 전후 데이터 변화는 E의 출력(SELECT 결과와 'n rows …' 메시지)으로 비교한다.

## C. 실행 SQL
[Oracle](ex02_merge_oracle.sql) · [SQL Server](ex02_merge_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 실행 뒤 재고 표는? (pen 10+3, cap 1−1 = 0 → 삭제, ink 그대로, box 신규)
2. 원본에 pen이 두 번 있으면?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex02_merge_oracle.sql -->
```text
PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.

Table created.

Table created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

1 row created.

Commit complete.

== [Q1] 있으면 UPDATE, 없으면 INSERT. Oracle 은 ON 조건에 괄호 필수. MATCHED 안의 DELETE WHERE 로 0 이 된 행 삭제

3 rows merged.

ITEM|QTY
box|7
ink|5
pen|13

3 rows selected.

Rollback complete.

== [Q2] ON 절에 쓴 컬럼을 UPDATE SET 으로 바꾸면 오류
MERGE INTO d13_stock t USING d13_stock_in s ON (t.item = s.item) WHEN MATCHED THEN UPDATE SET t.item = s.item
                                                *
ERROR at line 1:
ORA-38104: Columns referenced in the ON Clause cannot be updated: "T"."ITEM"

== [Q3] 원본에 같은 키가 두 번 있으면(대상 1행에 원본 2행이 매칭) 오류

1 row created.

MERGE INTO d13_stock t USING d13_stock_in s ON (t.item = s.item) WHEN MATCHED THEN UPDATE SET t.qty = t.qty + s.qty
                             *
ERROR at line 1:
ORA-30926: unable to get a stable set of rows in the source tables

Rollback complete.

PL/SQL procedure successfully completed.

PL/SQL procedure successfully completed.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex02_merge_sqlserver.sql -->
```text
(3 rows affected)

(3 rows affected)
== [Q1] MERGE: 합계가 0 이 되는 행은 DELETE, 나머지 UPDATE, 없으면 INSERT

(3 rows affected)
item|qty
----|---
box|7
ink|5
pen|13

(3 rows affected)
== [Q1b] WHEN NOT MATCHED BY SOURCE: 원본에 없는 대상 행(ink) 삭제

(4 rows affected)
item|qty
----|---
box|7
cap|0
pen|13

(3 rows affected)
== [Q2] 세미콜론 없는 MERGE -> 오류
Msg 10713, Level 15, State 1, Server a70f428a7f8a, Line 2
A MERGE statement must be terminated by a semi-colon (;).
== [Q3] 원본 키 중복 -> 오류

(1 rows affected)
Msg 8672, Level 16, State 1, Server a70f428a7f8a, Line 2
The MERGE statement attempted to UPDATE or DELETE the same row more than once. This happens when a target row matches more than one source row. A MERGE statement cannot UPDATE/DELETE the same row of the target table multiple times. Refine the ON clause to ensure a target row matches at most one source row, or use the GROUP BY clause to group the source rows.
```
<!-- /RESULT -->

**이유**
* Q1: box 7, ink 5, pen 13. cap은 0이 되어 삭제되었다(두 DBMS 같음).
* SQL Server Q1b: `NOT MATCHED BY SOURCE` → 원본에 없는 ink 삭제. cap은 0으로 갱신만 됨.
* Q2(Oracle): ON 컬럼 갱신 → ORA-38104. SQL Server Q2: 세미콜론 없음 → Msg 10713.
* Q3: 원본 키 중복 → ORA-30926 / Msg 8672.

## F. 변형 문제
1. 원본의 qty가 NULL인 행은 어떻게 처리해야 하는가? (t.qty + NULL = NULL)
2. 08단원 ex08의 UPDATE SET 서브쿼리 문제를 MERGE로 다시 풀어라.

G: [../exercises/ex02_merge.md](../exercises/ex02_merge.md)
