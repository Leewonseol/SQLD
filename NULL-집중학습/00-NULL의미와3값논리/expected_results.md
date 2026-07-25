# 00. 예상 결과

`oracle.sql`/`sqlserver.sql`을 각 환경에서 실행했을 때 나올 것으로 예상되는
결과다(**미검증** — 12절 참고). 3값 논리는 두 DBMS가 공유하는 표준 규칙이라
STEP 1~4의 계산 결과는 Oracle과 SQL Server가 완전히 같다.

## STEP 1. `= NULL` / `<> NULL` / `IS NULL`

| customer_id | score | eq_null_literal | neq_null_literal | is_null_correct |
|---|---|---|---|---|
| 1 | 85 | NULL | NULL | 0(FALSE) |
| 3 | NULL | NULL | NULL | 1(TRUE) |
| 9 | NULL | NULL | NULL | 1(TRUE) |

`eq_null_literal`/`neq_null_literal`은 score 값과 무관하게 **모든 행에서
NULL** — 이 두 컬럼만 보면 3값(85, NULL, NULL) 중 어느 것도 TRUE/FALSE로
안 나온다는 게 요점이다.

## STEP 2. AND/OR 진리표 (9행)

| a_value | b_value | a_and_b | a_or_b |
|---|---|---|---|
| TRUE | TRUE | TRUE | TRUE |
| TRUE | FALSE | FALSE | TRUE |
| TRUE | UNKNOWN | UNKNOWN | TRUE |
| FALSE | TRUE | FALSE | TRUE |
| FALSE | FALSE | FALSE | FALSE |
| FALSE | UNKNOWN | FALSE | UNKNOWN |
| UNKNOWN | TRUE | UNKNOWN | TRUE |
| UNKNOWN | FALSE | FALSE | UNKNOWN |
| UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |

(정렬 순서는 Oracle/SQL Server 정렬 문법 차이로 실제 행 순서가 조금 다를 수
있으나, 9개 조합의 값 자체는 위 표와 완전히 같다.)

## STEP 3. `NOT`

| customer_id | score | not_result |
|---|---|---|
| 1 | 85 | TRUE |
| 3 | NULL | UNKNOWN(NOT으로도 못 뒤집음) |
| 9 | NULL | UNKNOWN(NOT으로도 못 뒤집음) |

## STEP 4. WHERE로 12행을 3그룹으로 분할

| 조건 | 해당 customer_id | 행 수 |
|---|---|---|
| `score > 80` (TRUE) | 1, 2, 7, 8, 11, 12 | 6 |
| `NOT (score > 80)` (TRUE, 즉 score<=80이고 NULL 아님) | 4, 5, 6, 10 | 4 |
| `score IS NULL` (원래 조건이 UNKNOWN이었던 몫) | 3, 9 | 2 |

6 + 4 + 2 = 12 — 세 그룹이 서로 겹치지 않고 전체 12행을 정확히 나눈다.
**`score > 80`과 `NOT (score > 80)`만 UNION 했다면 10행만 나오고 3,9행이
누락됐을 것** — 이것이 8절 "SQLD 함정"의 핵심 증거다.

## 12. 실제 실행 검증 여부

Oracle·SQL Server 모두 미검증. 위 수치는 3값 논리 표준 규칙과 수기 계산으로
도출한 예상값이며, 이 저장소 세션에서 실제 DBMS로 실행하지 않았다.
