# 03. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## STEP 1. NULL이 섞인 산술연산

`purchase_amt`(NULL: 5, 11), `age`(NULL: 5), `score`(NULL: 3, 9) — Oracle과
SQL Server 결과는 완전히 같다(NULL 산술 규칙 자체는 표준 SQL 공통).

| customer_id | purchase_amt | amt_plus(+10000) | amt_times(*1.1) |
|---|---|---|---|
| 1 | 120000 | 130000 | 132000 |
| 2 | 98000 | 108000 | 107800 |
| 3 | 150000 | 160000 | 165000 |
| 4 | 0 | 10000 | 0 |
| 5 | NULL | **NULL** | **NULL** |
| 6 | 45000 | 55000 | 49500 |
| 7 | 76000 | 86000 | 83600 |
| 8 | 210000 | 220000 | 231000 |
| 9 | 89000 | 99000 | 97900 |
| 10 | 132000 | 142000 | 145200 |
| 11 | NULL | **NULL** | **NULL** |
| 12 | 300000 | 310000 | 330000 |

`age_plus_1`: customer_id=5만 NULL, 나머지는 `age+1`. `score_times_2`:
customer_id 3, 9만 NULL, 나머지는 `score*2`.

## STEP 2. 문자열 결합에서의 NULL 전파

| customer_id | nickname | Oracle `nickname \|\| '님'` | SQL Server `nickname + N'님'` |
|---|---|---|---|
| 2 | NULL | NULL | NULL |
| 3 | Oracle: NULL / SQL Server: `''` | **NULL** | **'님'**(정상 결합) |
| 8 | NULL | NULL | NULL |
| 나머지 9행 | 일반 문자열 | `문자열님` | `문자열님` |

customer_id=3에서 Oracle과 SQL Server 결과가 갈리는 것은 01 폴더에서 확인한
`''→NULL` 저장 규칙 차이가 그대로 이어진 것이다.

방어 쿼리(`NVL`/`ISNULL`로 먼저 치환) 결과: 모든 행이 NULL 없이
`고객님`(2, 8행) 또는 원래 닉네임+`님`으로 채워진다. Oracle에서는 3행도
`고객님`(Oracle에서 nickname이 NULL이므로), SQL Server에서는 3행이
`님`(nickname이 ''이라 NVL/ISNULL이 관여하지 않음)으로 서로 다르게 채워진다.

## STEP 3. NULLIF로 0으로 나누기 방지

| customer_id | order_qty | discount_qty | 방어 없는 나눗셈 | 방어(`NULLIF(discount_qty,0)`) 결과 |
|---|---|---|---|---|
| 1 | 10 | 2 | 5(Oracle·SQL Server 동일) | 5 |
| 2 | 5 | 0 | **에러**(Oracle `ORA-01476`, SQL Server `Divide by zero error`) | NULL(에러 없이 방어됨) |
| 3 | 8 | 4 | 2 | 2 |
| 4 | 3 | 1 | 3 | 3 |
| 5 | 6 | 2 | 3 | 3 |
| 6 | 0 | 3 | 0 | 0 |
| 7 | 4 | NULL | **NULL(에러 아님)** | NULL |
| 8 | 12 | 5 | Oracle 2.4 / SQL Server **2**(정수 나눗셈) | 동일 |
| 9 | 7 | 2 | Oracle 3.5 / SQL Server **3**(정수 나눗셈) | 동일 |
| 10 | 9 | 3 | 3 | 3 |
| 11 | 5 | 2 | Oracle 2.5 / SQL Server **2**(정수 나눗셈) | 동일 |
| 12 | 15 | 5 | 3 | 3 |

두 가지 대비 포인트:

1. **customer_id=2(분모 0)와 customer_id=7(분모 NULL)의 차이** — 2행은
   나눗셈 자체가 **에러**를 내지만, 7행은 에러 없이 결과가 **NULL**이 된다.
   "0으로 나누기"와 "NULL로 나누기"는 서로 다른 현상이다.
2. **Oracle NUMBER vs SQL Server INT의 나눗셈 차이**(8, 9, 11행) — 두
   컬럼 모두 정수처럼 보이는 값이지만, Oracle의 `NUMBER`는 정수/소수를
   구분하지 않아 소수 결과가 그대로 나오는 반면(2.4, 3.5, 2.5), SQL
   Server의 `INT`는 정수 나눗셈이라 소수부가 버려진다(2, 3, 2). 02 폴더
   STEP 6에서 확인한 "Oracle NUMBER는 항상 소수 나눗셈"이라는 특성이 이
   폴더에서도 그대로 재확인된다.

## 12. 실제 실행 검증 여부

미검증. NULL 산술 전파 규칙(표준 SQL 공통), Oracle `ORA-01476`, SQL Server
"Divide by zero" 오류, `NULLIF`의 방어 동작, Oracle `NUMBER`와 SQL Server
`INT`의 나눗셈 결과 타입 차이는 각 벤더 공식 문서를 근거로 도출했으나 이
세션에서 실제 DBMS로 실행해 재확인하지 않았다.
