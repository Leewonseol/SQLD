# 05. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## Oracle STEP 1. `||` 연산자 (customer_id 1,2,3,4,8)

| customer_id | customer_name | nickname | concat_pipe |
|---|---|---|---|
| 1 | 김민준 | 민준 | 김민준(민준) |
| 2 | 이서연 | NULL | 이서연() |
| 3 | 박지훈 | NULL(원래 `''`) | 박지훈() |
| 4 | 최유진 | `' '` | 최유진( ) |
| 8 | 임수아 | NULL | 임수아() |

nickname이 NULL이어도 `concat_pipe` 전체가 NULL이 되지 않는다.

## Oracle STEP 2. `CONCAT`

| customer_id | concat_func_2args |
|---|---|
| 1 | 김민준민준 |
| 2 | 이서연 |
| 3 | 박지훈 |
| 4 | 최유진 (공백 포함) |
| 8 | 임수아 |

`concat_nested_3args`(customer_id 1,2,4,8): `김민준-민준`, `이서연-`, `최유진- `, `임수아-` —
NULL 자리는 빈 문자열로 취급되어 `-`만 남는다. `CONCAT(a,b,c)` 형태(3개
인수 직접)는 ORA-00909로 컴파일 오류가 나므로 스크립트에는 실행하지 않는다.

## Oracle STEP 3. `LENGTH`

| customer_id | nickname | len_nickname | len_literal_padded | len_rtrim_space | len_single_char |
|---|---|---|---|---|---|
| 1 | 민준 | 2 | 9 | NULL | 1 |
| 2 | NULL | NULL | 9 | NULL | 1 |
| 3 | NULL(원래 `''`) | NULL | 9 | NULL | 1 |
| 4 | `' '` | 1 | 9 | NULL | 1 |
| 8 | NULL | NULL | 9 | NULL | 1 |

`len_literal_padded`/`len_rtrim_space`/`len_single_char`는 리터럴 상수라
행마다 값이 같다. `len_rtrim_space`가 NULL인 이유: `RTRIM(' ')`은 `''`이
되고 Oracle은 `''`을 NULL로 취급하므로 `LENGTH('')`도 NULL이다.

## Oracle STEP 4. `TRIM`/`LTRIM`/`RTRIM`

| customer_id | nickname | trim_nickname | ltrim_nickname | rtrim_nickname |
|---|---|---|---|---|
| 2 | NULL | NULL | NULL | NULL |
| 3 | NULL(원래 `''`) | NULL | NULL | NULL |
| 4 | `' '` | NULL | NULL | NULL |
| 8 | NULL | NULL | NULL | NULL |

customer_id=4는 원본이 `' '`(공백 한 칸, NULL 아님)이지만 트림하면 `''`이
되고 Oracle은 이를 다시 NULL로 표시한다.

## SQL Server STEP 1. `+` 연산자 (customer_id 1,2,3,4,8)

| customer_id | customer_name | nickname | concat_plus |
|---|---|---|---|
| 1 | 김민준 | 민준 | 김민준(민준) |
| 2 | 이서연 | NULL | **NULL** |
| 3 | 박지훈 | `''` | 박지훈() |
| 4 | 최유진 | `' '` | 최유진( ) |
| 8 | 임수아 | NULL | **NULL** |

## SQL Server STEP 2. `CONCAT`

| customer_id | concat_func |
|---|---|
| 1 | 김민준(민준) |
| 2 | 이서연() |
| 3 | 박지훈() |
| 4 | 최유진( ) |
| 8 | 임수아() |

`plus_result`/`concat_result` 나란히 비교 시 customer_id 2, 8에서만
`plus_result`='NULL 전체'로 표시되고 `concat_result`는 정상 문자열 — `+`와
`CONCAT`의 NULL 처리 차이가 이 두 행에서만 드러난다.

## SQL Server STEP 3. `LEN` vs `DATALENGTH`

| customer_id | nickname | len_nickname | datalength_nickname | len_literal_padded | datalength_literal_padded |
|---|---|---|---|---|---|
| 1 | 민준 | 2 | 4(한글 인코딩에 따라 다를 수 있음) | 7 | 9 |
| 2 | NULL | NULL | NULL | 7 | 9 |
| 3 | `''` | 0 | 0 | 7 | 9 |
| 4 | `' '` | **0** | **1** | 7 | 9 |
| 8 | NULL | NULL | NULL | 7 | 9 |

`len_literal_padded`=7(앞쪽 공백 2개는 유지, 뒤쪽 공백 2개만 제거),
`datalength_literal_padded`=9(원본 그대로) — 리터럴 상수라 행과 무관하게
동일. `nickname`의 `DATALENGTH`는 NVARCHAR/VARCHAR 인코딩·문자셋에 따라
한글 부분 바이트 수가 달라질 수 있어 참고값이다.

## SQL Server STEP 4. `TRIM`/`LTRIM`/`RTRIM`

| customer_id | nickname | trim_nickname | trim_datalength |
|---|---|---|---|
| 2 | NULL | NULL | NULL |
| 3 | `''` | `''` | **0** |
| 4 | `' '` | `''` | **0** |
| 8 | NULL | NULL | NULL |

Oracle STEP 4와 정반대: SQL Server는 customer_id=3,4의 트림 결과가 NULL이
아니라 진짜 빈 문자열(길이 0)로 남는다.

## 12. 실제 실행 검증 여부

미검증. `\|\|`/`+`/`CONCAT`의 NULL 처리 규칙과 `LEN`/`DATALENGTH`/`LENGTH`
동작은 각 벤더 공식 문서에 근거했으나, 이 세션에서 실제 DBMS로 실행해
재확인하지 않았다. 특히 `DATALENGTH(nickname)`의 한글 바이트 수는 DB
문자셋(예: `AL32UTF8`, `Korean_Wansung_CI_AS` 등)에 따라 달라질 수 있다.
