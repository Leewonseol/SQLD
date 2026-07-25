---
type: written-exam-problem
pilot: true
primary_dbms: [oracle, sqlserver]
oracle_verified: false
sqlserver_verified: false
---

# 문제 07. 문자열·날짜·상위 N행·NULL 문법 (Oracle · SQL Server)

## 1. 필기 예상문제

> 다음 고객 테이블에서 (1) 성과 이름을 합쳐 전체 이름을 만들고, (2) 기준일
> `2025-06-01` 기준 가입 후 경과일수를 구하고, (3) 전화번호가 없는(NULL) 고객은
> `'미등록'`으로 표시한 뒤, (4) 가입일이 가장 최근인 고객 3명만 조회하는 SQL을
> 작성하시오. 추가로, 전화번호에 빈 문자열 `''`을 입력했을 때 `IS NULL` 조건이
> Oracle과 SQL Server에서 각각 어떻게 판정되는지 설명하시오.
>
> | 성 | 이름 | 가입일 | 전화번호 |
> |---|---|---|---|
> | 김 | 민준 | 2024-03-15 | 010-1111-2222 |
> | 이 | 서연 | 2024-07-01 | (없음) |
> | 박 | 도윤 | 2023-11-20 | 010-3333-4444 |
> | 최 | 하은 | 2025-01-10 | (없음) |
> | 정 | 지호 | 2024-05-05 | 010-5555-6666 |

이 문제는 계산이 아니라 **Oracle과 SQL Server의 문법·NULL 의미 차이 자체**가 정답의
일부다.

## 2. 손계산(가입일 최근순 상위 3명, 경과일수는 2025-06-01 기준)

1. 최하은(2025-01-10, 142일), 2. 이서연(2024-07-01, 335일), 3. 정지호(2024-05-05, 392일)

## 3. 공통 입력 데이터

```
customers(last_name, first_name, signup_date, phone)  -- 위 표 5행
```

## 4. Oracle SQL

[`oracle.sql`](./oracle.sql).

```sql
SELECT last_name || first_name AS full_name,
       DATE '2025-06-01' - signup_date AS days_since_signup,
       NVL(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC
FETCH FIRST 3 ROWS ONLY;
```

## 5. SQL Server SQL

[`sqlserver.sql`](./sqlserver.sql).

```sql
SELECT TOP 3
       last_name + first_name AS full_name,
       DATEDIFF(day, signup_date, '2025-06-01') AS days_since_signup,
       ISNULL(phone, '미등록') AS phone_display
FROM customers
ORDER BY signup_date DESC;
```

## 6. Oracle 예상 결과

상위 3행: 최하은(142), 이서연(335), 정지호(392) — 손계산과 일치.
추가 NULL 시연: `phone=''`으로 입력한 행에서 `IS NULL` → **TRUE(1)**.
(**실제 Oracle 검증 필요**)

## 7. SQL Server 예상 결과

상위 3행: Oracle과 동일.
추가 NULL 시연: `phone=''`으로 입력한 행에서 `IS NULL` → **FALSE(0)**
(빈 문자열은 NULL이 아닌 별개의 값으로 저장된다 — Oracle과 **정반대** 결과).
(**실제 SQL Server 검증 필요**)

## 8. 두 DBMS에서 같은 부분

- 상위 3명 조회 결과(이름·경과일수·전화번호 표시)는 완전히 동일하다.
- `DATE - DATE` 계열 연산과 `DATEDIFF`가 최종적으로 반환하는 일수 값은 같다.
- `NVL`/`ISNULL` 둘 다 "NULL을 대체값으로" 바꾸는 결과 자체는 같다.

## 9. 두 DBMS에서 다른 부분

| 항목 | Oracle | SQL Server |
|---|---|---|
| 문자열 결합 | `\|\|` | `+` |
| 날짜 차이 | `날짜1 - 날짜2` (연산자) | `DATEDIFF(day, 날짜2, 날짜1)` (함수, 단위 필수) |
| NULL 대체 | `NVL(x, 대체값)` | `ISNULL(x, 대체값)` |
| 상위 N행 | `FETCH FIRST n ROWS ONLY` 또는 `ROWNUM` 서브쿼리 | `TOP n` 또는 `OFFSET...FETCH` |
| **빈 문자열 `''`** | **NULL로 저장됨** (`IS NULL` → TRUE) | **NULL과 구분되는 별개의 값** (`IS NULL` → FALSE) |

마지막 행이 이 문제의 핵심이다 — **같은 `INSERT ... VALUES ('', ...)` 문장이 두
DBMS에서 실제로 다른 것을 데이터베이스에 남긴다.** Oracle에서 `WHERE phone IS NULL`은
빈 문자열로 입력한 행도 찾아내지만, SQL Server에서는 찾지 못한다(반대로
`WHERE phone = ''`는 SQL Server에서만 그 행을 찾는다).

## 10. SQLD 출제 함정

- "Oracle에서 결측치를 어떻게 처리하는가"를 묻는 문제에서 `WHERE phone = ''`으로
  빈 문자열 행을 걸러내려 하면, Oracle에서는 그 조건이 항상 UNKNOWN이 되어(NULL은
  `=`로 비교 불가) **아무 행도 찾지 못한다** — `WHERE phone IS NULL`을 써야 한다.
  같은 문제를 SQL Server 버전으로 풀 때는 반대로 `= ''`과 `IS NULL`을 **둘 다** 조건에
  넣어야 두 상태를 모두 잡을 수 있다.
- `ROWNUM <= 3`을 정렬 없는 원본 쿼리에 바로 걸면 "정렬 전 임의 3건"이 나온다 —
  `oracle.sql`의 두 번째 쿼리처럼 정렬을 먼저 끝낸 서브쿼리를 감싸야 한다.

## 11. 실기 Python/R 코드와의 대응

| SQL | Python | R |
|---|---|---|
| NULL 대체 | `df.fillna('미등록')`(pandas는 `''`과 `NaN`을 구분 — SQL Server와 유사) | `ifelse(is.na(x), '미등록', x)` |
| 상위 N행 | `df.sort_values(...).head(3)` | `head(df[order(...),], 3)` |

pandas는 SQL Server처럼 빈 문자열과 결측(`NaN`/`None`)을 구분하는 쪽에 가깝다 —
`Olist-고객데이터/00-데이터사전`에서 `df.isna()`와 `.str.strip()==''`를 **따로**
검사한 이유이기도 하다(하나의 조건으로 합치면 이 구분을 잃는다).

## 12. 보조 DBMS 실행 결과 (SQLite·DuckDB·MariaDB)

이 세션에서 실제 실행 확인(`python3 run_compare.py`): 상위 3명 조회 결과는 세 엔진
모두 Oracle·SQL Server와 일치한다. 세 엔진 모두 `''`과 `NULL`을 SQL Server처럼
**구분**한다(Oracle만 예외) — 즉 "빈 문자열=NULL" 취급은 다섯 DBMS 중 **Oracle에만
있는 특수 동작**이다. 부수적으로 MariaDB의 `\|\|`가 기본 설정에서 결합이 아니라
논리 OR로 해석되는 함정도 실제로 확인했다(`PIPES_AS_CONCAT` 모드를 켜야 Oracle과
같은 `\|\|` 결합 동작을 한다) — Oracle 스타일 SQL을 MariaDB에 이식할 때 걸리는
지점이다.

## 실행

```bash
# Oracle: oracle.sql을 Oracle SQL Developer 등에 복사해 실행 (이 저장소에서 실행 불가)
# SQL Server: sqlserver.sql을 SSMS 등에 복사해 실행 (이 저장소에서 실행 불가)
python3 run_compare.py   # 보조 DBMS(SQLite/DuckDB/MariaDB) 실행 비교
```
