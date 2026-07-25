# 07. 예상 결과

미검증(12절 참고) — JOIN·집합연산의 NULL 처리 규칙은 ANSI SQL 표준
공통 규칙이므로 Oracle과 SQL Server 결과는 완전히 동일하다(문법만
`MINUS`/`EXCEPT`로 다름).

## STEP 1. INNER JOIN vs LEFT JOIN

`INNER JOIN` 결과 (9행):

| customer_id | dept_code | dept_name |
|---|---|---|
| 1 | D01 | 총무팀 |
| 2 | D02 | 영업팀 |
| 3 | D03 | 개발팀 |
| 5 | D01 | 총무팀 |
| 6 | D02 | 영업팀 |
| 7 | D03 | 개발팀 |
| 9 | D01 | 총무팀 |
| 11 | D02 | 영업팀 |
| 12 | D03 | 개발팀 |

customer_id 4, 8, 10은 결과에 없다(각각 dept_code=NULL, NULL, 'D99').

`LEFT JOIN` 결과 (12행, 4/8/10만 발췌):

| customer_id | dept_code | dept_name |
|---|---|---|
| 4 | NULL | **NULL** |
| 8 | D99 | **NULL** |
| 10 | NULL | **NULL** |

나머지 9행은 INNER JOIN과 동일한 `dept_name` 값을 그대로 가진다.

## STEP 2. NULL = NULL 재확인

| 쿼리 | 결과 |
|---|---|
| `eq_comparison_rule` | `UNKNOWN(=비교 규칙)` |
| SELF JOIN(customer_id 4, 10을 dept_code로 매칭) | **0행** |

## STEP 3. UNION vs UNION ALL (customer_id 4, 10의 dept_code만)

| 쿼리 | 결과 행 수 | 내용 |
|---|---|---|
| `UNION` | **1** | `(NULL)` |
| `UNION ALL` | **2** | `(NULL)`, `(NULL)` |

`UNION`은 두 NULL 행을 "중복"으로 인식해 하나로 합친다. `UNION ALL`은
중복 제거 자체를 하지 않으므로 이 규칙과 무관하게 2행이 남는다.

## STEP 4. INTERSECT / MINUS(EXCEPT)

| 쿼리 | Oracle 결과 | SQL Server 결과 |
|---|---|---|
| `INTERSECT` | 1행 `(NULL)` | 1행 `(NULL)` |
| `MINUS` / `EXCEPT` | **0행** | **0행** |

`INTERSECT`는 두 집합이 모두 `{NULL}`뿐이라 교집합에 NULL이 남는다.
`MINUS`/`EXCEPT`는 왼쪽의 NULL이 오른쪽의 NULL과 "같다"고 판정되어
제거되므로 결과가 0행이 된다.

## 요약 대조표

| 비교 방식 | NULL = NULL 판정 |
|---|---|
| `WHERE`/`JOIN ON`의 `=` | UNKNOWN (매칭 안 됨) |
| `UNION`(중복 제거) | 같다 (1행으로 병합) |
| `INTERSECT` | 같다 (교집합에 남음) |
| `MINUS`/`EXCEPT` | 같다 (차집합에서 제거됨) |

## 12. 실제 실행 검증 여부

미검증. JOIN `ON`의 NULL 비교 규칙과 집합연산의 NULL 동등 취급 규칙은
ANSI SQL 표준 및 각 벤더 공식 문서에 근거했으나, 이 세션에서 실제 DBMS로
실행해 재확인하지 않았다.
