# 01. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## STEP 1. IS NULL / IS NOT NULL (Oracle·SQL Server 공통)

`WHERE nickname IS NULL` → customer_id **2, 8** (2행)
`WHERE nickname IS NOT NULL` → 나머지 10행 (customer_id 3도 포함 — Oracle에서는
nickname이 NULL로 바뀌었으므로 **Oracle에서는 3행도 IS NULL 쪽으로 이동**한다.
SQL Server에서는 3행이 IS NOT NULL 쪽에 그대로 남는다.)

| | Oracle `IS NULL` 행 | SQL Server `IS NULL` 행 |
|---|---|---|
| customer_id | 2, 3, 8 (3행) | 2, 8 (2행) |

## STEP 2. `= NULL` / `<> NULL`

| 쿼리 | Oracle | SQL Server |
|---|---|---|
| `wrong_count_eq_null` | 0 | 0 |
| `wrong_count_neq_null` | 0 | 0 |
| `correct_count_is_null` | 3 | 2 |

## STEP 3. 2, 3, 4, 8행 비교

**Oracle**

| customer_id | nickname | nickname_length | is_null_check |
|---|---|---|---|
| 2 | NULL | NULL | NULL(TRUE) |
| 3 | NULL(원래 `''`) | NULL | NULL(TRUE) |
| 4 | `' '` | 1 | NOT NULL |
| 8 | NULL | NULL | NULL(TRUE) |

**SQL Server**

| customer_id | nickname | nickname_len(LEN) | nickname_datalength | is_null_check |
|---|---|---|---|---|
| 2 | NULL | NULL | NULL | NULL(TRUE) |
| 3 | `''` | 0 | 0 | NOT NULL |
| 4 | `' '` | 0 | 1 | NOT NULL |
| 8 | NULL | NULL | NULL | NULL(TRUE) |

`LEN`은 3행과 4행을 똑같이 0으로 보여준다 — 반드시 `DATALENGTH`로 확인해야
`''`(0바이트)과 `' '`(1바이트)이 구분된다.

## STEP 4. 빈 문자열/공백 명시 비교

| 쿼리 | Oracle 결과 | SQL Server 결과 |
|---|---|---|
| `nickname = ''` 행 수 | 0 | **2**(customer_id 3, 4 — 공백 패딩) |
| `nickname = ' '` 행 수 | 1(customer_id 4) | **2**(customer_id 3, 4 — 공백 패딩) |

SQL Server의 `empty_vs_whitespace` 최종 판정(오직 `DATALENGTH`로 확정):

| customer_id | empty_vs_whitespace |
|---|---|
| 3 | TRUE_EMPTY_STRING |
| 4 | WHITESPACE_NOT_EMPTY |

## 12. 실제 실행 검증 여부

미검증. Oracle `''→NULL` 저장 규칙과 SQL Server ANSI 공백 패딩 비교 규칙은
각 벤더 공식 문서에 근거했으나, 이 세션에서 실제 DBMS로 실행해 재확인하지
않았다.
