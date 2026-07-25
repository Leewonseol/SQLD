# 02. 예상 결과

미검증(12절 참고) — 각 DBMS 공식 문서의 표준 동작을 근거로 도출한 예상값이다.

## STEP 1. 기본 치환(NVL/ISNULL vs COALESCE)

`purchase_amt` NULL 행: customer_id 5, 11.

| customer_id | purchase_amt | NVL/ISNULL 결과 | COALESCE 결과 |
|---|---|---|---|
| 5 | NULL | 0 | 0 |
| 11 | NULL | 0 | 0 |
| 그 외 10행 | 원래 값 | 원래 값 | 원래 값 |

`nickname` 치환('별명없음') 결과는 Oracle과 SQL Server가 갈린다.

| customer_id | nickname 설계 의도 | Oracle 치환 결과 | SQL Server 치환 결과 |
|---|---|---|---|
| 2 | NULL | '별명없음' | '별명없음' |
| 3 | `''` | **'별명없음'**(Oracle이 ''→NULL로 저장) | **''**(그대로, 치환 안 됨) |
| 8 | NULL | '별명없음' | '별명없음' |

## STEP 2. NVL2 / CASE WHEN 흉내

`score` NULL 행: customer_id 3, 9.

| customer_id | score | nvl2_score_status | nvl2_score_scaled |
|---|---|---|---|
| 3 | NULL | 'SCORE_없음' | -1 |
| 9 | NULL | 'SCORE_없음' | -1 |
| 그 외 10행 | 원래 값 | 'SCORE_있음' | score*10 |

Oracle `NVL2`와 SQL Server `CASE WHEN` 구현 결과는 완전히 같다.

## STEP 3. CASE WHEN = NVL/ISNULL

모든 행에서 `nvl_result`(또는 `isnull_result`) = `case_when_result`. 차이 없음.

## STEP 4. NULLIF

| 쿼리 | 결과가 NULL로 바뀌는 행 |
|---|---|
| `NULLIF(age, 0)` | customer_id=4(age=0) |
| `NULLIF(score, 0)` | customer_id=6(score=0) |

customer_id=5(age가 원래 NULL)는 `NULLIF`를 거쳐도 그대로 NULL — 애초에 0이
아니라 NULL이었기 때문에 `NULLIF`가 관여할 여지가 없다.

## STEP 5. 짧은 VARCHAR(2)/VARCHAR2(5) + 긴 대체 문자열

| 단계 | Oracle | SQL Server |
|---|---|---|
| SELECT (COALESCE 결과 직접 조회) | 성공, `memo_demo`='정보없음(장기미접속)', `memo_len`=11 | 성공, 동일 |
| INSERT INTO VARCHAR2(5)/VARCHAR(5) 컬럼 | **에러**: `ORA-12899: value too large for column` | **에러**: `String or binary data would be truncated` |

SELECT는 폭 제한이 없어 항상 성공하고, 물리적 컬럼에 저장하려는 순간에만
길이 제약이 걸린다는 것이 이 STEP의 핵심.

## STEP 6. 정수 + 소수 리터럴(타입 승격)

| DBMS | `score`(customer_id=1, 값 85) 기준 `raw`(원본) 나눗셈 | `COALESCE(score,0.5)/2` |
|---|---|---|
| SQL Server(`score` INT) | `score/2` = 42(정수 나눗셈, 소수부 버림) | 42.500000(decimal로 승격) |
| Oracle(`score` NUMBER) | `score/2` = 42.5(원래도 소수 나눗셈) | 42.5(승격 여부 자체가 안 보임) |

SQL Server는 INT 컬럼이 소수 리터럴과 섞이는 순간 결과 타입이 decimal로
승격되어 나눗셈 결과가 달라지는 게 뚜렷이 보인다. Oracle은 NUMBER가 처음부터
정수/소수를 구분하지 않으므로 이 "승격"이라는 현상 자체가 관측되지 않는다 —
Oracle과 SQL Server의 근본적인 숫자 타입 철학 차이다.

## STEP 7. 숫자 + 문자열 혼합

`COALESCE(age, membership_code)` — age가 NULL인 유일한 행(customer_id=5)의
membership_code가 `'0'`이라 우연히 숫자로 변환되어 에러가 나지 않는다.

| customer_id | age | membership_code | coalesced_age |
|---|---|---|---|
| 5 | NULL | '0' | 0 |
| 그 외 11행 | 원래 값 | (미사용) | 원래 age |

`COALESCE(age, dept_code)` — customer_id=5의 dept_code가 `'D01'`(숫자 변환
불가)이라 **에러가 난다.**

| DBMS | 에러 메시지 |
|---|---|
| Oracle | `ORA-01722: invalid number` |
| SQL Server | `Conversion failed when converting the varchar value 'D01' to data type int.` |

## STEP 8. 날짜 + 문자열 혼합

`COALESCE(join_date, '정보없음')` — join_date가 NULL인 customer_id=3, 11에서
'정보없음'을 DATE로 변환하려다 **에러가 난다**(NULL이 아닌 행도 컴파일 단계의
타입 결정 때문에 전체 쿼리가 실패할 수 있다).

| DBMS | 에러 메시지(대표) |
|---|---|
| Oracle | `ORA-01858` 또는 `ORA-01861: literal does not match format string` |
| SQL Server | `Conversion failed when converting date and/or time from character string.` |

올바른 방법(먼저 문자열로 변환) 결과:

| customer_id | join_date | correct_coalesced_date |
|---|---|---|
| 3 | NULL | '정보없음' |
| 11 | NULL | '정보없음' |
| 그 외 10행 | 날짜 값 | 'YYYY-MM-DD' 형식 문자열 |

## STEP 9. ISNULL vs COALESCE 반환형 고정 여부(SQL Server 전용)

| 함수 | 결과 | 길이 |
|---|---|---|
| `ISNULL(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')` | `'정보없음('`(앞 5글자만, 조용히 잘림) | 5 |
| `COALESCE(CAST(NULL AS VARCHAR(5)), '정보없음(장기미접속)')` | `'정보없음(장기미접속)'`(전체) | 11 |

`ISNULL`은 에러 없이 **조용히 잘리는** 것이 STEP 5의 INSERT 에러(명시적 에러)와
대비되는 또 다른 함정이다 — SELECT 목록에서 바로 잘려버리므로 에러 로그조차
남지 않는다.

## 12. 실제 실행 검증 여부

미검증. 각 벤더 공식 문서의 COALESCE/NVL/ISNULL/NULLIF 동작 규칙, 데이터 타입
우선순위 규칙, 오류 코드(ORA-12899, ORA-01722, ORA-01858/01861, SQL Server의
truncation/conversion 오류 메시지)를 근거로 도출했으나 이 세션에서 실제
DBMS로 실행해 재확인하지 않았다.
