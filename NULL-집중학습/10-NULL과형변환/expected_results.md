# 10. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## STEP 1. CAST(NULL AS 자료형)

| DBMS | cast_null_number/int | cast_null_varchar | cast_null_date |
|---|---|---|---|
| Oracle | NULL | NULL | NULL |
| SQL Server | NULL | NULL | NULL |

## STEP 2. NULL 입력 형변환 함수

| 함수 | Oracle 결과 | SQL Server 대응 함수 | SQL Server 결과 |
|---|---|---|---|
| `TO_CHAR(NULL)` | NULL | `CONVERT(VARCHAR(10), NULL)` | NULL |
| `TO_NUMBER(NULL)` | NULL | `CAST(NULL AS INT)` | NULL |
| `TO_DATE(NULL)` | NULL | `TRY_CONVERT(INT, NULL)` | NULL |
| — | — | `TRY_CAST(NULL AS INT)` | NULL |

모두 NULL — 에러 없음.

## STEP 3. membership_code 숫자 변환

`membership_code`: customer_id=5는 `'0'`, 나머지는 `'A001'`~`'A012'`.

| 단계 | Oracle | SQL Server |
|---|---|---|
| 3-1. customer_id=5, `CAST(... AS NUMBER/INT)` | 0 | 0 |
| 3-2. customer_id=1, `CAST('A001' AS NUMBER/INT)` | **에러: ORA-01722 invalid number** | **에러: Conversion failed ... 'A001' to data type int** |
| 3-3. 안전 변환(전체 12행) | `TO_NUMBER(... DEFAULT NULL ON CONVERSION ERROR)` → customer_id=5만 0, 나머지 11행 NULL | `TRY_CAST`/`TRY_CONVERT` → customer_id=5만 0, 나머지 11행 NULL |

## STEP 4. join_date 문자열 변환

`join_date`가 NULL인 행: customer_id 3, 11.

| customer_id | join_date | Oracle `TO_CHAR(join_date,'YYYY-MM-DD')` | SQL Server `CONVERT(VARCHAR(10), join_date, 120)` |
|---|---|---|---|
| 1 | 2024-01-10 | '2024-01-10' | '2024-01-10' |
| 2 | 2024-02-15 | '2024-02-15' | '2024-02-15' |
| 3 | NULL | **NULL**(문자열 "NULL" 아님) | **NULL** |
| 4 | 2024-03-05 | '2024-03-05' | '2024-03-05' |
| 5 | 2024-01-22 | '2024-01-22' | '2024-01-22' |
| 6 | 2024-04-11 | '2024-04-11' | '2024-04-11' |
| 7 | 2024-05-02 | '2024-05-02' | '2024-05-02' |
| 8 | 2024-06-19 | '2024-06-19' | '2024-06-19' |
| 9 | 2024-07-08 | '2024-07-08' | '2024-07-08' |
| 10 | 2024-08-14 | '2024-08-14' | '2024-08-14' |
| 11 | NULL | **NULL** | **NULL** |
| 12 | 2024-09-30 | '2024-09-30' | '2024-09-30' |

## 12. 실제 실행 검증 여부

미검증. Oracle `ORA-01722`, SQL Server 변환 에러 메시지, `TRY_CAST`/
`TRY_CONVERT`(SQL Server 2012+), `DEFAULT ... ON CONVERSION ERROR`(Oracle
12c+)는 각 벤더 공식 문서에 근거했으나, 이 세션에서 실제 DBMS로 실행해
재확인하지 않았다.
